# rpp-gw-base-ansible

Ansible script to install and configure the base software on the Rapid Prototyping Platform gateway

Usage:

    ansible-playbook -e '{"version":"\<the script version>\>","new_hostname":"\<the host name\>"}' gateway.yml

Example:

    ansible-playbook -e '{"version":"1.0","new_hostname":"home-blue"}' gateway.yml

The "version" field should contain the result of a "git describe" command. The script "run_gateway.sh" does the whole work so you may just call

    sudo ./run_gateway.sh -i <ip address> -n <host name>

Example:

    sudo ./run_gateway.sh -i raspberrypi.local -n home-blue


The run_gateway script has other options run /run_gateway.sh -h to see those

To run this script you need:

* Ansible
* An RPP gateway with the OS installed (see below) and accessible via SSH and with internet access

You may need to provide the IP Address (or name) of the gateway by editing the file "inventory". The original file comes with "raspberrypi.local" and this should work)

The script:

* Expands the filesystem
* Installs ansible-pull and schedule it to periodically poll the script repository (see below)
* Changes the hostname
* creates and environment variable RPP_BASE_SCRIPT_VERSION with the current script version (if is a command line parameter but should contain the result of 'git describe')

The git repository that ansible pull is configured to poll is git@github.com:acn-iot/node-red-proto-client-ansible.git tag "latest". This can be changed on file ./roles/prepare-ansible-pull/files/run_ansible_pull.sh

The OS is Jessie Lite based modification that includes the drivers and configuration for the TFT display module. It can be found here: https://learn.adafruit.com/adafruit-pitft-28-inch-resistive-touchscreen-display-raspberry-pi/easy-install

#Wi-fi configuration

The base image contains a nice feature that enables a wifi hotspot when the gateway cannot find any network connection (wired or wireless). On this scenario, look for a "RapidPrototypingGateway" wifi network using your laptop. Connect using the password "aaaaa11111" and open a browser at http://10.0.0.200:8080 to configure an existing SSID/Key. Reboot the gateway and it will connect to the configured wifi network.

#RaspberryPi 2 with Edimax Wifi Dongle

There is a special case if you are running this script to create an SD card for a Raspberry Pi 2 with an EDIMAX wifi dongle. In this case we need to replace the *hostapd* application with another version that works on this conditions. For this you need to add a "isRPi2":"True" in the extra variable brackets on the ansible scripts. 
