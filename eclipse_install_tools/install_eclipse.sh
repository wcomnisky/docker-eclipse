#!/bin/bash

ECLIPSE_DOWNLOAD_URL="http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads/release/luna/SR1a/eclipse-rcp-luna-SR1a-linux-gtk-x86_64.tar.gz"
ECLIPSE_P2_START_ARGS="-clean -purgeHistory -application org.eclipse.equinox.p2.director -noSplash"
ECLIPSE_VMARGS="-vmargs -Declipse.p2.mirrors=true -Djava.net.preferIPv4Stack=true"
#!/bin/bash

show_help() {
    echo " "
    echo "Usage: $0 -t <installation dir> [-y] [-p <plugin name>] [-d <dropin name>]"
    echo " "
    echo "\t-y -- don't show the confirmation dialog"
    echo "\t-p -- installs the plugin defined in plugin-info/<plugin name>.pi"
    echo "\t-d -- installs the dropin defined in drop-info/<dropin name>.di"
    echo " "
    echo "If neigther -p nor -d are passed eclipse base installation is started."
    echo "Only one of -p and -d is allowed, call the script twice to install a plugin and a dropin"
    echo " "
    exit 0
}

show_confirmation() {
    ECLIPSE_BASE_DIR="$1"; shift;

    echo "Create a new eclipse installation in $ECLIPSE_BASE_DIR? [y/N]"
    read a
    case $a in
	y|Y)
	    echo "Ok ... here we go ..."
	    ;;

	*)
            echo "Aborted"
            exit 1;
    esac
}

download_eclipse() {
    ECLIPSE_BASE_DIR="$1"; shift;
    ECLIPSE_DIR="$1"; shift;

    # Download Eclipse for RCP and RAP developers
    mkdir -p $(dirname $ECLIPSE_DIR)
    curl "$ECLIPSE_DOWNLOAD_URL" | tar -C "$ECLIPSE_BASE_DIR" -xvz
}

fix_eclipse_classcast_exception() {
    ECLIPSE_DIR="$1"; shift;

    # Fix Eclipse Classcast Exception at startup
    # see http://stackoverflow.com/questions/26279570/getting-rid-of-org-eclipse-osgi-internal-framework-equinoxconfiguration1-that-c
    #
    echo "-Dosgi.configuration.area.default=null" >> $ECLIPSE_DIR/eclipse.ini 
    echo "-Dosgi.user.area.default=null" >> $ECLIPSE_DIR/eclipse.ini 
    echo "-Dosgi.user.area=@user.home" >> $ECLIPSE_DIR/eclipse.ini
    echo "-Dosgi.instance.area.default=null" >> $ECLIPSE_DIR/eclipse.ini    
}

remove_maxpermsize_from_eclipse_ini() {
    ECLIPSE_DIR="$1"; shift;

    # Remove MaxPermSize parameter from eclipse.ini. 
    # (This parameter is no longer supported with Java 8)
    grep -v -e "MaxPermSize" -e "256m" $ECLIPSE_DIR/eclipse.ini > $ECLIPSE_DIR/eclipse.ini.new;
    mv $ECLIPSE_DIR/eclipse.ini.new $ECLIPSE_DIR/eclipse.ini 
}

install_eclipse() {
    ECLIPSE_BASE_DIR="$1"; shift;
    ECLIPSE_DIR="$1"; shift;

    download_eclipse "$ECLIPSE_BASE_DIR" "$ECLIPSE_DIR"
    if [ -f "$ECLIPSE_DIR" ]
    then
	echo "Found an existing eclipse installation in \"$ECLIPSE_DIR\" aborting!";
	exit 1;
    fi
    fix_eclipse_classcast_exception "$ECLIPSE_DIR"
    remove_maxpermsize_from_eclipse_ini "$ECLIPSE_DIR"
}

run_p2() {
    ECLIPSE_DIR="$1"; shift;
    
    ECLIPSE_BINARY="$ECLIPSE_DIR/eclipse"
    $ECLIPSE_BINARY $ECLIPSE_P2_START_ARGS $@ $ECLIPSE_JVMARGS
}

check_for_file() {
    FILENAME="$1"; shift;
    FILETYPE="$1"; shift;

    if [ ! -f "$FILENAME" ]
    then
	echo "Error: $FILETYPE file \"$FILENAME\" not found! - aborting"
	exit 1;
    fi
}

check_not_empty() {
    PARAMETERNAME="$1"; shift;
    PARAMETERVALUE="$1"; shift;
    FILENAME="$1"; shift;

    if [ -z "$PARAMETERVALUE" ]
    then
	echo "Error: Invalid file format \"$FILENAME\"; \"$PARAMETERNAME\" is missing - aborting!"
	exit 1	
    fi
}

install_plugin () {
    ECLIPSE_DIR="$1"; shift;
    PLUGIN="$1"; shift;

    PI_FILE="$TOOL_INSTALL_PATH/plugin-info/$PLUGIN.pi"

    check_for_file "$PI_FILE" "Plugin info";

    REPOSITORY=""
    FEATURES=""
    . "$PI_FILE"

    check_not_empty "REPOSITORY" "$REPOSITORY" "$PI_FILE"
    check_not_empty "FEATURES" "$FEATURES" "$PI_FILE"

    run_p2 "$ECLIPSE_DIR" -repository "$REPOSITORY" -installIUs "$FEATURES"
}

install_dropin () {
    ECLIPSE_DIR="$1"; shift;
    DROPIN="$1"; shift;

    DI_FILE="$TOOL_INSTALL_PATH/dropin-info/$DROPIN.di"

    check_for_file "$DI_FILE" "Dropin info";

    DROPIN_URL=""
    . "$DI_FILE"

    check_not_empty "DROPIN_URL" "$DROPIN_URL" "$DI_FILE"

    (cd $ECLIPSE_DIR/dropins && curl -L -O "$DROPIN_URL")
}

STARTDIR=$(pwd)
SHOW_CONFIRMATION=1;

RUN_ECLIPSE_INSTALLATION=1
PLUGIN="";
DROPIN=""
ECLIPSE_DIR=""
ECLIPSE_BASE_DIR=""
TOOL_INSTALL_PATH=$(dirname $0)

while getopts "h?t:p:d:y" opt; do
    case "$opt" in
    h|\?)
        show_help
        ;;
    y)  SHOW_CONFIRMATION=0
        ;;
    t) ECLIPSE_BASE_DIR="$OPTARG";
       ECLIPSE_DIR="$ECLIPSE_BASE_DIR/eclipse"	    
	;;
    p) PLUGIN="$OPTARG"
       RUN_ECLIPSE_INSTALLATION=0;
       ;;
    d) DROPIN="$OPTARG"
       RUN_ECLIPSE_INSTALLATION=0;
       ;;
    esac
done

if [ -z "$ECLIPSE_DIR" ]
then
    echo "Error: no target dir"
    show_help
fi

if [ ! -z "$DROPIN" ] && [ ! -z "$PLUGIN" ]
then
    echo "Error: -d and -p specified!"
    show_help
fi

if [ $SHOW_CONFIRMATION -ne 0 ]
then 
    show_confirmation;
fi

if [ $RUN_ECLIPSE_INSTALLATION -ne 0 ]
then
    install_eclipse "$ECLIPSE_BASE_DIR" "$ECLIPSE_DIR"
else
    if [ ! -z "$PLUGIN" ]
    then
	install_plugin "$ECLIPSE_DIR" "$PLUGIN"
    elif [ ! -z "$DROPIN" ]
    then
	install_dropin "$ECLIPSE_DIR" "$DROPIN"
    else
	show_help
    fi	
fi

exit 0
