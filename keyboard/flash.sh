#!/bin/sh

# Script to flash my corne

if sudo dfu-programmer atmega32u4 get ; then
	sudo dfu-programmer atmega32u4 erase
	sudo dfu-programmer atmega32u4 flash keyboard/crkbd_rev1_layout_split_3x6_3_mine.hex
	sudo dfu-programmer atmega32u4 reset
fi
