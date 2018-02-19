#!/bin/bash

DIR_DESTINO="/home/antonio/Dropbox/etc"
DIR_ORIG="/etc"
FICHERO="$DIR_DESTINO/copia_total.tar.gz"
LOG="/home/antonio/Dropbox/etc/log"
FECHA=`date +%d-%m-%Y`
DIA_MES=`date +%d`
FIJA="01"

if [ $DIA_MES = $FIJA ]; then
	rm  $FICHERO
  	rm  $LOG
	rm  *.tar.gz
	echo "copia seguridad completa"
	tar -zcvf $FICHERO -g $LOG $DIR_ORIG 
	echo "copia seguridad completa ok" | mail -s "copia seguridad" antocarmona@gmail.com
	exit 0
else 
	if [ -f $FICHERO ]; then
	echo "copia seguridad PARCIAL"
	tar -zcvf $DIR_DESTINO/incremental-$FECHA.tar.gz -g $LOG $DIR_ORIG
	
		echo "copia seguridad incremental ok" | mail -s "copia seguridad" antocarmona@gmail.com	
		exit 0
	fi

fi

