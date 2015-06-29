#!/bin/bash

ECLIPSE_DOWNLOAD_URL="http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads/release/mars/R/eclipse-java-mars-R-linux-gtk-x86_64.tar.gz"
ECLIPSE_P2_START_ARGS="-clean -application org.eclipse.equinox.p2.director -noSplash"
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
    echo " "
    exit 0
}

show_confirmation() {
    ECLIPSE_BASE_DIR="$1"; shift;

    echo "Create/Update eclipse installation in $ECLIPSE_BASE_DIR? [y/N]"
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
    echo "-Dosgi.user.area=@user.home/.eclipse.user.area" >> $ECLIPSE_DIR/eclipse.ini
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

install_plugins() {
   ECLIPSE_DIR="$1"; shift;
   PLUGINS="$1"; shift;

   ALL_REPOSITORIES=""
   ALL_FEATURES=""
   
   for PLUGIN in $(echo "$PLUGINS" | sed -e 's/,/ /g')
   do
          PI_FILE="$TOOL_INSTALL_PATH/plugin-info/$PLUGIN.pi"

          check_for_file "$PI_FILE" "Plugin info";

          REPOSITORY=""
          FEATURES=""
          . "$PI_FILE"

          check_not_empty "REPOSITORY" "$REPOSITORY" "$PI_FILE"
          check_not_empty "FEATURES" "$FEATURES" "$PI_FILE"

          ALL_REPOSITORIES="${ALL_REPOSITORIES}${REPOSITORY},"
          ALL_FEATURES="${ALL_FEATURES}${FEATURES},"          
   done

   run_p2 "$ECLIPSE_DIR" -repository "$ALL_REPOSITORIES" -installIUs "$ALL_FEATURES"
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

install_dropins() {
   ECLIPSE_DIR="$1"; shift;
   DROPINS="$1"; shift;

   for DROPIN in $(echo "$DROPINS" | sed -e 's/,/ /g')
   do
      install_dropin "$ECLIPSE_DIR" "$DROPIN"
   done
}


STARTDIR=$(pwd)
SHOW_CONFIRMATION=1;

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
    p) PLUGINS="$OPTARG"
       ;;
    d) DROPINS="$OPTARG"
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
    show_confirmation "$ECLIPSE_BASE_DIR";
fi

if [ -f "$ECLIPSE_DIR/eclipse" ]
then
   echo "Eclipse is already installed => skipping eclipse installation."
else
    install_eclipse "$ECLIPSE_BASE_DIR" "$ECLIPSE_DIR"
fi

if [ ! -z "$PLUGINS" ]
then
	install_plugins "$ECLIPSE_DIR" "$PLUGINS"
fi

if [ ! -z "$DROPINS" ]
then
	install_dropins "$ECLIPSE_DIR" "$DROPINS"
fi

exit 0
