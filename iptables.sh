#!/bin/bash

case "$1" in

normal)
echo iniciando iptables
#Borrándose reglas anteriores
iptables -F
iptables -X
iptables -t nat -F

## Establecemos politicas predeterminada
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
# Aceptamos todo de localhost
iptables -A INPUT -i lo -j ACCEPT
# A nuestra IP le dejamos todo
iptables -A INPUT -s 192.168.1.101 -j ACCEPT
# El puerto 80 y 443
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
#Pemito trafico SMTP
iptables -A OUTPUT -o wlan0 -p tcp --dport 465 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i wlan0 -p tcp --sport 465 -m state --state ESTABLISHED -j ACCEPT
#Pemito trafico imap
iptables -A OUTPUT -o wlan0 -p tcp --dport 993 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i wlan0 -p tcp --sport 993 -m state --state ESTABLISHED -j ACCEPT
#amule
iptables -A INPUT -p tcp --dport 50048 -j ACCEPT
iptables -A INPUT -p udp --dport 40885 -j ACCEPT
iptables -A INPUT -p udp --dport 50051 -j ACCEPT
#Permito tráfico torrent
iptables -A INPUT -p tcp --dport 40886 -j ACCEPT
# Cerramos rango de los puertos privilegiados. Cuidado con este tipo de
# barreras, antes hay que abrir a los que si tienen acceso.
iptables -A INPUT -p tcp --dport 1:1024 -j DROP
iptables -A INPUT -p udp --dport 1:1024 -j DROP
# impedimos iniciar conexion los puertos altos
# (puede que ftp no funcione)
iptables -A INPUT -p tcp --syn --dport 1025:65535 -j DROP
#Se muestran los resultados
if [ $? = 0 ]
	then
	echo reglas aplicadas correctamente
	echo "Listo."
	echo "verifica el firewall con los comandos netstat -nlt, lsof -i TCP:puerto,sudo iptables -L -n -v"
	echo "ver puertos abiertos: nmap -sTU localhost" 
	exit 0
else
	echo se produjo un error al aplicar las reglas
	exit 1
fi
;;

stop)
#Borrándose reglas anteriores
echo "Borrando reglas anteriores..."
iptables -F
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#Se muestran los resultados
if [ $? = 0 ]
	then
	echo reglas aplicadas correctamente
	echo "Listo."
	echo "verifica el firewall con los comandos netstat -nlt, lsof -i TCP:puerto,sudo iptables -L -n -v"
	echo "Usar: /etc/init.d/iptables-script {start|restart|stop|paranoia}"
	echo "ver puertos abiertos: nmap -sTU localhost" 
	exit 0
else
	echo se produjo un error al aplicar las reglas
	exit 1
fi
;;

restart)
echo iniciando iptables

# borrar reglas anteriores
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
#Estableciendo las reglas por defecto(bloqueo trafico entrante)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
# Aceptamos todo de localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# acepto paquetes de conexiones establecidas
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# Permitir acceso DNS saliente
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
# permito trafico ntp
iptables -A OUTPUT -p udp --dport 123 -j ACCEPT
iptables -A INPUT -p udp --sport 123 -j ACCEPT
#Permito trafico http
iptables -A OUTPUT -o wlan0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i wlan0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
#Permito trafico https
iptables -A OUTPUT -o wlan0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i wlan0 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
# FTP
iptables -A INPUT -p tcp -m tcp --sport 20:21 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 20:21 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --sport 1024:65535 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 1024:65535 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
#Pemito trafico SMTP
iptables -A OUTPUT -o wlan0 -p tcp --dport 465 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i wlan0 -p tcp --sport 465 -m state --state ESTABLISHED -j ACCEPT
#Pemito trafico imap
iptables -A OUTPUT -o wlan0 -p tcp --dport 993 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i wlan0 -p tcp --sport 993 -m state --state ESTABLISHED -j ACCEPT
#bloquear trackers facebook
#iptables -A OUTPUT -d 31.13.64.0/18 -j REJECT
#iptables -A OUTPUT -d 66.220.144.0/20 -j REJECT
#iptables -A OUTPUT -d 69.171.224.0/19 -j REJECT
#iptables -A OUTPUT -d 69.63.176.0/20 -j REJECT 
#podemos bloquear dominio por IP
#averiguo IP del dominio
#host -t a www.facebook.com
#iptables -A OUTPUT -p tcp -d 69.171.224.0/19 -j DROP
#iptables -A OUTPUT -p tcp -d www.facebook.com -j DROP
# iptables -A OUTPUT -p tcp -d facebook.com -j DROP
# Permito hacer ping a mi laptop
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
# Prevengo ataques DDOS
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
# Vamos con los logs
iptables -N LOGGING
iptables -A INPUT -j LOGGING
# Marco los paquetes a descartar
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables Packet Dropped: " --log-level 7
# Ahora descarto esos paquetes
iptables -A LOGGING -j DROP
#Se muestran los resultados
if [ $? = 0 ]
	then
	echo reglas aplicadas correctamente
	echo "Listo."
	echo "verifica el firewall con los comandos netstat -nlt, lsof -i TCP:puerto,sudo iptables -L -n -v"
	echo "ver puertos abiertos: nmap -sTU localhost" 
	exit 0
else
	echo se produjo un error al aplicar las reglas
	exit 1
fi
;;
paranoia)

echo iniciando iptables

