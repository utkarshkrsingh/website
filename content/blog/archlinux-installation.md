+++
title = "Archlinux Installation : A Beginner's Guide"
date = 2024-10-06T00:37:01+05:30
draft = false
+++

So, you're thinking about installing Arch Linux on your laptop? That’s awesome! Whether you’re diving into Arch Linux for its flexibility, minimalism, or just for the pure challenge (because, let’s face it, we Linux users love a challenge 😄), you’ve come to the right place.

In this guide, I’ll walk you through the entire process of installing Arch Linux on your laptop—step by step. And don’t worry, I’ve got screenshots and clear instructions to help you every step of the way.

Ready? Let’s get started!

## Why Arch Linux?
Before we dive into the technical stuff, let me tell you why people _love_ Arch Linux:
- **Control**: You get to decide every little thing that goes into your system. No bloatware, just what you want.
- **Learning**: Arch Linux doesn’t hold your hand, but that’s the beauty of it. It helps you learn so much about how Linux really works.
- **Rolling release**: You’re always up to date with the latest and greatest software versions.

If that excites you, then keep reading—we’re about to set up Arch Linux on your laptop!

## What You’ll Need Before We Start 
Before we jump into the installation, here’s a quick checklist of what you’ll need to ensure everything goes smoothly:

- **A Laptop (obviously! 😄)** – Make sure it’s compatible with Linux (most modern laptops are).
- **Stable Internet Connection** – You’ll need it to download the Arch Linux base system during installation.
- **A USB Drive (2GB or more)** – I'm assuming that your have already created a bootable usb drive using arch-iso.
- **Backup Your Data** – If you already have an operating system on your laptop and you want to replace it with Arch, please make sure to back up any important files. We’ll be wiping your disk!

Got all that ready? Awesome! Let’s move on.

## Step 1: Boot from the USB Drive

