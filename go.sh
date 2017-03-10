#!/bin/bash

docker rmi debian-squeeze-minbase-i386

docker run --privileged \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $PWD/docker-build-image.sh:/docker-build-image.sh \
    --name="build-image" \
    ubuntu \
    /docker-build-image.sh

docker rm build-image
