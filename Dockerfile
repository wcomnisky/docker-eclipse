FROM ubuntu

MAINTAINER Joerg Matysiak

# Please adjust values of USERNAME, uid and gid if needed 

ENV USERNAME developer

# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/$USERNAME && \
    echo "$USERNAME:x:${uid}:${gid}:Developer:/home/$USERNAME:/bin/bash" >> /etc/passwd && \
    echo "$USERNAME:x:${uid}:" >> /etc/group && \
    chown ${uid}:${gid} -R /home/$USERNAME



# Install missing packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
	ant \
	ant-contrib \
	bash-completion \
	curl \
	git \
	libswt-gtk-3-java \
	maven \
	software-properties-common \
	unzip \
	wget && \
    rm -rf /var/lib/apt/lists/*

# Install oracle jdks 6,7 and 8
RUN apt-add-repository ppa:webupd8team/java && \
    apt-get update && \
    echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \	
    echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \
    apt-get install -y --no-install-recommends \
	oracle-java7-installer \
	oracle-java8-installer && \
    rm -rf /var/lib/apt/lists/*

# Install latest gradle
#ENV GRADLE_DOWNLOAD_LINK https://services.gradle.org/distributions/gradle-2.4-all.zip
#RUN curl -L -o gradle.zip $GRADLE_DOWNLOAD_LINK && \
#     unzip gradle.zip -d /opt && \
#     rm gradle.zip && \
#     update-alternatives --install /usr/bin/gradle gradle /opt/gradle*/bin/gradle 100 

# copy eclipse install tools to image
ENV ECLIPSE_BASE_DIR /opt
ENV ECLIPSE_INST_TOOL /opt/eclipse_install_tools/install_eclipse.sh
ADD eclipse_install_tools/ /opt/eclipse_install_tools/
RUN chmod 755 $ECLIPSE_INST_TOOL

# Install eclipse
RUN mkdir -p $ECLIPSE_BASE_DIR/eclipse && chown $USERNAME:$USERNAME $ECLIPSE_BASE_DIR/eclipse
RUN $ECLIPSE_INST_TOOL -y -t $ECLIPSE_BASE_DIR -p egit,efxclipse,m2eclipse-tycho
RUN update-alternatives --install /usr/bin/eclipse eclipse $ECLIPSE_BASE_DIR/eclipse/eclipse 100 

USER $USERNAME
ENV HOME /home/$USERNAME

WORKDIR $HOME

# Eclipse is the default tool to start in this docker container
CMD $ECLIPSE_BASE_DIR/eclipse/eclipse
