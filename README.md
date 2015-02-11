Running Eclipse Luna inside a Docker container
---------------------------------------------

## Preliminary note
This image is heavily based on these blog entries

* http://fabiorehm.com/blog/2014/09/11/running-gui-apps-with-docker/ 
* http://www.lorenzobettini.it/2012/10/installing-eclipse-features-via-the-command-line/

## TL;DR: how to use it

### Run it

    $ sudo docker run -it \
        -v ~/workspace/:/home/developer/workspace/ \
        -e DISPLAY \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        joemat/docker-eclipse

### Build the image if you don't trust the pullable one

    $ sudo docker build -t joemat/docker-eclipse
