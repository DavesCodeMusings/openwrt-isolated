# Serving Files from the OpenWrt Raspberry Pi Zero
The Raspberry Pi Zero relies on a microSD card for its file storage. OpenWrt only uses a small fraction of the available storage space (less than 200 Megabytes.) With a typical Raspberry Pi microSD size of 32 Gigabytes or more, there is a lot of storage space left unused.

The steps below will show you how we can make that extra space available for users to download files via the same web server OpenWrt uses for its web-based administrative tool. Everything is made more complicated by the fact our OpenWrt Pi has no internet connection, and that is the reason for these instructions.

## Prerequisites:
* Create the OpenWrt access point as directed in _Raspberry Pi Zero W as an Isolated WiFi Access Point_
* Set up the SFTP server in _Improving the OpenWrt Isolated Network Experience_
* You'll also need a laptop with internet access and a microSD card slot.
* And, of course, you need the ability to log into OpenWrt via a command prompt.

## Warning!
Do not use the expanded space to store anything critical. MicroSD cards are low-end storage devices prone to corruption and data loss. Future OpenWrt upgrades may erase part or all of the microSD card. Either of these situation could leave you crying over your lost files. Always keep a second copy of anything you don't want to lose.

## Previewing the Required Steps
At a high level, this is what we'll need to do to serve files:
1. Use _fdisk_ or _cfdisk_ to create a new partition.
2. Format the partition with an _ext4_ filesystem.
3. Mount the filesystem on the _/srv_ directory.
4. Organize things by making a directory called _/srv/files_. 
5. Create a link from the _/www_ directory to the new files directory.
6. Ensure all of this still works after a reboot of the system.

## Downloading Necessary Packages
Being a minimalist Linux system, OpenWrt does not expect you to be partitioning storage and does not include _fdisk_ or _cfdisk_ in its default set of tools. We'll need to use a combination of an internet connected laptop, the SFTP server, and the _opkg_ command to get things installed.

1. Review the steps in _Improving the OpenWrt Isolated Network Experience_, paying close attention to the sections for determining package sources and downloading packages.
2. Use the internet connected laptop to find and download packages listed below.
   * cfdisk
   * fdisk
   * libfdisk1
   * libmount1
   * libncurses6
   * terminfo
3. Use _sftp_ on the laptop to transfer these packages to the OpenWrt Raspberry Pi.

## Installing Packages
Some of the packages rely on other packages being installed first. For example, _libncurses6_ expects _terminfo_ to be there or it's going to give an error. This is called "package dependency". What it means to you is you must install things in the correct order or it's not going to work.

1. Access the OpenWrt command prompt with a monitor and keyboard or serial connection.
2. Change directory to wherever you uploaded the package files (e.g. /boot)
3. Use _opkg_ to install the packages in the order shown below to account for dependencies.
   * terminfo
   * libncurses6, libfdisk1, libmount1
   * cfdisk, fdisk

## Viewing Partition Information on the MicroSD Card
The _fdisk_ command can be used with the _-l_ option to display partition information.

1. Access the OpenWrt command prompt.
2. Run `fdisk -l /dev/mmcblk0` to see the microSD card's current partition configuration.
3. Verify it looks similar to the example of a 32G microSD shown below.

```
root@OpenWrt:~# fdisk -l /dev/mmcblk0
Disk /dev/mmcblk0: 29.72 GiB, 31914983424 bytes, 62333952 sectors
Device         Boot  Start      End  Sectors  Size Id Type
/dev/mmcblk0p1 *      8192   139263   131072   64M  c W95 FAT32 (LBA)
/dev/mmcblk0p2      147456   360447   212992  104M 83 Linux
```

> Note: some lines have been removed for brevity.

## Creating a New Partition on the MicroSD Card
Expert users can use fdisk to create partitions as well as view them, but cfdisk provides a more friendly interface.

1. At the OpenWrt command prompt, run `cfdisk /dev/mmcblk0`
2. Use the down arrow key to move to the last row of _Free space_.
3. Select _New_ and press ENTER.
4. Press ENTER to accept the proposed _partition size_.
5. Choose a _primary_ partition.
6. If everything looks good, choose _Write_. Otherwise, choose _Quit_ and try again.

> Note: Be sure to type out "yes" and not just enter "y" to confirm writing.

## Creating a File System on the New Partition
The partition will be formatted with an ext4 file system, since this is the standard used by most Linux distributions, including OpenWrt.

1. At the OpenWrt command prompt, repeat the command `fdisk -l /dev/mmcblk0` to show the new partition configuration.
2. Verify _/dev/mmcblk0p3_ appears in the command output. This is the new partition.
3. Create an _Ext4_ filesystem on _/dev/mmcblk0p3_ with the command `mkfs.ext4 /dev/mmcblk0p3`
4. Wait for formatting to finish.

