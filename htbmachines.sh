#!/bin/bash

#Colores
verde="\e[0;32m\033[1m"
rojo="\e[0;31m\033[1m"
amarillo="\e[0;33m\033[1m"
purpura="\e[0;35m\033[1m"
turquesa="\e[0;36m\033[1m"
gris="\e[0;37m\033[1m"
fin_color="\033[0m\e[0m"

function ctrl_c(){
	echo -e "\n\n${rojo}[!] Saliendo...${fin_color}\n"
	exit 1
}

# Ctrl + C
trap ctrl_c INT

# Variables globales

main_url="https://htbmachines.github.io/bundle.js"


function helpPanel(){
	echo -e "\n${rojo}[+]${fin_color}${gris} Uso:${fin_color}"
	echo -e "\t ${purpura}y)${fin_color} ${gris}Obtener link de la resolucion de la maquina en youtube${fin_color}"
	echo -e "\t ${purpura}u)${fin_color} ${gris}Descargar o actualizar archivos necesarios${fin_color}"
	echo -e "\t ${purpura}m)${fin_color} ${gris}Buscar por un nombre de maquina${fin_color}"
	echo -e "\t ${purpura}o)${fin_color} ${gris}Buscar por sistema operativo${fin_color}"
	echo -e "\t ${purpura}i)${fin_color} ${gris}Buscar por direccion IP${fin_color}"
	echo -e "\t ${purpura}d)${fin_color} ${gris}Buscar por la dificultad de la maquina${fin_color}"
	echo -e "\t ${purpura}s)${fin_color} ${gris}Buscar por skill de la amaquina${fin_color}"
	echo -e "\t ${purpura}h)${fin_color}${gris} Mostrar el panel de ayuda${fin_color}\n"
}


function updateFiles(){

	if [ ! -f bundle.js ]; then
		echo -e "\n${rojo}[+]${fin_color} ${gris}Descargando archivos necesarios...${fin_color}"
		curl -s -X GET $main_url > bundle.js
		js-beautify bundle.js | sponge bundle.js
		echo -e "\n${rojo}[+]${fin_color} ${gris}Todos los archivos descargados.${fin_color}"
	else
		echo -e "\n${purpura}[+]${fin_color} ${gris}Comprobando si hay actualizaciones pendientes...${fin_color}\n"

		curl -s -X GET $main_url > bundle_temp.js
		js-beautify bundle_temp.js | sponge bundle_temp.js
		md5_temp_value=$(md5sum bundle_temp.js | awk '{print $1}')
		md5_original_value=$(md5sum bundle.js | awk '{print $1}')

		if [ "$md5_temp_value" == "$md5_original_value" ]; then
			echo -e "\n${gris}No hay actualizaciones${fin_color}\n"
			rm bundle_temp.js
		else
			echo -e "\n${gris}Hay actualizaciones${fin_color}\n"
			rm bundle.js && mv bundle_temp.js bundle.js
		fi

	fi
}

function searchMachine(){
	machineName="$1"

	machineName_checker="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//;s/^[^:]*/\x1b[0;36m&\x1b[0m/')"

	if [ "$machineName_checker" ]; then #comprueba que no este vacia la variable
		echo -e "\n${rojo}[+]${fin_color} ${gris}Listando las propiedades de la maquina $machineName${fin_color}${gris}:${fin_color}\n"

		cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//;s/^[^:]*/\x1b[0;36m&\x1b[0m/'
	
	else
		echo -e "\n${rojo} [!] La maquina no existe${fin_color}\n"
	fi
}

function searchIP(){
	ipAdress="$1"
	machineName="$(cat bundle.js | grep "ip: \"$ipAdress\"" -B 3 | grep "name: " | awk 'NF{print $NF}' | tr -d '"' | tr -d ',')"

	if [ "$machineName" ]; then

		echo -e "\n${purpura}[+]${fin_color}${gris} La maquina correspondiente para la IP${fin_color} ${amarillo}$ipAdress${fin_color} ${gris}es${fin_color} ${rojo}$machineName${fin_color}\n"

	else
		echo -e "\n${rojo} [!] La direccion IP no existe${fin_color}\n"

	fi
}

