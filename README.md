Running Eclipse Luna inside a Docker container
---------------------------------------------

## Preliminary note

This image is based on these blog entries

* http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/ 
* http://www.lorenzobettini.it/2012/10/installing-eclipse-features-via-the-command-line/

Thanks to the authors :)

## What's installed?

* Eclipse Luna SR2 for RCP and RAP developers

### Plugins

 * Findbugs
 * Checkstyle
 * Database Viewer
 * Memory Analyzer
 * QuickREx
 * M2Eclipse (Tycho)
 * E(fx)clipse
 
### Tools (command line, use e.g. in Wicket Shell)

 * Oracle JDKs 6, 7 and 8
 * Gradle
 * Ant
 * Git

## Build the image from Dockerfile

    git clone https://github.com/guedressel/docker-eclipse.git
    cd docker-eclipse
   
    # (optional: adjust UID, GUI and User in Dockerfile)

    docker build -t eclipse-rcp:luna .
   
    # run the image to create a container
    docker run -it \
	--name eclipse-rcp-luna \
	-v ~/workspace/:/home/developer/workspace/ \
        -e DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        eclipse-rcp:luna

## Subsequent starts 

    docker start -ia eclipse-rcp-luna
