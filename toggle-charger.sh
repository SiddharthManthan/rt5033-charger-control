#!/bin/sh

# This is a simple script to turn charger supply on or off on 
# device Samsung Fortuna3g. It talks to the RT5033 MFD on i2c bus 4
# at address $address.

# I2C Address
bus=4
address=0x34

# Registers
RT5033_CHG_STAT_CTRL=0x00
RT5033_CHG_CTRL1=0x01
RT5033_CHG_CTRL3=0x04
RT5033_CHG_CTRL4=0x05
RT5033_EOC_CTRL=0x07

# Battery Monitoring
min_battery=40
max_battery=75
# Replace BATTERY variable with the actual battery device
# found under sysfs
BATTERY="rt5033-battery"

bailout() {
	echo "Usage: $0 off|on|auto"
	exit 1
}

i2c_assign_bits() {
	bus=$1
	address=$2
	reg=$3
	mask=$4
	data=$5

	value=$(i2cget -y $bus $address $reg)

	# Quit if i2cget failed :
	test "$?" != 0 && exit 1

	value=`printf "0x%x" $((value & ~mask))`
	value=`printf "0x%x" $((value | data))`

	i2cset -y $bus $address $reg $value
	# Quit if i2cset failed :
	test "$?" != 0 && exit 1
}

enable_charger() {
	# # Disable high Impedance Mode
	i2c_assign_bits $bus $address $RT5033_CHG_CTRL1 0x02 0x00

	# Enable Charger
	i2c_assign_bits $bus $address $RT5033_CHG_STAT_CTRL 0x01 0x00

	logger "turned charger on"
}

disable_charger() {
	# Disable Charger
	i2c_assign_bits $bus $address $RT5033_CHG_STAT_CTRL 0x01 0x01

	logger "turned charger off"
}

auto() {
	if [ ! -d /sys/class/power_supply/"$BATTERY" ]; then {
		bailout;
	} fi

	CAPACITY="$(cat /sys/class/power_supply/${BATTERY}/capacity)"
	if [ "$CAPACITY" -lt "$min_battery" ]; then {
		enable_charger
	} elif [ "$CAPACITY" -gt "$max_battery" ]; then {
		disable_charger
	} fi
}

test "$#" != 1 && bailout
test "$1" != "on" && test "$1" != "off" && test "$1" != "auto" && bailout

if test "$1" == "on"; then {
	enable_charger
} elif test "$1" == "off"; then {
	disable_charger
} elif test "$1" == "auto"; then {
	auto
} fi
