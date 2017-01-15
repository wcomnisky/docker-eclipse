Running Eclipse Luna RCP inside a Docker container
--------------------------------------------------

## Preliminary note

This image is based on these blog entries

* http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/
* http://www.lorenzobettini.it/2012/10/installing-eclipse-features-via-the-command-line/

Thanks to the authors :)

## What's installed?

* Eclipse Luna SR2 for RCP and RAP developers

### Plugins

 * Findbugs¹
 * Checkstyle¹
 * Database Viewer¹
 * Memory Analyzer¹
 * QuickREx¹
 * M2Eclipse (Tycho)
 * E(fx)clipse

 ¹ Available but commented. The image must be built again using the Dockerfile with the specific parameters and/or uncommented lines to have the feature.

### Tools (command line, use e.g. in Wicked Shell)

 * Oracle JDKs 6, 7 and 8
 * Gradle¹
 * Ant
 * Git

¹ Available but commented. The image must be built again using the Dockerfile with the specific parameters and/or uncommented lines to have the feature.

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

The container is stopped when Eclipse is shut down.

## Get a shell within a running container

To get a shell within the running container (e.g. for running `gradle` or `mvn`from the command line) call:

    docker exec -ti -u developer eclipse-rcp-luna bash

## Troubleshooting

If the UI does not come up and the following message appears:

    No protocol specified
    Eclipse: Cannot open display:

Try to call the following before starting the container. X server connection uses a local socket `/tmp/.X11-unix` and such direct access is disabled.

    xhost +local:
