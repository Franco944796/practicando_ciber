#/bin/bash

#Colores
verde="\e[0;32m\033[1m"
rojo="\e[0;31m\033[1m"
azul="\e[0;34\033[1m"
amarillo="\e[0;33m\033[1m"
purpura="\e[0;35m\033[1m"
turquesa="\e[0;36m\033[1m"
gris="\e[0;37m\033[1m"
fin_color="\033[0m\e[0m"

echo -e "\n ${rojo} [+] ${fin_color} ${azul} Los usuarios conectados: \n ${fin_color} $(who -q) FS="/" \n"

