FROM ndeloof/java

# Heavily based on http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/

MAINTAINER Baptiste Mathus <batmat@batmat.net>

# TODO : variabilize those values
# Replace 1000 with your user / group id
RUN export uid=1000 gid=1000 && \
    mkdir -p /home/developer && \
    echo "developer:x:${uid}:${gid}:Developer,,,:/home/developer:/bin/bash" >> /etc/passwd && \
    echo "developer:x:${uid}:" >> /etc/group && \
    echo "developer ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/developer && \
    chmod 0440 /etc/sudoers.d/developer && \
    chown ${uid}:${gid} -R /home/developer

USER developer
ENV HOME /home/developer

WORKDIR /home/developer
RUN curl http://ftp-stud.fht-esslingen.de/pub/Mirrors/eclipse/technology/epp/downloads/release/luna/SR1a/eclipse-rcp-luna-SR1a-linux-gtk-x86_64.tar.gz | tar -xvz

RUN sudo apt-get update
RUN sudo apt-get install libswt-gtk-3-java -y

# Install Findbugs
RUN /home/developer/eclipse/eclipse -clean -purgeHistory \
    -application org.eclipse.equinox.p2.director \
    -noSplash \
    -repository http://findbugs.cs.umd.edu/eclipse \
    -installIUs edu.umd.cs.findbugs.plugin.eclipse \
    -vmargs -Declipse.p2.mirrors=true -Djava.net.preferIPv4Stack=true

# Install Checkstyle
RUN /home/developer/eclipse/eclipse -clean -purgeHistory \
    -application org.eclipse.equinox.p2.director \
    -noSplash \
    -repository  http://eclipse-cs.sourceforge.net/update \
    -installIUs net.sf.eclipsecs.ui \
    -vmargs -Declipse.p2.mirrors=true -Djava.net.preferIPv4Stack=true

# Install Database Viewer
RUN /home/developer/eclipse/eclipse -clean -purgeHistory \
    -application org.eclipse.equinox.p2.director \
    -noSplash \
    -repository http://www.ne.jp/asahi/zigen/home/plugin/dbviewer/  \
    -installIUs zigen.plugin.db \
    -vmargs -Declipse.p2.mirrors=true -Djava.net.preferIPv4Stack=true

# Install Memory Analyzer
RUN /home/developer/eclipse/eclipse -clean -purgeHistory \
    -application org.eclipse.equinox.p2.director \
    -noSplash \
    -repository \
    http://download.eclipse.org/mat/1.4/update-site/\
    -installIUs org.eclipse.mat.ui,org.eclipse.mat.report,org.eclipse.mat.ui.help \
    -vmargs -Declipse.p2.mirrors=true -Djava.net.preferIPv4Stack=true

# Install QuickREx
RUN sudo apt-get install wget -y
RUN cd /home/developer/eclipse/dropins && wget http://sourceforge.net/projects/quickrex/files/latest/download/QuickREx_3.5.0.jar

# Install WicketShell
RUN /home/developer/eclipse/eclipse -clean -purgeHistory \
    -application org.eclipse.equinox.p2.director \
    -noSplash \
    -repository http://www.wickedshell.net/updatesite \
    -installIUs net.sf.wickedshell.ui,net.sf.wickedshell.shell \
    -vmargs -Declipse.p2.mirrors=true -Djava.net.preferIPv4Stack=true

# Fix Eclipse Classcast Exception
RUN echo "-Dosgi.configuration.area.default=null" >> /home/developer/eclipse/eclipse.ini && \
    echo "-Dosgi.user.area.default=null" >> /home/developer/eclipse/eclipse.ini && \
    echo "-Dosgi.user.area=@user.home" >> /home/developer/eclipse/eclipse.ini &&\
     echo "-Dosgi.instance.area.default=null" >> /home/developer/eclipse/eclipse.ini

CMD /home/developer/eclipse/eclipse