# borrar reglas anteriores
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
#Estableciendo las reglas por defecto(bloqueo trafico entrante)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
# Aceptamos todo de localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# acepto paquetes de conexiones establecidas
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# Permitir acceso DNS saliente
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
# permito trafico ntp
iptables -A OUTPUT -p udp --dport 123 -j ACCEPT
iptables -A INPUT -p udp --sport 123 -j ACCEPT
#Permito trafico http
iptables -A OUTPUT -o wlan0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i wlan0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
#Permito trafico https
iptables -A OUTPUT -o wlan0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i wlan0 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
# FTP
iptables -A INPUT -p tcp -m tcp --sport 20:21 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 20:21 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --sport 1024:65535 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 1024:65535 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
#Pemito trafico SMTP
iptables -A OUTPUT -o wlan0 -p tcp --dport 465 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i wlan0 -p tcp --sport 465 -m state --state ESTABLISHED -j ACCEPT
#Pemito trafico imap
iptables -A OUTPUT -o wlan0 -p tcp --dport 993 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i wlan0 -p tcp --sport 993 -m state --state ESTABLISHED -j ACCEPT
#bloquear trackers facebook
#iptables -A OUTPUT -d 31.13.64.0/18 -j REJECT
#iptables -A OUTPUT -d 66.220.144.0/20 -j REJECT
#iptables -A OUTPUT -d 69.171.224.0/19 -j REJECT
#iptables -A OUTPUT -d 69.63.176.0/20 -j REJECT 
#podemos bloquear dominio por IP
#averiguo IP del dominio
#host -t a www.facebook.com
#iptables -A OUTPUT -p tcp -d 69.171.224.0/19 -j DROP
#iptables -A OUTPUT -p tcp -d www.facebook.com -j DROP
# iptables -A OUTPUT -p tcp -d facebook.com -j DROP
# Permito hacer ping a mi laptop
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
# Prevengo ataques DDOS
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
# Vamos con los logs
iptables -N LOGGING
iptables -A INPUT -j LOGGING
# Marco los paquetes a descartar
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables Packet Dropped: " --log-level 7
# Ahora descarto esos paquetes
iptables -A LOGGING -j DROP
#Se muestran los resultados
if [ $? = 0 ]
	then
	echo reglas aplicadas correctamente
	echo "Listo."
	echo "verifica el firewall con los comandos netstat -nlt, lsof -i TCP:puerto,sudo iptables -L -n -v"
	echo "ver puertos abiertos: nmap -sTU localhost" 
	exit 0
else
	echo se produjo un error al aplicar las reglas
	exit 1
fi
;;
*)
echo iniciando iptables

# borrar reglas anteriores
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
#Estableciendo las reglas por defecto(bloqueo trafico entrante)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP
# Aceptamos todo de localhost
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT
# acepto paquetes de conexiones establecidas
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
# Permitir acceso DNS saliente
iptables -A OUTPUT -p udp --dport 53 -m state --state NEW -j ACCEPT
# permito trafico ntp
iptables -A OUTPUT -p udp --dport 123 -j ACCEPT
iptables -A INPUT -p udp --sport 123 -j ACCEPT
#Permito trafico http
iptables -A OUTPUT -o wlan0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i wlan0 -p tcp --sport 80 -m state --state ESTABLISHED -j ACCEPT
#Permito trafico https
iptables -A OUTPUT -o wlan0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i wlan0 -p tcp --sport 443 -m state --state ESTABLISHED -j ACCEPT
# FTP
iptables -A INPUT -p tcp -m tcp --sport 20:21 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 20:21 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --sport 1024:65535 --dport 1024:65535 -m state --state ESTABLISHED -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 1024:65535 -m state --state NEW,RELATED,ESTABLISHED -j ACCEPT
#Pemito trafico SMTP
iptables -A OUTPUT -o wlan0 -p tcp --dport 465 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i wlan0 -p tcp --sport 465 -m state --state ESTABLISHED -j ACCEPT
#Pemito trafico imap
iptables -A OUTPUT -o wlan0 -p tcp --dport 993 -m state --state NEW,ESTABLISHED -j ACCEPT
iptables -A INPUT -i wlan0 -p tcp --sport 993 -m state --state ESTABLISHED -j ACCEPT
#bloquear trackers facebook
#iptables -A OUTPUT -d 31.13.64.0/18 -j REJECT
#iptables -A OUTPUT -d 66.220.144.0/20 -j REJECT
#iptables -A OUTPUT -d 69.171.224.0/19 -j REJECT
#iptables -A OUTPUT -d 69.63.176.0/20 -j REJECT 
#podemos bloquear dominio por IP
#averiguo IP del dominio
#host -t a www.facebook.com
#iptables -A OUTPUT -p tcp -d 69.171.224.0/19 -j DROP
#iptables -A OUTPUT -p tcp -d www.facebook.com -j DROP
# iptables -A OUTPUT -p tcp -d facebook.com -j DROP
# Permito hacer ping a mi laptop
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT
# Prevengo ataques DDOS
iptables -A INPUT -p tcp --dport 80 -m limit --limit 25/minute --limit-burst 100 -j ACCEPT
# Vamos con los logs
iptables -N LOGGING
iptables -A INPUT -j LOGGING
# Marco los paquetes a descartar
iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "IPTables Packet Dropped: " --log-level 7
# Ahora descarto esos paquetes
iptables -A LOGGING -j DROP
#Se muestran los resultados
if [ $? = 0 ]
	then
	echo reglas aplicadas correctamente
	echo "Listo."
	echo "verifica el firewall con los comandos netstat -nlt, lsof -i TCP:puerto,sudo iptables -L -n -v"
	echo "ver puertos abiertos: nmap -sTU localhost" 
	exit 0
else
	echo se produjo un error al aplicar las reglas
	exit 1
fi
;;
esac

exit 0



#pones este script en /etc/init.d/
#mv iptables_script /etc/init.d

#update-rc.d iptables.sh defaults
#/etc/init.d/iptables.sh start
#/etc/init.d/iptables.sh restart
#/etc/init.d/iptables.sh stop
#/etc/init.d/iptables.sh paranoia

