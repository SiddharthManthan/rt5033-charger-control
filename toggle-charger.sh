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

bailout() {
	echo "Usage: $0 off|on"
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

test "$#" != 1 && bailout
test "$1" != "on" && test "$1" != "off" && bailout

if test "$1" == "on"; then {
	# # Disable high Impedance Mode
	i2c_assign_bits $bus $address $RT5033_CHG_CTRL1 0x02 0x00
	
	# # Set COF_EN_MASK
	# # Verify if this is really necessary
	# # i2c_assign_bits $bus $address $RT5033_CHG_CTRL3 $RT5033_COF_EN_MASK 0x01

	# # Disable Internal Timer. Maybe max amount of time charger will be enabled
	# # Verify if this is really necessary
	# i2c_assign_bits $bus $address $RT5033_CHG_CTRL3 $RT5033_TIMEREN_MASK 0x00
	
	# # Reset EOC loop, and make it re-detect
	# # Set EOC_RESET_MASK
	# i2c_assign_bits $bus $address $RT5033_CHG_STAT_CTRL $RT5033_CHGENB_MASK 0x00
	# # Reset EOC_RESET_MASK
	# i2c_assign_bits $bus $address $RT5033_EOC_CTRL $RT5033_EOC_RESET_MASK 0x01
	# i2c_assign_bits $bus $address $RT5033_EOC_CTRL $RT5033_EOC_RESET_MASK 0x00

	# Enable Charger
	i2c_assign_bits $bus $address $RT5033_CHG_STAT_CTRL 0x01 0x00

	logger "turned charger on"
} else {
	# # Disable EOC
	# i2c_assign_bits $bus $address $RT5033_CHG_CTRL4 $RT5033_IEOC_MASK 0x00

	# Disable Charger
	i2c_assign_bits $bus $address $RT5033_CHG_STAT_CTRL 0x01 0x01

	logger "turned charger off"
} fi
