#!/bin/bash

FICHERO="servers"

function Menu
{
	echo "_____________MENU_____________"
   	echo ""
   	echo "     1. Introducir Servidor Proxy"
   	echo "     2. Buscar Servidor Proxy"
   	echo "     3. Establecer Servidor Proxy"
   	echo "     4. Hacer Ping"
	echo "	   5. Ver Proxy Sistema"
	echo "	   6. Resetear Proxy"
   	echo "     7. Salir"
}

function Introducir
{
	if [ -e "servers" ]; then  # Si el fichero existe...
      		echo "Introduzca url del servidor: "
      		read -p "url:" URL
      		echo "Introduzca el puerto del servidor: "
      		read -p "puerto:" PUERTO
      		echo "Introduzca el usuario del servidor: "
      		read -p "usuario:" USER
      		echo "Introduzca la contrasenya del servidor: "
      		read -p "contrasenya:" PASS
      		# Redireccionamos los datos introducidos al fichero
		echo "Introduzca tipo de servidor(http/https): "
        	read -p "tipo:" TIPO
		if [ $TIPO == "http" ]; then
		 	if [ -z "$USER" ];then
      				echo "http://$URL:$PUERTO" >> $FICHERO
			else 
				echo "http://$USER:$PASS'@'$URL:$PUERTO" >> $FICHERO
			fi
		elif [ $TIPO == "https" ]; then
		 	if [ -z "$USER" ];then
      				echo "https://$URL:$PUERTO" >> $FICHERO
			else 
				echo "https://$USER:$PASS'@'$URL:$PUERTO" >> $FICHERO
			fi
		
		else
			echo "formato erroneo"
		fi 
			
   	else
      		# Si no existe el fichero, damos el mensaje de error...
      		echo "No se ha podido acceder al archivo de listado de servidores!"
   	fi
   
}

function Buscar
{   
	if [ -s $FICHERO ]; then
        	echo "Introduzca url del servidor a buscar: "
      		read -p "url: " URL

   
      		DATOS="$URL"  # Metemos en DATOS nuestra busqueda
      		SALIDA=$(grep "$DATOS" $FICHERO)  # Con grep asigna a salida el contenido de la linea
      		echo -e "${SALIDA//:/\n}"  # Cambiamos el caracter ":" por saltos de linea "\n"
   	else
      		echo "El fichero no existe o esta vacio"
   	fi
}

function Listar
{
	if [ -s $FICHERO ]; then  # Si existe el fichero y contiene datos
        	for linea in $(cat $FICHERO)  # Recorremos cada linea del fichero 
		do
                	echo "__________________"
         		echo -e "${linea//:/:}"  # Sacamos la linea con formato
         		echo "__________________"
        		echo ""

      		done
  	else
        	echo "El fichero no existe o esta vacio"
  	fi
}

function Set
{
	if [ $(whoami) != "root" ]; then
    		echo "Debes ser root para correr este script."
    		echo "Para entrar como root, escribe \"sudo su\" sin las comillas."
    		exit 1
	fi
	Listar
	echo "Introduzca posicion(numero) del servidor: "
        read -p "posicion:" POSICION
        
	proxy=`cat lista | sed -n '$POSICION  p'`
	echo "Introduzca tipo de servidor(http/https): "
        read -p "tipo:" TIPO
	if [ $TIPO == "http" ]; then
        	export http_proxy=$PROXY >> /etc/environment
		
	elif [ $TIPO == "https" ]; then
		export https_proxy=$PROXY >> /etc/environment
		
	fi
}

function Ping 
{
	
  	echo "Introduzca url del servidor a alcanzar: "
        read -p "url:" URL2
	ping $URL2
}

function Ver
{
	echo "Introduzca tipo de servidor(http/https): "
        read -p "tipo:" TIPO
	if [ $TIPO == "http" ]; then
		echo $http_proxy 

	elif [ $TIPO == "https" ]; then
		echo $https_proxy
	fi
}

function Reset
{
	
  	echo "Introduzca tipo de servidor(http/https): "
        read -p "tipo:" TIPO
	if [ $TIPO = "http" ]; then
		unset http_proxy
		exit 0
	elif [ $TIPO = "https" ]; then
		unset https_proxy
		exit 0
	else
		echo "formato erroneo"
		exit 1
	fi
}	

function Salir
{
	exit 0
}

opc=0
salir=8

while [ $opc -ne $salir ];  # Mientras el valor de $opt es distinto del valor de $salir...
do   
	clear
   	Menu  # Dibujamos el menu en pantalla
   	read -p "Opcion:..." opc  # Escogemos la opcion deseada
      
   	if [ $opc -ge 1 ] && [ $opc -le 7 ]; then  # No se por que no funciona el rango...!!!!!!!!!!!!!!!!!!!!!!
      		clear
     		case $opc in   # Acciones para las diferentes opciones del menu

         		1)Introducir   
            		;;       
         
         		2)Buscar
           		 ;;

         		3)Set
           		;;

			4)Ping
           		;;
			
			5)Ver
			;;

			6)Reset
			;;

         		7)Salir 
            		;;
     		 esac
   	else
      		echo "No ha introducido una opcion correcta!!"
   	fi
   	echo "Pulse una tecla..."
   	read
done

