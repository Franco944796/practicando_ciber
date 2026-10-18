#!/bin/bash

#Letras
# ñ

#Colours
verde="\e[0;32m\033[1m"
rojo="\e[0;31m\033[1m"
azul="\e[0;34m\033[1m"
naranja="\e[0;33m\033[1m"
purpura="\e[0;35m\033[1m"
turquesa="\e[0;36m\033[1m"
gris="\e[0;37m\033[1m"
fin_color="\033[0m\e[0m"

function ctrl_c(){
  echo -e "\n${rojo}[!] Saliendo...${fin_color}"
  exit 1
}

# Ctrl + C
trap ctrl_c INT

function helpPanel(){
  echo -e "\n${naranja}[+]${fin_color} ${gris}Uso: ${fin_color} ${purpura} $0 ${fin_color}\n"
  echo -e "\n${purpura}a)${fin_color} ${gris} Actualizar el sistema${fin_color}${verde} (habilitada)${fin_color}"
  echo -e "\n${purpura}f)${fin_color} ${gris} Filtrar en una pagina web${fin_color}${verde} (habilitada)${fin_color}"
  echo -e "\n${rojo}m)${fin_color} ${gris} Mostrar las 10 redes con mejor señal disponibles ${fin_color}${rojo}(deshabilitada de momento)${fin_color}"
  echo -e "\n${verde}b)${fin_color} ${gris} Buscar informacion en paginas cientificas, institucionales y confiables${fin_color}${rojo} (deshabilitada de momento)${fin_color}"

  exit 1
}

function actualizarSistema(){
  echo -e "\n${naranja}[+]${fin_color} ${gris} A continuacion solicitara la clave del usuario administrador para luego actualizar el sistema: ${fin_color}"
  sudo apt update
  sudo apt full-upgrade -y
}

function filtrarEnUnaPaginaWeb(){
  echo -en "\n${naranja}[+]${fin_color} ${gris} Ingrese la url de la pagina web: ${fin_color}" && read link_web
  echo -en "\n${naranja}[*]${fin_color} ${gris} Ingrese palabra/s para realizar el filtrado: ${fin_color}" && read word_web
  curl -s -X GET $link_web > reporte_temp.js
  js-beautify reporte_temp.js | sponge reporte_temp.js | grep -i "$word_web" reporte_temp.js > resultados_filtrado.js
  batcat resultados_filtrado.js
  
  rm resultados_filtrado.js # elimina el archivo generado en el grep.
  # rm reporte_temp.js # elimina el archivo temporal.
  echo -e "\n${naranja}[+]${fin_color} ${gris} Ejecutando comando temporal...${fin_color}"
  echo "$(batcat reporte_temp.js | grep -i "$word_web" > temporal.js | batcat | tr -d '/' | tr -d '<' | tr -d '>' | sed 's/ \+/\n/g')" # el comando sed en este caso reemplaza los multiples espacios por un salto de linea.
}

function mostrarRedes(){
  echo -e"\n${rojo}[!]${fin_color} ${gris} Listando las redes cercanas con mejor señal:${fin_color}"
  nmcli dev wifi list
  # falta hacer que la maquina virtual pueda ver las redes disponibles
  # terminar el script
}

#function recopilarPaginasConfiables(){
#  echo -en "\n${naranja}[+]${fin_color} Ingrese "
#}

function busquedaInteligente(){
  echo -e "\n${rojo}[!]${fin_color} ${gris} Se inicio la busqueda de informacion...${fin_color}"
  # ...

}

# Indicadores
declare -i parameter_counter=0


while getopts "afmbh" arg; do 
  case "$arg" in 
    a) let parameter_counter+=1;;
    f) let parameter_counter+=2;;
    m) let parameter_counter+=4;;
    b) let parameter_counter+=8;;
    h) ;; #helpPanel
  esac
done

if [ "$parameter_counter" -eq 1 ]; then
  actualizarSistema
elif [ "$parameter_counter" -eq 2 ]; then
  filtrarEnUnaPaginaWeb
elif [ "$parameter_counter" -eq 4 ]; then
  mostrarRedes
elif [ "$parameter_counter" -eq 8 ]; then
  busquedaInteligente
else
  helpPanel
fi
