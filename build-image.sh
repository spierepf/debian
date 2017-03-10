#!/bin/bash -x
### Build a docker image for debian i386.

### settings
arch=i386
suite=${1:-squeeze}
chroot_dir="/var/chroot/$suite"
apt_mirror="http://archive.debian.org/debian"
variant="minbase"
docker_image="debian-$suite-$variant-$arch"

### make sure that the required tools are installed
apt-get install -y docker.io debootstrap dchroot

### install a minbase system with debootstrap
export DEBIAN_FRONTEND=noninteractive
debootstrap --arch $arch --variant $variant $suite $chroot_dir $apt_mirror

### update the list of package sources
cat <<EOF > $chroot_dir/etc/apt/sources.list
deb $apt_mirror $suite main contrib non-free
#deb $apt_mirror $suite-updates main contrib non-free
deb http://security.debian.org/ $suite/updates main contrib non-free
EOF

### upgrade packages
chroot $chroot_dir apt-get update
chroot $chroot_dir apt-get upgrade -y

### cleanup
chroot $chroot_dir apt-get autoclean
chroot $chroot_dir apt-get clean
chroot $chroot_dir apt-get autoremove

### create a tar archive from the chroot directory
tar cfz debian.tgz -C $chroot_dir .

### import this tar archive into a docker image:
cat debian.tgz | docker import - $docker_image

# ### push image to Docker Hub
# docker push $docker_image

### cleanup
rm debian.tgz
rm -rf $chroot_dir
