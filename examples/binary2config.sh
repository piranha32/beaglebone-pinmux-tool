#!/bin/sh

#eeprom.bin file can be generated using config2binary.sh
 
ruby ../bbone_pinmux_tool.rb 	\
	--input-file eeprom.bin 	\
	--input-format binary 		\
	--output-format config 		\
	--output-file out.sh