Alright, now we’re getting to the fun part! It’s time to boot your laptop from the USB (that I'm assuming, you have already created).

- Insert the USB drive into your laptop.
- Restart your laptop, and immediately start pressing the key to access the boot menu (this varies by manufacturer; common keys are F2, F12, ESC, or DEL).
- From the boot menu, select your USB drive.

Once you do this, you’ll be greeted with the Arch Linux boot menu. 🎉 Select the default option, and press Enter.

**Take a deep breath 😌—you’re about to enter the world of Arch Linux installation!** 

## Step 2: Connect to the Internet
Now that we’re booted into the Arch environment, the first thing we’ll want to do is connect to the internet. If you’re using an Ethernet cable, you should already be connected (lucky you!). But if you’re using Wi-Fi, let’s get connected.
- Type `iwctl` and press **Enter**.
- Then run the following commands:
```bash
device list     # in most casses its `wlan0`
```
![arch-install03.jpg](https://i.postimg.cc/rscQjMvK/arch-install03.jpg)
```
<device> list
```
![arch-install04.jpg](https://i.postimg.cc/HsY67WwN/arch-install04.jpg)
```
station <device> connect <your-network-name>
```
![arch-install05.jpg](https://i.postimg.cc/9FLJP31Q/arch-install05.jpg)
- Enter your Wi-Fi password when prompted.

To check if you’re connected, you can ping a website:
```bash
ping utkarsh.is-a.dev
```
![arch-install06.jpg](https://i.postimg.cc/BvKpGj3j/arch-install06.jpg)
If you see responses, you’re good to go!

## Step 3: Update Archlinux-keyrings
Before we start, we need to update the `archlinux-keyring` of the iso you are using. The `archlinux-keyring` is essential for verifying the authenticity of Arch Linux packages.
```bash
pacman -Sy archlinux-keyring
```

![arch-install07.png](https://i.postimg.cc/c4kBgR4K/arch-install07.png)

## Step 4: Partition the Disk
Now, let’s partition your hard drive. This part is where we divide your disk into separate sections for Arch to live on. You can use either `cfdisk` or `fdisk`—I’ll use `cfdisk` because it’s a bit more user-friendly.

- First run the command `lsblk` to see what are the drive available to you.

![arch-install07-1.png](https://i.postimg.cc/RZ8d8ckr/arch-install07-1.png)
In my case it's `sda`, if you have `nvme0n1` on your screen, then this is what you are looking for. Remenber `sdb` is the usb you are using to boot in. Don't use it as your main disk.

- Now that we got our partner we can go forward. Use the following command to use `cfdisk` to partition your disk.
```bash
cfdisk /dev/sda             # if you have nvme0n1, replace sda with it
```
![arch-install07-2.png](https://i.postimg.cc/63x06B6Y/arch-install07-2.png)

- Now select the `free space` you have on your disk and select `new` on bottom left, then press **Enter** .

![arch-install07-3.png](https://i.postimg.cc/9MPBrsrV/arch-install07-3.png)

- Now, it will ask for how much space will this new partition will have. For this we will select `2G` i.e., 2 Gigabytes only for `UEFI` partition.

![arch-install07-4.png](https://i.postimg.cc/x803Hgzm/arch-install07-4.png)

- Then press **Enter** and select `Type` and again press **Enter**.
- In that menu, scroll up and select `UEFI System` and press **Enter**.

![arch-install07-5.png](https://i.postimg.cc/cCXMcYRb/arch-install07-5.png)

- Now you will get some `free space` and a `UEFI System` partition of 2 Gigabytes.
- Again select the `free space` and press **Enter**.
- This time leave the value it have, and press **Enter**.
- You will see a new partition of type `Linux filesystem`. That's good.
- Then select `write`, write yes and press **Enter**.

![arch-install07-6.png](https://i.postimg.cc/gcDDd9CH/arch-install07-6.png)

- Now quit.
- Run the command `lsblk` again, and you will see that now there is 2 more partitions under `sda` or `nvme0n1`.
```bash
lsblk
```

## Step 5: Format the Partitions
Next, we’ll format the partitions to prepare them for use.

For the root partition (aka the bigger one):
```bash
mkfs.ext4 /dev/sda2 # or mount /dev/nvme0n1pX (for those who have nvme0n1, replace X with the respective number)
```

![arch-install07-7.png](https://i.postimg.cc/sDgJg6yd/arch-install07-7.png)

For the EFI partition (if applicable):
```bash
mkfs.fat -F32 /dev/sda1 # or mount /dev/nvme0n1pY (for those who have nvme0n1, replace Y with the respective number)
```

![arch-install08.png](https://i.postimg.cc/rwdCSDKf/arch-install08.png)

## Step 5: Mount the Partitions 
Now we’ll mount the partitions so we can install Arch Linux onto them.

Mount the root partition:
```bash
mount /dev/sda2 /mnt # or mount /dev/nvme0n1pX /mnt (mount the bigger one to /mnt)
```

![arch-install09.png](https://i.postimg.cc/7Zp1Xqzw/arch-install09.png)

To check whether the mounting is correct or not again run `lsblk` command.

![arch-install10.png](https://i.postimg.cc/g08VT1yR/arch-install10.png)

If you have an EFI partition:
```bash
mkdir /mnt/boot # first create the boot directory in /mnt
mount /dev/sda1 /mnt/boot # then mount the EFI partition to /mnt/boot
```

![arch-install12.png](https://i.postimg.cc/rm9S8WPw/arch-install12.png)
![arch-install13.png](https://i.postimg.cc/Wzb0t3B6/arch-install13.png)

## Step 6: Install the Base System 
Now that our partitions are set up and mounted, it’s time to install the base system. This is where the magic happens! We’ll be using the `pacstrap` command to install the essential packages.

Run the following command:
```bash
pacstrap -i /mnt base base-devel linux-zen linux-firmware sof-firmware intel-ucode sudo nano bluez bluez-utils networkmanager
```

![arch-install14.png](https://i.postimg.cc/BbYHF3sW/arch-install14.png)

If it asks to select some package, just press **Enter** and use the default one. 

![arch-install15.png](https://i.postimg.cc/G3qkVFDM/arch-install15.png)

This command installs the base Arch Linux system, along with the Linux kernel and firmware necessary for your hardware.

## Step 7: Generate fstab
Next, we need to create the filesystem table (fstab), which helps the system know how to mount the partitions during boot.
```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

This command generates the fstab file automatically based on your partitions.

## Step 8: Chroot into the System
We’re almost there! Now, we need to change the root directory to the new system we just installed.

Run:
```bash
arch-chroot /mnt
```

You’ll now be inside your newly installed Arch environment! 🎉

![arch-install20.png](https://i.postimg.cc/SKF8CD0K/arch-install20.png)
The path will be changed, if you are inside the installed arch environment.

## Step 9: Create Root Password 
Now that you entered the environment you need to create a root password.
Run:
```bash
passwd 
```
![arch-install21.png](https://i.postimg.cc/k5QScK9v/arch-install21.png)

## Step 10: Create Username and Password
Now we need to create a user and it's password just like we do on windows.
Run:
```bash
useradd -m -g users -G wheel,storage,power,video,audio -s /bin/bash utkarsh # replace "urkarsh" with your Username
```
To create it's password, run:
```bash
passwd utkarsh # again replace utkarsh with your Username
```

## Step 11: Give the User Powers
In this step we will give the user (i.e. you) administrative powers. Sounds cool nah 👻.
Run:
```bash
EDITOR=nano visudo
```
Uncomment the following line (by removing '#'):
![arch-install25.png](https://i.postimg.cc/05Wwc8gF/arch-install25.png)
And save by pressing `Ctrl-o` and **Enter**  and again `Ctrl-x`.

## Step 12: Set the Time Zone and Localization
Now let’s configure your time zone. This is important to make sure your clock is set correctly.
- Set your time zone by creating a symbolic link. For example, if you're in India:
```bash
ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
```
Replace Asia/Kolkata with your relevant time zone. You can find it in [ArchWiki](https://wiki.archlinux.org/title/Main_page).

- Run:
```bash
hclock --systohc
```
Next, we’ll set the localization. This ensures your system uses the correct language and settings.

- Open the locale.gen file:
```bash
nano /etc/locale.gen 
```
Uncomment `en_US.UTF-8 UTF-8` and any other locales you want to use by removing the # at the start of the line.
![arch-install34.png](https://i.postimg.cc/1tWfCKdw/arch-install34.png)
To save press `Ctrl-o` and press **Enter** and to exit press `Ctrl-x`.

- Generate the locales:
```bash
locale-gen
```

- Set the `LANG` variable:
```bash
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
```

## Step 13: Set Hostname and Localdomain
Let’s set up your hostname! This is the name your laptop will use on the network.

Run:
```bash
echo "archlinux" >> /etc/hostname # replace "archlinux" as your choice
```

For localdomain run:
```bash
echo "127.0.0.1      localdomain" >> /etc/hosts
echo "::1            localdomain" >> /etc/hosts
echo "127.0.1.1      archlinux.localdomain      archlinux" >> /etc/hosts # replace "archlinux" with your Hostname
```

## Step 14: Install and Configure the Bootloader
We’re almost done! Now, let’s install the bootloader so you can boot into your new Arch Linux system.
- First install `grub`, `efibootmgr`, `dosfstools` and `mtools`
```bash
pacman -S grub efibootmgr dosfstools mtools
```

- For UEFI systems, run:
```bash
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

## Step 15: Installing Desktop Manager
A desktop manager must be installed for the GUI (Graphical User Interface) to function. One of the most well-known characters is Gnome.

Run:
```bash
pacman -S gnome 
```

## Step 16: Sound Systems 
To enable sound control in archlinux, we need to install `pipewire` and dependencies related to it. Let's install it.

Run:
```bash
pacman -S pipewire pipewire-alsa pipewire-pulse wireplumber
systemctl --user --now enable pipewire pipewire-pulse wireplumber
```

## Step 17: Enabling Service 
Now that we are done with installation, we need to start the networkmanager and bluetooth services.

Run:
```bash
systemctl enable bluetooth && systemctl enable NetworkManager # "NetworkManager" not "networkmanger" for enabling it 
systemctl enable gdm
```

## Step 18: Unmount & Reboot
Now that installation is completely over, we need to carefully umount the drives.

Run:
```bash
exit # to come out of Chroot
umount -lR /mnt
reboot 
```

![arch-install47.png](https://i.postimg.cc/59TtXjW4/arch-install47.png)

Bravo, welcome to archlinux.

## Conclusion
Congratulations! 🎉 You’ve successfully installed Arch Linux on your laptop! When your laptop boots up, you should see the GRUB menu. Select Arch Linux, and you’ll be taken to the login prompt. If you encountered any issues or have questions, feel free to ask them. Happy computing, and welcome to the Arch community! 😊
