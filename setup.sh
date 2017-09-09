
#!/bin/bash
# file: setup_i2c.sh
#
# This script will enable I2C and install i2c-tools on your Raspberry Pi 
#
#TODO: convert to ansible, manage lifecycle remotely

# check if sudo is used
if [ "$(id -u)" != 0 ]; then
  echo 'Sorry, you need to run this script with sudo'
  exit 1
fi

# enable I2C on Raspberry Pi
echo '>>> Enable I2C'
if grep -q 'i2c-bcm2708' /etc/modules; then
  echo 'Seems i2c-bcm2708 module already exists, skip this step.'
else
  echo 'i2c-bcm2708' >> /etc/modules
fi
if grep -q 'i2c-dev' /etc/modules; then
  echo 'Seems i2c-dev module already exists, skip this step.'
else
  echo 'i2c-dev' >> /etc/modules
fi
if grep -q 'dtparam=i2c1=on' /boot/config.txt; then
  echo 'Seems i2c1 parameter already set, skip this step.'
else
  echo 'dtparam=i2c1=on' >> /boot/config.txt
fi
if grep -q 'dtparam=i2c_arm=on' /boot/config.txt; then
  echo 'Seems i2c_arm parameter already set, skip this step.'
else
  echo 'dtparam=i2c_arm=on' >> /boot/config.txt
fi
if [ -f /etc/modprobe.d/raspi-blacklist.conf ]; then
  sed -i 's/^blacklist spi-bcm2708/#blacklist spi-bcm2708/' /etc/modprobe.d/raspi-blacklist.conf
  sed -i 's/^blacklist i2c-bcm2708/#blacklist i2c-bcm2708/' /etc/modprobe.d/raspi-blacklist.conf
else
  echo 'File raspi-blacklist.conf does not exist, skip this step.'
fi

# install i2c-tools
echo '>>> Install i2c-tools'
apt-get install -y i2c-tools python-smb tmux git

echo "setting flag in i2c_bcm..."
if grep -q 'For Pi-16ADC' /etc/rc.local; then
  echo 'already set flag.'
else
  echo 'echo -n 1 > /sys/module/i2c_bcm2708/parameters/combined' > /etc/rc.local
  echo 'exit 0' >> /etc/rc.local
fi

shutdown -r now