## Adding the New File System to the File System Table (/etc/fstab)
_/etc/fstab_ is where Linux systems record information about which file systems go where. Expert users can edit the file with a tool like _vi_. However in this example, we'll simply append a line with the new information.

1. At the OpenWrt command prompt, change to the _/etc_ directory with the command `cd /etc`
2. Show the contents of the current _fstab_ using `cat fstab`
3. Add a new line to mount the new file system on the _/srv_ directory. The command is shown below.

```
echo "/dev/mmcblk0p3  /srv  ext4  defaults,noatime  0  0" >> /etc/fstab
```

> Note:
> If you installed the _nano_ editor in the previous document's steps, you can use the command `nano /etc/fstab` to make the changes. Just add the text between the quotes above as the last line of the file.

## Create the /srv Directory and Mount the New File System
The _/srv_ directory is the standard place for Linux systems to store data served by the system and that's what we've specified in _fstab_. But, since OpenWrt is intended to be a wireless access point and not a file server, we'll need to create the directory before we can use it.

1. Create the _/srv_ directory with the command `mkdir /srv`
2. Make the new storage availble under _/srv_ with the command `mount /srv`
3. Check the contents of _/srv_ using `ls /srv`
4. See how much space is available to us with `df -h /srv`

Notice the directory is empty (except for the system created _lost+found_) and nearly all of the microSD card capacity is available for use.

## Uploading Some Files with SFTP
We can create a directory, _/srv/files_, as a place to store important files, including [cat pictures](https://upload.wikimedia.org/wikipedia/commons/1/1a/Cat_crying_%28Lolcat%29.jpg) from Wikipedia.

1. Connect the laptop to the OpenWrt wifi and use sftp to connect.
2. Create a _files_ directory using the _sftp_ command `mkdir /srv/files`
3. Change directory to _/srv/files_ with the _sftp_ command `cd /srv/files`
4. Upload your important files and cat pictures.
5. Use the OpenWrt command prompt to run `ls /srv/files`
6. Verify the uploaded files are there.

## Sharing Files Using the Web Server
1. With the laptop still connected to the OpenWrt wifi, open a browser and go to [http://openwrt.lan/files](http://openwrt.lan/files)
2. Notice the _Not Found_ message.
3. From the OpenWrt command prompt, create a link to the _files_ directory inside the web server directory. Use the commands shown below. 

```
cd /www
ln -s /srv/files files
```

Refresh the browser to see the available files.

## Exploring What Happens After Reboot
If you reboot the OpenWrt system you'll no longer have access to the files we've shared. They're not gone, they're just inaccessible.

1. At the OpenWrt command prompt, note the files in _/srv_ by using the command `ls /srv`
2. Reboot the system with the command `reboot`
3. Log in again and repeat the `ls /srv` command.
4. Notice the directory is empty.

## Making the File Available Again
In a previous step, we used `mount /srv` to make the contents of _/dev/mmcblk0p3_ available under the _/srv_ directory. We were able to use the command `mount /srv`, because _/etc/fstab_ has the entry we created to associate _/dev/mmcblk0p3_ with _/srv_. We could have used the command `mount /dev/mmcblk0p3` to get the same result, and that is what we'll do here. But first, we will run a check of the file system.

1. Check the file system health with the command `e2fsck -p /dev/mmcblk0p3`
2. Verify the command's response says _/dev/mmcblk0p3: clean_
3. Mount _/dev/mmcblk0p3_ on _/srv_

## Automating File System Check and Mount
Running the previous steps everytime the system is rebooted will quickly become tedious. We can automate this process by adding the commands to a file called _/etc/rc.local_ (rc stands for "run commands" and local means it is not part of the original operating system installation.)

1. From the OpenWrt command prompt, change to the _/etc_ directory using the command `cd /etc`
2. Show the contents of _rc.local_ with the command `cat rc.local`
3. Notice the last line of _exit 0_. If we add our commands after this, they won't run, because _exit 0_ terminates processing.
4. Replace _exit 0_ (and the rest of the file) with our _e2fsck_ and _mount_ commands using the command shown below.

```
echo "e2fsck -p /dev/mmcblk0p3 && mount /dev/mmcblk0p3" > /etc/rc.local
```

This will execute both commands, but the double ampersand (&&) ensures the _mount_ command will only run if the _e2fsck_ command reports the filesystem is clean.

> Note:
> If you're not keen on editing files from the command prompt, /etc/rc.local can be edited in the web administration tool. Just navigate to _System_ > _Startup_ and select the _Local Startup_ tab.

## Final Testing
1. Reboot the system one more time.
2. Try to access shared files by visiting [http://openwrt.lan/files](http://openwrt.lan/files) in a browser on the laptop.
3. If you don't see the files, review the previous steps to find the cause.
   * Is _/srv_ mounted after reboot?
   * Does _e2fsck_ report the file system is clean?
   * Is there a link to _/srv/files_ in the _/www_ directory?
   * Is your laptop using the OpenWrt access point connection?
