FROM dockerfile/java:oracle-java8

MAINTAINER Joerg Matysiak

# Please adjust values of USERNAME, uid and gid if needed 

ENV USERNAME developer

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/$USERNAME && \
    echo "$USERNAME:x:${uid}:${gid}:Developer,,,:/home/$USERNAME:/bin/bash" >> /etc/passwd && \
    echo "$USERNAME:x:${uid}:" >> /etc/group && \
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME && \
    chown ${uid}:${gid} -R /home/$USERNAME


USER $USERNAME
ENV HOME /home/$USERNAME

WORKDIR $HOME

# Install missing packages
RUN sudo apt-get update
RUN sudo apt-get install libswt-gtk-3-java unzip ant ant-contrib git bash-completion -y

ENV ECLIPSE_DIR /opt/eclipse

ENV ECLIPSE_DOWNLOAD_URL http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads/release/luna/SR1a/eclipse-rcp-luna-SR1a-linux-gtk-x86_64.tar.gz 
# Download Eclipse for RCP and RAP developers
RUN sudo mkdir -p $(dirname $ECLIPSE_DIR) && \
    sudo chown $USERNAME:$USERNAME $(dirname $ECLIPSE_DIR) && \
    cd $(dirname $ECLIPSE_DIR) && curl $ECLIPSE_DOWNLOAD_URL | tar -xvz

# Fix Eclipse Classcast Exception at startup
# see http://stackoverflow.com/questions/26279570/getting-rid-of-org-eclipse-osgi-internal-framework-equinoxconfiguration1-that-c
#
RUN echo "-Dosgi.configuration.area.default=null" >> $ECLIPSE_DIR/eclipse.ini && \
    echo "-Dosgi.user.area.default=null" >> $ECLIPSE_DIR/eclipse.ini && \
    echo "-Dosgi.user.area=@user.home" >> $ECLIPSE_DIR/eclipse.ini &&\
    echo "-Dosgi.instance.area.default=null" >> $ECLIPSE_DIR/eclipse.ini

# Remove MaxPermSize parameter from eclipse.ini. 
# (This parameter is no longer supported with Java 8)
RUN grep -v -e "MaxPermSize" -e "256m" $ECLIPSE_DIR/eclipse.ini > $ECLIPSE_DIR/eclipse.ini.new; mv $ECLIPSE_DIR/eclipse.ini.new $ECLIPSE_DIR/eclipse.ini 

ADD run_p2.sh  $ECLIPSE_DIR/run_p2.sh
RUN sudo chown $USERNAME:$USERNAME $ECLIPSE_DIR/run_p2.sh; chmod 755 $ECLIPSE_DIR/run_p2.sh

# Install EGit
RUN $ECLIPSE_DIR/run_p2.sh \
    -repository http://download.eclipse.org/egit/updates \
    -installIUs org.eclipse.egit,org.eclipse.egit.core,org.eclipse.egit.ui,org.eclipse.jgit,org.eclipse.jgit.ui

# Install Findbugs
RUN $ECLIPSE_DIR/run_p2.sh \
    -repository http://findbugs.cs.umd.edu/eclipse \
    -installIUs edu.umd.cs.findbugs.plugin.eclipse 

# Install Checkstyle
RUN $ECLIPSE_DIR/run_p2.sh \
    -repository http://eclipse-cs.sourceforge.net/update \
    -installIUs net.sf.eclipsecs.ui 

# Install Database Viewer
RUN $ECLIPSE_DIR/run_p2.sh \
    -repository http://www.ne.jp/asahi/zigen/home/plugin/dbviewer/ \
    -installIUs zigen.plugin.db 

# Install Memory Analyzer
RUN  $ECLIPSE_DIR/run_p2.sh \
    -repository http://download.eclipse.org/mat/1.4/update-site/ \
    -installIUs org.eclipse.mat.ui,org.eclipse.mat.report,org.eclipse.mat.ui.help 

# Install QuickREx (as dropin)
RUN cd $ECLIPSE_DIR/dropins && curl -L -O http://sourceforge.net/projects/quickrex/files/latest/download/QuickREx_3.5.0.jar

# Install WicketShell
RUN $ECLIPSE_DIR/run_p2.sh \
    -repository http://www.wickedshell.net/updatesite \
    -installIUs net.sf.wickedshell.ui,net.sf.wickedshell.shell 

# Install latest gradle
ENV GRADLE_DOWNLOAD_LINK https://services.gradle.org/distributions/gradle-2.2.1-bin.zip
RUN curl -L  -o gradle.zip $GRADLE_DOWNLOAD_LINK && \
     sudo unzip gradle.zip -d /opt && \
     rm gradle.zip && \
     sudo update-alternatives --install /usr/bin/gradle gradle /opt/gradle*/bin/gradle 100 

###
### TODO: fix gradle tooling
###

# Install Eclipse gradle tooling (needs antlr and protobuf-dt)
#RUN $ECLIPSE_INSTALL_CALL_PREFIX \
#    -repository http://download.eclipse.org/modeling/tmf/xtext/updates/composite/releases/ \
#    -installIUs org.antlr.runtime,org.eclipse.emf.codegen.ecore.xtext\
#    $ECLIPSE_INSTALL_CALL_POSTFIX



#RUN $ECLIPSE_INSTALL_CALL_PREFIX \
#    -repository http://protobuf-dt.googlecode.com/git/update-site \
#    -installIUs com.google.eclipse.protobuf,com.google.eclipse.protobuf.ui \
#    $ECLIPSE_INSTALL_CALL_POSTFIX

#RUN $ECLIPSE_INSTALL_CALL_PREFIX \
#    -repository http://dist.springsource.com/release/TOOLS/gradle \
#    -installIUs org.springframework.ide.eclipse.uaa,org.springsource.ide.eclipse.gradle.ui,org.springsource.ide.eclipse.gradle.ui.taskview \
#    $ECLIPSE_INSTALL_CALL_POSTFIX

CMD $ECLIPSE_DIR/eclipse
