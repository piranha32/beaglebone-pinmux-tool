#!/bin/sh

ruby ../bbone_pinmux_tool.rb 	\
	--input-file in.txt 		\
	--input-format config 		\
	--output-format python 		\
	--output-file setmuxing.py
	