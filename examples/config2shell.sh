#!/bin/sh

ruby ../bbone_pinmux_tool.rb 	\
	--input-file in.txt 		\
	--input-format config 		\
	--output-format shell 		\
	--output-file setmuxing.sh
	