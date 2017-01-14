Running Eclipse Luna inside a Docker container
---------------------------------------------

## Preliminary note

This image is based on these blog entries

* http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/ 
* http://www.lorenzobettini.it/2012/10/installing-eclipse-features-via-the-command-line/

Thanks to the authors :)

## What's installed?

* Eclipse Non (or Mars or Luna - depends on tag) for RCP and RAP developers

### Plugins

 * Findbugs
 * Checkstyle
 * Database Viewer
 * Memory Analyzer
 * QuickREx
 * M2Eclipse (Tycho)
 * E(fx)clipse
 
### Tools (command line, use e.g. in Wicked Shell)

 * Oracle JDKs 6 (on Luna tag), 7 and 8
 * Gradle
 * Ant
 * Git

## Build the image from Dockerfile

    git clone https://github.com/guedressel/docker-eclipse.git
    cd docker-eclipse
   
    # (optional: adjust UID, GUI and User in Dockerfile)

    docker build -t eclipse-rcp:neon .
   
    # run the image to create a container
    docker run -it \
	--name eclipse-rcp-neon \
	-v ~/workspace/:/home/developer/workspace/ \
        -e DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        eclipse-rcp:neon

## Subsequent starts 

    docker start -ia eclipse-rcp-neon

The container is stopped when Eclipse is shut down.

## Get a shell within a running container

To get a shell within the running container (e.g. for running `gradle` or `mvn`from the commandline) call:

    docker exec -ti -u developer eclipse-rcp-neon bash 

## Troubleshooting

If the UI does not come up and the following message appears:

    No protocol specified
    Eclipse: Cannot open display:

Try to call `xhost +local:` before starting the container. (Because the X server connection uses a local socket `/tmp/.X11-unix` and such direct access is disabled.)
