## GUIDE-amdgpu-mining-Ubuntu-Server-LTS-18.04.5--04/2021-UPDATED
Guide to set all up for amdgpu's mining in Ubuntu Server LTS environnement; with Vega10 exemple (RX Vega 56 Pulse) files that you can easily adapt to your config/username!   

I spent a lot of times in learning, trickering, testing, improving tools and configs to write this guide for beginners level understanding.   
If it's ok for you (i'm sure it will be..:)..) please consider donation, it would be very appreciated!   
```sh
BTC: 3DMFX97J1iz65xJRwyiMNNFFWr9qgn4PP3
LTC: MBeEPQctvNGnFFFsMuJxbLwKMqUBUNHhsN
ETH: 0x2A2Ae71baE7EefFB21B3430e488a55f555cb9430
XMR: 86sXqcNXaq3UBG9oMAfst1fXRLicKWE6QKzecf7eooiCa6iQkBC4SUFKkS8zJ1nCSkCEUGUncgYHG8csZead83wu9LeZAZB
```
![alt text](https://i.postimg.cc/Hnbv7yKG/Capture-d-cran-du-2020-06-28-19-08-25.png)

## Install 
#### Burn it on USB Key then boot and follow the installer instructions.  
**[Ubuntu 18.04.5 LTS ISO](https://releases.ubuntu.com/18.04/ubuntu-18.04.5-live-server-amd64.iso)** 

1- Preferred Boot USB mode : UEFI  
2-Choose "Boot and install wit HWE Kernel"  
3-Install Disc:   
-a Install Ubuntu Server LTS using "entire disc" (only if dedicated disc)  
Install Ubuntu Server with Ext4 Partition or XFS (fast I/O Capability) and auto-swap creation (file).  
-b Choose to create custom install on an existing partitions disc  
UEFI and Legacy creation will differ refer: **[Install Ubuntu 18.04 UEFI/Legacy mode](https://www.itzgeek.com/how-tos/linux/ubuntu-how-tos/how-to-install-ubuntu-18-04-lts-bionic-beaver-on-uefi-and-legacy-bios-system.html)**  
Also feel free to enable openssh deamon install for remote control of your RIG, see further for config...   
4-Wait install process & update finish and reboot to new environnement  

## Ubuntu Config
Sudoers file, enable NOPASSWD for user, all commands
```sh
sudo visudo
```
Replace: 
```sh
%sudo ALL=(ALL:ALL) ALL
```
to 
```sh
%sudo ALL=(ALL:ALL) NOPASSWD: ALL
```
Locales fix, adapt to your localisation
```sh
sudo ln -s /usr/share/zoneinfo/Europe/Paris /etc/localtime
sudo locale-gen fr_FR fr_FR.UTF-8
timedatectl set-local-rtc 1
sudo dpkg-reconfigure locales
```
### AMD tweaks, fall back to ethX network interface naming
Edit the grub configuration file:
```sh
sudo nano /etc/default/grub
```
Replace GRUB_CMDLINE_LINUX_DEFAULT and GRUB_CMDLINE_LINUX lines
```sh
GRUB_CMDLINE_LINUX_DEFAULT="text amdgpu.ppfeaturemask=0xffffffff amdgpu.vm_fragment_size=9"
GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"
```
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
sudo netplan apply && sudo reboot
```

### Install AMDGPU Driver + OpenCL
Download amdgpu-drivers, on 04/21 >=20.40 recommended due to "large alloc memory" possibility!
```sh
wget https://drivers.amd.com/drivers/linux/amdgpu-pro-20.40-1147287-ubuntu-18.04.tar.xz --referer https://www.amd.com/en/support/kb/release-notes/rn-amdgpu-unified-linux-20-40
tar -Jxvf amdgpu-pro-20.40-1147287-ubuntu-18.04.tar.xz
cd amdgpu-pro-20.40-1147287-ubuntu-18.04
```
I experienced some trouble with drivers to make Vega10 running ok at full load. 
I recommend to install the full pro stack even if no monitors are connected.
*=rocr, replace depreciated *=pal, option, adapt as driver needs
```sh
./amdgpu-pro-install -y
```
Or you can choose to install needed Opencl components only
```sh
./amdgpu-pro-install -y --opencl=pal,legacy,rocm --headless 
```
Add yourself to the video group
```sh
sudo usermod -aG video $LOGNAME
```
### Upgrade and install tools (usefull only; no deep shits!)
```sh
sudo apt update && sudo apt upgrade
sudo apt install build-essential cmake git libuv1-dev libssl-dev libhwloc-dev libmicrohttpd-dev lm-sensors htop opencl-amdgpu-pro-dev clinfo
sudo reboot
```
## RainbowMiner Installation
RainbowMiner is for me, the best multipool mining manager ever coded; feel free to install or choose to mine without!
[More Here](https://github.com/RainbowMiner/RainbowMiner)
```sh
sudo apt-get update
git clone https://github.com/rainbowminer/RainbowMiner
cd RainbowMiner
chmod +x *.sh
sudo ./install.sh
./start.sh ### Will start RainbowMiner; insure all is ready for it!
```
### SSH Remote Control
If you didn't check openssh installation during Ubuntu install:
```sh
sudo apt-get update
sudo apt-get install openssh-server
```
You are ready to log into your remote machine type on another computer to access:
```sh
ssh username@public_IP 
```
I Recommend to change port in /etc/ssh/sshd_config to something like "2009" or other! then add "-p portnumber"  

If you do not know the IP address, you can quickly identify it through the terminal by typing the command:
```sh
ip a
```
If you want to improve security and ssh config (non standard port, or encrypt access) see: [SSH Security](https://anansewaa.com/quick-tips-to-harden-ssh-on-ubuntu/)

### Use [Tmux](http://manpages.ubuntu.com/manpages/xenial/man1/tmux.1.html) 
Terminal multiplexer to prevent mining activities to be stopped when SSH session is closed, you find full config file in my tools, just copy to home folder as .tmux.conf

For exemple: if your SSH session number 0 ends and you want to get back existing Tmux session when reconnecting
```sh
tmux attach -t 0
```

## Tools
Here is my ultimate collection of tools to Overclock and Mine over Linux. Download and make it able to run.
```sh
git clone https://github.com/ArSd-g/anytech-mining
cd anytech-mining
chmod +x *.sh && chmod +x amd*
```
#### Atiflash
Ati flash allow you to dump, save and flash bios on AMD cards, you will find them here:[TechpowerUp](https://www.techpowerup.com/vgabios)
```sh
chmod +x amdflash
sudo cp amdflash /usr/bin
sudo amdflash -h
```
Save Bios
```sh
sudo ./amdflash -s 0 CARD-NAME.rom ##Not Working? Use -f flag to force"
```
Flash Bios
```sh
sudo ./amdflash -p 0 CARD-NAME.rom ##Not Working? Use "-f" flag to force"
```
#### HugePages
Set recommended nbr of hugepages to 4096 per numa node.
```sh
sudo nano /proc/sys/vm/nr_hugepages
```
## Overclocking
- Write Power Play Table, in this exemple for GPU number 1 write the content of V56V1PPT (Ethash-Algo Vega56-Pulse-P2-1000Mhz-850Mv/Mem-950Mhz-850Mv).!!reset on every reboot!!
```sh
sudo ./setPPT.sh 1 V56V1PPT
```
- Install amdgpu-clocks to overclock GPU and select P-States; Simply place the script in /usr/bin/amdgpu-clocks:
```sh
sudo cp amdgpu-clocks /usr/bin/
```
Then copy exemple to or save/edit: 
```sh
cp amdgpu-custom-states.card1 /etc/default/
```
If you want your GPU to be overclocked at boot time; place 'amdgpu-clocks.service' in systemd services, remember to edit it to work with your paths/files:
```sh
cp amdgpu-clocks.service /lib/systemd/system/
sudo systemctl enable --now amdgpu-clocks
sudo reboot
```
After reboot check if Overclocking service is ok by:
```sh
sudo systemctl status amdgpu-clocks
```
#### AMD Memory Tweak
```sh
sudo cp amdmemtweak /usr/bin
```
Apply memory strap on AMD Cards to improve hashrates, This is a 'Stock-Bios-Vega56-Pulse-Hynix-Memory' exemple on GPU 0 and 1 for ETHASH:
```sh
sudo ./amdmemtweak --i 0,1 --cl 20 --ras 23 --rcdrd 15 --rcdwr 11 --rc 36 --rp 13 --rrds 3 --rrdl 5 --rtp 6 --faw 12 --cwl 7 --wtrs 4 --wtrl 9 --wr 13 --rfc 248 --REF 65535
```
#### Monitor GPU 
In this exemple it will monitor GPU number 1 and print infos checking every 5s
```sh
sudo ./moniterGPU.sh 5 1
```
## Process Explained
Here is an exemple of my 'amdgpu-clocks.service' and 'oc.sh' and how things work on my machine:
NOTE: As you can see above tools don't use the same way to detect GPU's GPU-1 with 'amdgpuclocks' reading is GPU-0 with amdmemtweak, so beware!

1-System-D calls 'oc.sh' script at every boot which will:  
    a-Write PPT to Linux GPU PPT (make sure that all required files are in the directory you are working in)  
    b-Apply AMD-Memory Timings Straps  
    
2-System-D calls amdgpu-clocks script which will applied: 'amdgpu-custom-states.card1, amdgpu-custom-states.card2...    

/oc.sh
```sh
#!/bin/bash
sudo ./setPPT.sh 1 V56V3PPT
sudo ./setPPT.sh 2 V56V3PPT
sudo ./setPPT.sh 3 V56V3PPT
sudo ./amdmemtweak --i 0,1 --cl 20 --ras 23 --rcdrd 15 --rcdwr 11 --rc 36 --rp 13 --rrds 3 --rrdl 5 --rtp 6 --faw 12 --cwl 7 --wtrs 4 --wtrl 9 --wr 13 --rfc 248 --REF 65535
```
/lib/systemd/system/amdgpu-clocks.service
```sh
GNU nano 4.8
[Unit]
Description=Set custom amdgpu clocks & voltages
After=multi-user.target rc-local.service systemd-user-sessions.service

[Service]
Type=oneshot
WorkingDirectory=/home/username/RainbowMiner
ExecStart=/home/username/RainbowMiner/oc.sh
RemainAfterExit=yes
ExecStart=/usr/bin/amdgpu-clocks
ExecStop=/usr/bin/amdgpu-clocks restore
ExecReload=/usr/bin/amdgpu-clocks
StandardOutput=syslog

[Install]
WantedBy=multi-user.target
```

### You are READY!
Take a deep breath and get ready to configure RainbowMiner

I hope this guide was clear and precise, feel free to contact me for suggestions, questions, corrections or just to say thanks!

### Donate:
```sh
BTC: 3DMFX97J1iz65xJRwyiMNNFFWr9qgn4PP3
LTC: MBeEPQctvNGnFFFsMuJxbLwKMqUBUNHhsN
ETH: 0x2A2Ae71baE7EefFB21B3430e488a55f555cb9430
XMR: 86sXqcNXaq3UBG9oMAfst1fXRLicKWE6QKzecf7eooiCa6iQkBC4SUFKkS8zJ1nCSkCEUGUncgYHG8csZead83wu9LeZAZB
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
- **https://xmrig.com/docs/miner/hugepages**
- **https://anansewaa.com/quick-tips-to-harden-ssh-on-ubuntu/**
- **https://www.itzgeek.com/how-tos/linux/ubuntu-how-tos/how-to-install-ubuntu-18-04-lts-bionic-beaver-on-uefi-and-legacy-bios-system.html**
- **https://www.techpowerup.com**
