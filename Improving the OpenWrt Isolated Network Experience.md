# Improving the OpenWrt Isolated Network Experience
Because this OpenWrt access point does not connect to the internet, there is no way to use the `opkg` tool to download and install add-on packages. But, `opkg` accounts for this by allowing us to install from files. The trick is getting the files.

To accomodate this disconnected network situation, we wll install a Secure File Transfer Protocol (SFTP) server on the OpenWrt Raspberry Pi. This will allow us to download package files to an internet connected laptop and then upload, via SFTP, to the OpenWrt Pi.

In the steps below, we will first get the SFTP server installed. Then, we'll install another package using the disconnected package download method with SFTP.

> Note:
> The instructions here are written to not only get you an end result, but to hopefully understand some things in the process. As such, they sometimes takes a roundabout way of getting to the answers.

## Prerequisites:
* You'll need a laptop with internet access and a microSD card slot.
* You will also need the ability to log into OpenWrt via a command prompt (monitor and keyboard or serial connection.)

## Determine Your OpenWrt Package Source
1. Log into the OpenWrt command prompt as root.
2. Change to the package manager configuration directory by typing `cd /etc/opkg`
3. List the files there by typing `ls`
4. Look for a file named _distfeeds.conf_
5. Show the contents of the file by typing `cat distfeeds.conf`
6. Note the URLs that start with _https://_

## Download the SFTP Server Package
1. In the distfeeds.conf file above, look for a URL that ends in _/packages_
2. On a laptop with internet access, enter the URL into the web browser address bar.
2. Scroll down the page until you see a link that starts with _openssh-sftp-server_
3. Follow the link for _openssh-sftp-server_
4. Check your Downloads folder for the file starting with _openssh-sftp-server_ and ending with _.ipk_

## Copy the Package to the MicroSD Card
1. Log into OpenWrt as root and type: `poweroff`
2. Wait for the LEDs to go out and unplug the Raspberry Pi.
3. Remove the microSD card from the Pi.
4. Insert the microSD into the laptop, using an adpter if needed.
5. Copy the downloaded _openssh-sftp-server_XXX.ipk_ file to the microSD card.
6. Eject and remove the microSD when the copy is finished.

## Locating the SFTP Server Package
1. Insert the microSD card into the Raspberry Pi and power up the Pi.
2. Log into OpenWrt as root.
3. Change to the _boot_ directory by typing `cd /boot`
4. List the files there using the command `ls`
5. Look for a file name similar to _openssh-sftp-server_XXX.ipk_

## Installing the SFTP Server Package
1. From the /boot directory, begin typing the command `opkg ./openssh-sftp-server`
2. Press the TAB key to auto-complete the file name.
3. Press ENTER to confirm the installation.
4. Watch for messages about installing and configuring.

## Testing the SFTP Server
1. From the laptop, connect to the OpenWrt access point.
2. Open a command prompt on the laptop.
3. Use the laptop's sftp program to connect to the OpenWrt SFTP server as the root user and browse the _/boot_ directory. (See example below.)

```
PS C:\> sftp root@openwrt
root@openwrt's password:
Connected to openwrt.
sftp>
sftp> cd /boot
sftp> ls
COPYING.linux                                               LICENCE.broadcom
System Volume Information                                   bcm2708-rpi-b-plus.dtb
bcm2708-rpi-b-rev1.dtb                                      bcm2708-rpi-b.dtb
bcm2708-rpi-cm.dtb                                          bcm2708-rpi-zero-w.dtb
bcm2708-rpi-zero.dtb                                        bootcode.bin
cmdline.txt                                                 config.txt
distroconfig.txt                                            fixup.dat
fixup_cd.dat                                                fixup_x.dat
kernel.img                                                  openssh-sftp-server_9.9_p2-r1_arm_arm1176jzf-s_vfp.ipk
overlays                                                    partuuid.txt
start.elf                                                   start_cd.elf
start_x.elf
sftp>
```

If you see the _sftp>_ prompt, and you can change to the _boot_ directory to list files, everything's working as it should. Notice the openssh-sftp-server package file we copied onto the microSD card previously.

## Fetching a Package for the Isolated Environment
1. Log into the OpenWrt command prompt as root.
2. Review the package URLs by running the command to display _distfeeds.conf_ `cat /etc/opkg/distfeeds.conf`
3. Find the URL that ends in _/luci_ (Luci is the name of the web administration tool.)
4. Visit the luci URL in a browser on the internet connected laptop.
5. Scroll down until you see the link similar to _luci-mod-dashboard_XXX_all.ipk_ (where XXX represents a version number.)
6. Follow the link to download the file.

## Transferring the Package File to OpenWrt
1. Connect the laptop's wifi to the OpenWrt access point.
2. On the laptop, open a command prompt and change directory to your Downloads folder.
3. Connect to the OpenWrt sftp server with the command `sftp root@openwrt`
4. Change directory to _/boot_ using `cd /boot`
5. Transfer the luci dashboard package with `mput luci-mod-dashboard*`
6. Doublecheck the file with `ls /boot/luci*` (This command works from both sftp and from the administrative command prompt.)

## Installing the Package File
1. Log into the OpenWrt command prompt as root.
2. Change directory to _/boot_ (`cd /boot`)
3. Begin typing the command to install the package `opkg ./luci-mod`
4. Press TAB to auto-complete the file name.
5. Press ENTER to confirm the installation.

## Checking the Result
1. Connect the laptop to the OpenWrt access point.
2. Open a web browser and navigate to _http://openwrt_
3. Verify the dashboard appears in the browser.
