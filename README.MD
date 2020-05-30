# GUIDE_AMDGPU-Mining-Ubuntu-20.04-LTS-Server-HWE
Guide to set all up for amdgpu's mining in Ubuntu Server LTS environnement; with some Vega 56 Pulse files that you can easily adapt to your config/username! I spent a lot of times in learning, trickering, testing, improving tools and configs to write this guide for beginners level understanding. 
If it's ok for you (i'm sure it will be..:)..) please consider donation, it would be very appreciated!
```sh
ETH: 0x691318ab130Bb4B82a521C59Cac60B417e003675
BTC: 3Ec5UjkZxXjM92s53U9w7SRQuhHEm7x2HH
XMR: 4GdoN7NCTi8a5gZug7PrwZNKjvHFmKeV11L6pNJPgj5QNEHsN6eeX3DaAQFwZ1ufD4LYCZKArktt113W7QjWvQ7CW9BZBGeRUR69Tp5AVj
```
![alt text](https://i.postimg.cc/zBJwNzgj/Capture-d-cran-du-2020-05-30-12-15-58.png)

### Install 
Ubuntu Server with the HWE kernel with btrfs partition and zram swap.
Also feel free to enable openssh deamon install for remote control of your RIG, see further for config...
**[Ubuntu 20.04 LTS ISO](https://releases.ubuntu.com/20.04/ubuntu-20.04-live-server-amd64.iso)** 

#### Burn it on USB Key then boot and follow the installer instructions.

### Ubuntu Config
Sudoers file, enable NOPASSWD for user, all commands
```sh
sudo visudo
Replace %sudo ALL=(ALL:ALL) ALL line to %sudo ALL=(ALL:ALL) NOPASSWD: ALL
```
Locales fix, adapt to your localisation
```sh
sudo ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime
sudo locale-gen fr_FR fr_FR.UTF-8
timedatectl set-local-rtc 1
sudo dpkg-reconfigure locales
```
### HWE Kernel Install 
```sh
sudo swapoff -a
sudo rm /swap.img
```
Delete Swap Files entries in /etc/fstab
```sh
sudo nano /etc/fstab
```
Install HWE Kernel and zram for automated swap configuration
```sh
sudo apt update
sudo apt install --install-recommends linux-generic-hwe-20.04
sudo apt upgrade
git clone https://github.com/StuartIanNaylor/zram-swap-config
cd zram-swap-config
chmod +x install.sh && sudo ./install.sh
cd ..
rm -r zram-swap-config
```
### AMD tweaks, fall back to ethX network interface naming
Edit the grub configuration file:
```sh
sudo nano /etc/default/grub
```
Replace GRUB_CMDLINE_LINUX_DEFAULT and GRUB_CMDLINE_LINUX lines

GRUB_CMDLINE_LINUX_DEFAULT="text amdgpu.ppfeaturemask=0xffffffff"
GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"

amdgpu.ppfeaturemask=0xffffffff kernel boot option allows control of GPU power states (GPU / VRAM clocks and voltages)

Update grub configuration
```sh
sudo update-grub && sudo update-grub2 && sudo update-initramfs -u -k all
```
### Network Configuration:
Edit network configuration file:
```sh
ls /etc/netplan/
```
Replace enpXsX to eth0 in *.yaml
```sh
sudo nano /etc/netplan/*.yaml
```
EDIT *.yaml as below, also you can check how to config netplan.[Read more here](https://documentation.online.net/fr/dedicated-server/network/network-configuration-with-netplan)
```sh
network:
    ethernets:
        eth0:
            dhcp4: true
    version: 2
```
Apply Config:
```sh
sudo netplan apply
sudo reboot
```

### Install AMDGPU Driver + OpenCL
[AMDGPU Community Ubuntu](https://help.ubuntu.com/community/AMDGPU-Driver)
```sh
wget https://drivers.amd.com/drivers/linux/19.50/amdgpu-pro-19.50-967956-ubuntu-18.04.tar.xz --referer http://support.amd.com/en-us/kb-articles/Pages/Radeon-Software-for-Linux-Release-Notes.aspx
tar -Jxvf amdgpu-pro-19.50-967956-ubuntu-18.04.tar.xz
cd amdgpu-pro-19.50-967956-ubuntu-18.04
```
Edit OS-Version file to change '20.04' to '18.04'
```sh
sudo nano /etc/os-release
./amdgpu-pro-install -y --opencl=pal,legacy,rocm --headless --no-dkms
```
Edit again to revert change to 20.04
```sh
sudo nano /etc/os-release
```
Add yourself to the video group
```sh
sudo usermod -aG video $LOGNAME
```
### Upgrade and install tools (usefull only; no deep shits!)
```sh
sudo apt update && sudo apt upgrade
sudo apt install wget build-essential cmake git libuv1-dev libssl-dev libhwloc-dev libmicrohttpd-dev lm-sensors htop opencl-amdgpu-pro-dev clinfo
sudo reboot
```
### RainbowMiner Installation
RainbowMiner is for me, the best multipool mining manager ever coded; feel free to install or choose to mine without!
[More Here](https://github.com/RainbowMiner/RainbowMiner)
```sh
sudo apt-get update
git clone https://github.com/rainbowminer/RainbowMiner
cd RainbowMiner
chmod +x *.sh
sudo ./install.sh
sudo ./start.sh ### Will start RainbowMiner; insure all is ready for it!
```
### SSH Remote Control
If you didn't check openssh installation during Ubuntu install:
```sh
sudo apt-get update
sudo apt-get install openssh-server
```
You are ready to log into your remote machine type on another computer to access
```sh
ssh username@public_IP
```
If you do not know the IP address, you can quickly identify it through the terminal by typing the command:
```sh
ip a
```
If you want to improve security and ssh config (non standard port, or encrypt access) see: https://phoenixnap.com/kb/how-to-enable-ssh-on-ubuntu

### Use [Tmux](http://manpages.ubuntu.com/manpages/xenial/man1/tmux.1.html) 
Terminal multiplexer to prevent mining activities to be stopped when SSH session is closed, you find full config file in my tools, just copy to home folder as .tmux.conf

For exemple: if your SSH session number 0 ends and you want to get back existing Tmux session when reconnecting
```sh
tmux attach -t 0
```
### Tools
Here is my ultimate collection of tools to Overclock and Mine over Linux.NOT WORKING?! =check path/directories commands.

- Install
```sh
git clone https://github.com/ArSd-g/AMDGPU-Mining-Ubuntu-20.04-LTS-Server-HWE
```
- Atiflash
```sh
chmod +x atiflash
sudo cp atiflash /usr/bin
sudo atiflash -h
```
 - Save Bios
```sh
sudo ./atiflash -s 0 CARD-NAME.rom ##Not Working? Use -f flag to force"
```
 - Flash Bios
```sh
sudo ./atiflash -p 0 CARD-NAME.rom ##Not Working? Use "-f" flag to force"
```
- Enable 1GB Huge Pages
```sh
sudo ./hugep.sh
and/or
sudo ./hugep2.sh
```
- Write Power Play Table, in this exemple for GPU number 1 write the content of V56V3PPT, reset on every reboot!
```sh
sudo ./setPPT.sh 1 V56V3PPT
```
- Monitor GPU, in this exemple it will monitor GPU number 1 and print infos checking every 5s
```sh
sudo ./moniterGPU.sh 5 1
```
### You are READY!
Take a deep breath and get ready to configure RainbowMiner

I hope this guide was clear and precise, feel free to contact me for suggestions, questions, corrections or just to say thanks!

### Donate:
```sh
ETH: 0x691318ab130Bb4B82a521C59Cac60B417e003675
BTC: 3Ec5UjkZxXjM92s53U9w7SRQuhHEm7x2HH
XMR: 4GdoN7NCTi8a5gZug7PrwZNKjvHFmKeV11L6pNJPgj5QNEHsN6eeX3DaAQFwZ1ufD4LYCZKArktt113W7QjWvQ7CW9BZBGeRUR69Tp5AVj
```

### SRCs
Special thanks for they awesome job and wonderfull tools and guides to:
- **https://github.com/xmrminer01102018/VegaToolsNConfigs**
- **https://github.com/RainbowMiner/RainbowMiner**
- **https://github.com/czombos/AMDGPU-XMR-ETH-Mining-Ubuntu**
- **https://github.com/patrickschur/amdvbflash**

### Links&Docs
- **https://releases.ubuntu.com**
- **https://documentation.online.net/fr/dedicated-server/network/network-configuration-with-netplan**
- **https://help.ubuntu.com/community/AMDGPU-Driver**
- **https://wiki.ubuntu.com/Kernel/LTSEnablementStack**
- **https://www.amd.com/en/support/kb/release-notes/rn-rad-lin-19-50-unified**
- **https://www.cyberciti.biz/tips/linux-swap-space.html**
- **https://itsfoss.com/create-swap-file-linux/**
- **https://github.com/RadeonOpenCompute/ROC-smi**
- **https://xmrig.com/docs/miner/hugepages**
- **https://phoenixnap.com/kb/how-to-enable-ssh-on-ubuntu**

