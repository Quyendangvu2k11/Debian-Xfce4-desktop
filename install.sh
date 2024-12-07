CHROOT=$PREFIX/var/lib/proot-distro/installed-rootfs/debian-oldstable

install_debian(){
echo
if [[ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/debian-oldstable" ]]; then
echo ${G}"Existing Debian installation found, Resetting it..."${W}
proot-distro reset debian-oldstable
else
echo ${G}"Installing Debian..."${W}
echo
pkg update
pkg install proot-distro
proot-distro install debian-oldstable
fi
}

install_desktop(){
echo ${G}"Installing XFCE Desktop..."${W}
cat > $CHROOT/root/.bashrc <<- EOF
apt-get update
apt install udisks2 -y
rm -rf /var/lib/dpkg/info/udisks2.postinst
echo "" >> /var/lib/dpkg/info/udisks2.postinst
dpkg --configure -a
apt-mark hold udisks2
apt-get install xfce4 gnome-terminal nautilus dbus-x11 tigervnc-standalone-server -y
echo "vncserver -geometry 1280x720 -xstartup /usr/bin/startxfce4" >> /usr/local/bin/vncstart
echo "vncserver -kill :* ; rm -rf /tmp/.X1-lock ; rm -rf /tmp/.X11-unix/X1" >> /usr/local/bin/vncstop
chmod +x /usr/local/bin/vncstart 
chmod +x /usr/local/bin/vncstop 
sleep 2
exit
echo
EOF
proot-distro login debian-oldstable
rm -rf $CHROOT/root/.bashrc
}

adding_user(){
echo ${G}"Adding a User..."${W}
cat > $CHROOT/root/.bashrc <<- EOF
apt-get update
apt-get install sudo wget -y
sleep 2
useradd -m -s /bin/bash debian
echo "ubuntu:ubuntu" | chpasswd
echo "debian  ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/debian
sleep 2
exit
echo
EOF
proot-distro login debian
echo "proot-distro login --user debian debian-oldstable" >> $PREFIX/bin/debian
chmod +x $PREFIX/bin/debian
rm $CHROOT/root/.bashrc 

sound_fix(){
echo ${G}"Fixing Sound..."${W}
pkg update
pkg install x11-repo -y ; pkg install pulseaudio -y
cat > $HOME/.bashrc <<- EOF
pulseaudio --start \
    --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" \
    --exit-idle-time=-1
EOF

final_banner(){
banner
echo
echo ${G}"Installion completed"
echo
echo "ubuntu  -  To start Ubuntu"
echo
echo "ubuntu  -  default ubuntu password"
echo
echo "vncstart  -  To start vncserver, Execute inside ubuntu"
echo
echo "vncstop  -  To stop vncserver, Execute inside ubuntu"${W}
rm -rf ~/install.sh
}
banner
install_debian
install_desktop
adding_user
sound_fix
final_banner