#!/bin/bash

ARCH=i386

docker rmi debian-squeeze-minbase-$ARCH

cat >config.sh <<EOF
arch=$ARCH
EOF

docker run --privileged \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $PWD/docker-build-image.sh:/docker-build-image.sh \
    -v $PWD/config.sh:/tmp/config.sh \
    --name="build-image" \
    -it \
    ubuntu \
    /docker-build-image.sh

docker rm build-image
rm config.sh
