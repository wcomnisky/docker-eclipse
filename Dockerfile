FROM ubuntu

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
RUN sudo apt-get update && \
    sudo apt-get install libswt-gtk-3-java unzip ant ant-contrib git bash-completion curl software-properties-common wget -y

# Install oracle jdks 6,7 and 8
RUN sudo apt-add-repository ppa:webupd8team/java && \
    sudo apt-get update && \
    echo oracle-java6-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections && \	
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections && \
    sudo apt-get install oracle-java6-installer \
    	 oracle-java7-installer \
	 oracle-java8-installer -y

# Install latest gradle
ENV GRADLE_DOWNLOAD_LINK https://services.gradle.org/distributions/gradle-2.2.1-bin.zip
RUN curl -L -o gradle.zip $GRADLE_DOWNLOAD_LINK && \
     sudo unzip gradle.zip -d /opt && \
     rm gradle.zip && \
     sudo update-alternatives --install /usr/bin/gradle gradle /opt/gradle*/bin/gradle 100 

# copy eclipse install tools to image
ENV ECLIPSE_BASE_DIR /opt
ENV ECLIPSE_INST_TOOL /opt/eclipse_install_tools/install_eclipse.sh
ADD eclipse_install_tools/ /opt/eclipse_install_tools/
RUN sudo chmod 755 $ECLIPSE_INST_TOOL

# Install eclipse
RUN sudo mkdir -p $ECLIPSE_BASE_DIR/eclipse && sudo chown $USERNAME:$USERNAME $ECLIPSE_BASE_DIR/eclipse
RUN $ECLIPSE_INST_TOOL -t $ECLIPSE_BASE_DIR -y
RUN sudo update-alternatives --install /usr/bin/eclipse eclipse $ECLIPSE_BASE_DIR/eclipse/eclipse 100 

# Install eclipse plugins and dropins
RUN $ECLIPSE_INST_TOOL -t $ECLIPSE_BASE_DIR -y -p findbugs
RUN $ECLIPSE_INST_TOOL -t $ECLIPSE_BASE_DIR -y -p egit
RUN $ECLIPSE_INST_TOOL -t $ECLIPSE_BASE_DIR -y -p checkstyle
RUN $ECLIPSE_INST_TOOL -t $ECLIPSE_BASE_DIR -y -p databaseviewer
RUN $ECLIPSE_INST_TOOL -t $ECLIPSE_BASE_DIR -y -p mat
RUN $ECLIPSE_INST_TOOL -t $ECLIPSE_BASE_DIR -y -d quickrex
#RUN $ECLIPSE_INST_TOOL -t $ECLIPSE_BASE_DIR -y -e easyshell


# Eclipse is the default tool to start in this docker container
CMD $ECLIPSE_BASE_DIR/eclipse/eclipse
