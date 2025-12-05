# Using a Raspberry Pi Zero W as an Isolated WiFi Access Point
The Raspberry Pi Zero W is an inexpensive device that can serve as a WiFi access point with a software package called OpenWrt. It's not going to win any awards for long range connections, but it's good enough to connect multiple devices in a learning lab environment.

The problem with the Pi Zero W is that it lacks a wired Ethernet connection, so normal OpenWrt configuration using the web-based administration tool is not possible at first. But, with a little typing, we can use the command prompt to get WiFi up and running. The steps below show how to do just that.

> Note:
> The instructions here are written to not only get an end result, but to hopefully understand some things in the process. As such, they sometimes takes a roundabout way of getting to the answers.

## Prerequisites:
* You'll need a laptop with internet access and a Micro SD card slot.
* You'll also need to install the [Raspberry Pi Imager](https://www.raspberrypi.com/software/).
* Previous experience working with Raspberry Pis is a plus.

## Locate the Raspberry Pi Zero W on OpenWrt's web site
1. Visit the OpenWrt table of hardware at: https://openwrt.org/toh
2. Enter "Raspberry Pi" in the _Brand_ search box.
3. Scroll to the row for _Raspberry Pi Zero W_  and click on the link under the _Device Page_ column.

## Download the firmware image from the Raspberry Pi Zero W's device page
1. On the [OpenWrt Raspberry Pi device page](https://openwrt.org/toh/raspberry_pi_foundation/raspberry_pi), scroll down to the heading for _Installation_
2. Locate the column with a Model of _Raspberry Pi_ and a Version of _Zero W_
3. Find the row for _Firmware OpenWrt Install URL_
4. Click the link to download _Factory Image_

## Write the downloaded OpenWrt firmware image to the Micro SD card
1. Insert the Micro SD into the laptop, using an adapter if needed.
2. Run the Raspberry Pi Imager.
3. Choose _Raspberry Pi Zero_ as the device.
4. Choose _Use Custom_ as the Operating System (OS).
5. Select the OpenWrt firmware image file that was downloaded in the previous section.
6. Select the Micro SD card device (there should be only one choice.)
7. Write the image to the Micro SD.

## Boot the Raspberry Pi Zero from the Micro SD card
1. Attach a monitor and keyboard (or USB-serial adapter) to the Raspberry Pi Zero.
2. Remove the Micro SD card from the laptop and insert into the Pi Zero.
3. Connect power to the Pi Zero.
4. Watch the boot messages fly by on the screen.

## Log into OpenWrt on the Pi Zero
1. Wait for the boot messages to stop scrolling.
2. Press ENTER once.
3. Verify you see a command prompt (root@OpenWrt:~#).

## Explore the current (sad) state of the WiFi access point
1. At the command prompt, type: `ifconfig` to see the current state of the device's network interfaces.
2. Notice only the "lo" (loopback) device is shown. No WiFi device exists.
3. Type: `uci show network` to see what the desired state is.

## Determine steps to manually configure the WiFi
1. On a device with internet access, open the site: https://duck.ai
2. Type in a prompt of: "Configure openwrt wireless using uci commands"
3. Scroll through the results, paying attention to the _Example Configuration_
4. Type in another prompt of: "Explain the example configuration"

## Compare the AI generated configuration to the Raspberry Pi Zero's current configuration
1. Run the following command at the OpenWrt command prompt: `uci show wireless`
2. Compare the command output to the AI output, noting similarities and differences.
3. Make a mental plan on which parameters will be needed for WiFi on the Pi Zero.

## Set up a WiFi access point on the Pi Zero by typing the UCI commands shown below:
```
uci set wireless.default_radio0.ssid='PiLab'
uci set wireless.default_radio0.key='P@ssw0rd'
uci set wireless.default_radio0.encryption='psk2'
uci set wireless.radio0.disabled='0'
```

## Review the changes before activating
1. Run the command to show the WiFi configuration: `uci show wireless`
2. Compare the output to the previous run of the same command.
3. Note the changes and review the AI explanation of the parameters.

## Active the new WiFi configuration
1. Save the configuration with the command: `uci commit wireless`
2. Activete the new configuration with the command: `wifi reload`
3. Watch the status messages, looking for a line containing _entered forwarding state_
4. Press ENTER to get the prompt back.


## Verify the new configuration using UCI commands
1. Repeat the `ifconfig` command.
2. Compare to the previous output.
3. Notice the new devices: _br-lan_ and _phy0-ap0_. Together, these represent the WiFi access point.

## Connect to the Raspberry Pi Zero access point
1. Use a laptop or Chromebook to browse available WiFi networks.
2. Connect to the _PiLab_ network.
3. Use a password of _P@ssw0rd_ (or whatever you configured.)
4. Note how the laptop complains about no internet access. This is by design.

## Access the OpenWrt web-based configuration tool
1. Using the device attached to the _PiLab_ network, open a web browser for: http://192.168.1.1
2. Do not enter a password.
3. Click the _Log in_ button.
4. Notice the message about _No password set!_
5. Click the _Go to password configuration_ button to set a password.
6. Log out and test the new password by logging in again.

## Continue testing by inviting others to attach to your Raspberry Pi Zero access point
1. Have a contest to see how far away you can be and still see more than "zero bars" of signal strength.
2. Find out how many people can connect at the same time before connections start getting dropped.
3. Log into the web-based administration tool again (http://192.168.1.1) and scroll down to observe _Active DHCP Leases_ and _Associated Stations_ as others are connecting.