function getYoutubeLink(){
	machineName="$1"

	youtubeLink="$(cat bundle.js | awk "/name: \"$machineName\"/,/resuelta:/" | grep -vE "id:|sku:|resuelta" | tr -d '"' | tr -d ',' | sed 's/^ *//;s/^[^:]*/\x1b[0;36m&\x1b[0m/' | grep youtube | awk 'NF{print $NF}')"

	if [ $youtubeLink ]; then
		echo -e "\n${amarillo}[+]${fin_color} ${gris}El tutorial para esta maquina esta en el siguiente enlace:${fin_color} ${turquesa}$youtubeLink${fin_color}\n"
	else
		echo -e "\n${rojo} [!] La maquina proporcionada no existe${fin_color}\n"

	fi

}

function getMachinesDifficulty(){
	difficulty="$1"

	results_check="$(batcat bundle.js | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$results_check" ]; then
		echo -e "\n${amarillo}[+]${fin_color} ${gris}Representando las maquinas que poseen un nivel de dificultad${fin_color} ${rojo} $difficulty${fin_color}${gris}:${fin_color}\n"
		cat bundle.js | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column
	else
		echo -e "\n${rojo} [!] La dificultad indicada no existe${fin_color}"
	fi
}

function getOSMachines(){
	os="$1"

	os_results="$(cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$os_results" ]; then
		echo -e "\n${rojo}[+]${fin_color} ${gris}Mostrando las maquinas cuyo sistema operativo es${fin_color} ${purpura}$os${fin_color}${gris}:${fin_color}\n"
	cat bundle.js | grep "so: \"$os\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column

	else
		echo -e "\n${amarillo}[!]${fin_color} ${gris}El sistema operativo indicado no existe${fin_color}\n"
	fi
}

function getOSDifficultyMachines(){
	os="$2"
	difficulty="$1"

	check="$(cat bundle.js | grep -i "so: \"$os\"" -C 5 | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$check" ]; then

		echo -e "\n${amarillo}[+]${amarillo} ${gris}Se va a aplicar una busqueda por la dificultad${fin_color} ${rojo}$difficulty${fin_color} ${gris}y los sistemas operativos que sean${fin_color} ${purpura}$os${fin_color} ${gris}:${fin_color}\n"

		cat bundle.js | grep -i "so: \"$os\"" -C 5 | grep -i "dificultad: \"$difficulty\"" -B 5 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column

	else
		echo -e "\n${amarillo}[+]${fin_color} ${gris}La dificultad o sistema operativo indicado no existe.${fin_color}\n"
	fi
}

function getSkillsMachines(){
	skill="$1"

	check="$(cat bundle.js | grep "skills:" -B 6 | grep "$skill" -i -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column)"

	if [ "$check" ]; then
		echo -e "\n${amarillo}[+]${fin_color} ${gris}Maquinas encontradas que cuentan con la skill${fin_color} ${rojo}"$skill" ${fin_color}${gris}:${fin_color}\n"

		cat bundle.js | grep "skills:" -B 6 | grep "$skill" -i -B 6 | grep "name:" | awk 'NF{print $NF}' | tr -d '"' | tr -d ',' | column

	else
		echo -e "\n${rojo}[!]${fin_color} ${gris}No se encontro maquina con la skill indicada, o la skill indicada no existe${fin_color}\n"
	fi
}



# Indicadores
declare -i parameter_counter=0

while getopts "m:ui:y:d:o:s:h" arg; do
	case $arg in
		m) machineName="$OPTARG"; let parameter_counter+=1;;
		u) let parameter_counter+=2;;
		i) ipAdress="$OPTARG"; let parameter_counter+=3;;
		y) machineName="$OPTARG"; let parameter_counter+=4;;
		d) difficulty="$OPTARG"; let parameter_counter+=5;;
		o) os="$OPTARG"; let parameter_counter+=6;;
		s) skill="$OPTARG"; let parameter_counter+=40;;
		h) ;;
	esac
done

if [ $parameter_counter -eq 1 ]; then
	searchMachine $machineName
elif [ $parameter_counter -eq 2 ]; then
	updateFiles
elif [ $parameter_counter -eq 3 ]; then
	searchIP $ipAdress
elif [ $parameter_counter -eq 4 ]; then
	getYoutubeLink $machineName
elif [ $parameter_counter -eq 5 ]; then
	getMachinesDifficulty $difficulty
elif [ $parameter_counter -eq 6 ]; then
	getOSMachines $os
elif [ $parameter_counter -eq 11 ]; then
	getOSDifficultyMachines $difficulty $os
elif [ $parameter_counter -eq 40 ]; then
	getSkillsMachines "$skill"
else
	helpPanel
fi
