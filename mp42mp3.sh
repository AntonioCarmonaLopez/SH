#!/bin/bash
	
function leer(){
	echo -e "\e[33mRuta y Nombre archivo archivo origen(mp4)"
	read ORIGEN
	echo -e "\e[34mnombre archivo salida(mp3)"
	read SALIDA
#se comprueba si esta vacio el nombre salida
	if [ -z "$SALIDA" ];then
		SALIDA="salida.mp3"
	fi
		

	echo -e "\e[0mreset"
	clear
}

function convertir(){
	ffmpeg -i $ORIGEN -q:a 0 -map a $SALIDA
}
clear
echo -e "\e[31mSencillo script para extraer audio de archivos mp4"
sleep 2
clear
leer
convertir

