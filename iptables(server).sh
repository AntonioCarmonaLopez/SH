#!/bin/sh

MI_IP_PUBLICA=”X.X.X.X”
case $1 in
start )
echo iniciando iptables
iptables -F
iptables -X
#Estableciendo las reglas por defecto
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#Al localhost se le permite todo
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#Habilito el puerto 22, para mi, para conectarme con un ssh 
iptables -A INPUT -s "$MI_IP_PUBLICA" -p tcp --dport 22 -j ACCEPT
#puerto 80
iptables -A INPUT -p tcp -m tcp --sport 80 -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 80 -j ACCEPT
#Se muestran los resultados
if [ $? = 0 ]
then
echo reglas aplicadas
exit 0
else
echo se produjo un error al aplicar las reglas
exit 1
fi
echo "Listo."
;;
restart )
echo reiniciando iptables
iptables -F
iptables -X
#Estableciendo las reglas por defecto
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#Al localhost se le permite todo
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#Habilito el puerto 22, para mi, para conectarme con un ssh 
iptables -A INPUT -s "$MI_IP_PUBLICA" -p tcp --dport 22 -j ACCEPT
#puerto 80
iptables -A INPUT -p tcp -m tcp --sport 80 -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 80 -j ACCEPT
#Se muestran los resultados
if [ $? = 0 ]
then
echo reglas aplicadas
exit 0
else
echo se produjo un error al aplicar las reglas
exit 1
fi
echo "Listo."
echo "Listo."
;;
stop )
echo -n "Desactivando Reglas..."
#Pongo las políticas por defecto en 'ACCEPT'
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
#Quito todas las reglas declaradas
iptables -F
iptables -X
iptables -Z
#Se muestran los resultados
if [ $? = 0 ]
then
echo reglas desactivadas
exit 0
else
echo se produjo un error al desactivar las reglas
exit 1
fi
echo "Listo."
;;
* )
echo iniciando iptables
iptables -F
iptables -X
#Estableciendo las reglas por defecto
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
#Al localhost se le permite todo
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#Habilito el puerto 22, para mi, para conectarme con un ssh 
iptables -A INPUT -s "$MI_IP_PUBLICA" -p tcp --dport 22 -j ACCEPT
#puerto 80
iptables -A INPUT -p tcp -m tcp --sport 80 -j ACCEPT
iptables -A OUTPUT -p tcp -m tcp --dport 80 -j ACCEPT
#Se muestran los resultados
if [ $? = 0 ]
then
echo reglas aplicadas
exit 0
else
echo se produjo un error al aplicar las reglas
exit 1
fi
echo "Listo."
;;
esac
