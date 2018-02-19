#!/bin/bash

function temp(){
	sensors > .temp 
	temp1=$(awk 'NR==3' .temp |cut -c 16-17)
	echo $temp1;
	norm="65"
	high="70"
	crit="81"
	if [ "$temp1" -le "$norm" ]; then
		zenity --info --text "Temperatura equipo normal temperatura:"$temp1
	elif [ "$temp1" -ge "$high" ]; then
		zenity --info --text "Temperatura equipo alta temperatura:"$temp1
	elif [ "$temp1" -ge "$crit" ]; then
		zenity --info --text "Apagar equipo temperatura:"$temp1

	fi
}

temp
