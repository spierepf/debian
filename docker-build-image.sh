#!/bin/bash -x
### Build a docker image for debian i386.

if [ -e "/tmp/config.sh" ]
then
    source /tmp/config.sh
fi

### settings
arch=${arch:-`uname -m`}
suite=${1:-squeeze}
apt_mirror="http://archive.debian.org/debian"
variant="minbase"
docker_image="debian-$suite-$variant-$arch"
chroot_dir="/var/chroot/$docker_image"

### update package lists
apt-get update -y

### make sure that the required tools are installed
apt-get install -y docker.io debootstrap dchroot

case $arch in
i386|x86_64)
    ;;
armel)
    apt-get install -y qemu qemu-user-static binfmt-support
    update-binfmts --display
    mkdir -p $chroot_dir/usr/bin
    cp /usr/bin/qemu-arm-static $chroot_dir/usr/bin
    ;;
esac

### install a minbase system with debootstrap
export DEBIAN_FRONTEND=noninteractive
debootstrap --arch $arch --variant $variant $suite $chroot_dir $apt_mirror

### update the list of package sources
cat <<EOF > $chroot_dir/etc/apt/sources.list
deb $apt_mirror $suite main contrib non-free
#deb $apt_mirror $suite-updates main contrib non-free
deb http://security.debian.org/ $suite/updates main contrib non-free
EOF
cat $chroot_dir/etc/apt/sources.list | sed s/deb/deb-src/ >> $chroot_dir/etc/apt/sources.list

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
