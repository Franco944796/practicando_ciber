#!/bin/bash

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
	echo -e "\n${rojo}[!] Saliendo...${fin_color}\n"
	exit 1
}

# Ctrl + C
trap ctrl_c INT

function helpPanel(){
	echo -e "\n${naranja}[+]${fin_color} ${gris} Uso:${fin_color} ${purpura} $0 ${fin_color}\n"
	echo -e "\t${purpura}-m)${fin_color} ${gris} Dinero con el que se desea jugar${fin_color}\n"	
	echo -e "\t${purpura}-t)${fin_color} ${gris} Tecnica a utilizar${fin_color} ${rojo} (martingala / inverseLabrouchere)${fin_color}\n"
	exit 1
}

function martingala(){
	echo -e "\n${naranja}[+]${fin_color} ${gris}Vamos a jugar con la tecnica martingala${fin_color}"
	echo -en "\n${naranja}[+]${fin_color} ${gris}Cuanto dinero tienes pensado apostar? -->${fin_color} " && read initial_bet
	echo -en "\n${naranja}[+]${fin_color} ${gris}Apostaras a par o impar? --> ${fin_color}" && read par_impar
	# echo -e "\n${naranja}[+]${fin_color} ${gris}Vamos a jugar con una cantidad inicial de${fin_color} ${rojo}$initial_bet${fin_color} ${gris}a${fin_color} ${purpura}$par_impar${fin_color}"

	backup_bet=$initial_bet
	play_counter=1
	jugadas_malas=""
	max_dinero=0

	while true; do
		money=$(($money-$initial_bet))
		# echo -e "\n${naranja}[+]${fin_color} ${gris}Acabas de apostar ${fin_color} ${purpura} $initial_bet${fin_color} ${gris} y tienes ${fin_color} ${purpura} $money${fin_color}"

		random_number="$(($RANDOM % 37))"
		# echo -e "\n${naranja}[+]${fin_color} ${gris}Ha salido el numero${fin_color} ${naranja}$random_number${fin_color}"

		if [ ! "$money" -lt 0 ]; then
			if [ "$par_impar" == "par" ]; then
				# Cuando apostamos a numeros pares:
				if [ "$(($random_number % 2))" -eq 0 ]; then
					if [ "$random_number" -eq 0 ]; then
						# echo -e "${rojo}[+] Ha salido el 0, por tanto perdemos${fin_color}"
						
						initial_bet=$(($initial_bet*2))
						jugadas_malas+="$random_number "

						# echo -e "${naranja}[+]${fin_color} ${gris}Ahora mismo te quedas en${fin_color} ${naranja}$money${fin_color}"
					else
						# echo -e "${naranja}[+]${fin_color} ${verde}El numero que ha salido es par, ganas${fin_color}"
						
						reward=$(($initial_bet*2))

						# echo -e "${naranja}[+]${fin_color} ${gris}Ganas un total de${fin_color} ${naranja}$reward${fin_color}"
						
						money=$(($money + $reward))
						
						if [ "$money" -gt "$max_dinero" ]; then
							max_dinero=$money
						fi


						# echo -e "${naranja}[+]${fin_color} ${gris}Tienes${fin_color} ${naranja}$money${fin_color}"

						initial_bet=$backup_bet
						jugadas_malas=""
					fi
				else
					# echo -e "${rojo} [!] El numero que ha salido es impar, pierdes${fin_color}"
					
					initial_bet=$(($initial_bet*2))
					jugadas_malas+="$random_number "

					# echo -e "${naranja}[+]${fin_color} ${gris}Ahora mismo te quedas en${fin_color} ${naranja}$money${fin_color}"
				fi
			else
				# Esto es cuando apostamos a numeros impares:
				if [ "$(($random_number % 2))" -eq 1 ]; then
					# echo -e "${naranja}[+]${fin_color} ${verde}El numero que ha salido es impar, ganas${fin_color}"
					reward=$(($initial_bet*2))
					# echo -e "${naranja}[+]${fin_color} ${gris}Ganas un total de${fin_color} ${naranja}$reward${fin_color}"
					money=$(($money + $reward))
					if [ "$money" -gt "$max_dinero" ]; then
						max_dinero=$money
					fi
					# echo -e "${naranja}[+]${fin_color} ${gris}Tienes${fin_color} ${naranja}$money${fin_color}"
					initial_bet=$backup_bet
					jugadas_malas=""
				else
					# echo -e "${rojo} [!] El numero que ha salido es par, pierdes${fin_color}"
					initial_bet=$(($initial_bet*2))
					jugadas_malas+="$random_number "
					# echo -e "${naranja}[+]${fin_color} ${gris}Ahora mismo te quedas en${fin_color} ${naranja}$money${fin_color}"
				fi

			fi
		else
			echo -e "\n ${rojo}[!] Te quedas en ceros${fin_color}"
			echo -e "\n${naranja}[+]${fin_color} ${gris}Han habido un total de${fin_color} ${naranja}$(($play_counter-1))${fin_color} ${gris}jugadas${fin_color}"
			echo -e "\n${naranja}[+]${fin_color} ${gris}A continuacion se representan las malas jugadas consecutivas que han salido: ${fin_color}"
			echo -e "\n${purpura}[ $jugadas_malas ]${fin_color}"
			echo -e "\n${naranja}[+]${fin_color} ${gris}El maximo de dinero alcanzado fue:${fin_color} ${naranja}$max_dinero${fin_color}"
			exit 0 # se podria utilizar un break pero con exit 0 finalizamos el programa.
		fi
		let play_counter+=1
	done

}

function inverseLabrouchere(){

	jugadas_totales=0
	bet_to_renew=$(($money+50)) # Dinero el cual una vez alcanzado hara que renovemos nuestra secuencia a (1 2 3 4)

	echo -e "\n${naranja}[+]${fin_color} ${gris}Dinero actual:${fin_color} ${naranja}$money ${fin_color}"
	echo -en "\n${naranja}[+]${fin_color} ${gris}Apostaras a par o impar? --> ${fin_color}" && read par_impar

	declare -a my_secuence=(1 2 3 4)

	echo -e "\n${naranja}[+]${fin_color} ${gris}Comenzamos con la secuencia${fin_color} ${purpura} [ ${my_secuence[@]} ] ${fin_color}"
	
	bet=$((${my_secuence[0]} + ${my_secuence[-1]}))

	echo -e "${naranja}[+]${fin_color} ${gris}El tope a renovar la secuencia esta establecido en${fin_color} ${purpura}$bet_to_renew${fin_color}"

	while true; do
		let jugadas_totales+=1
		random_number=$(($RANDOM % 37))
		money=$(($money - $bet))
		
		if [ ! "$money" -lt 0 ]; then

			echo -e "\n${naranja}[+]${fin_color} ${gris}Invertimos${fin_color} ${naranja}$bet${fin_color}"
			echo -e "${naranja}[+]${fin_color} ${gris}Tenemos${fin_color} ${naranja}$money${fin_color}"
			echo -e "${naranja}[+]${fin_color} ${gris}Ha salido el numero${fin_color} ${naranja}$random_number${fin_color}"

			if [ "$par_impar" == "par" ]; then
				if [ "$(($random_number % 2))" -eq 0 ] && [ "$random_number" -ne 0 ]; then #usando otra condicion podemos evitarnos repetirla en la evaluacion del proximo elif.
					echo -e "${verde}[+] El numero es par, ganas${fin_color}"
					reward=$(($bet*2))
					let money+=$reward
					echo -e "${naranja}[+]${fin_color}${gris}Te quedas en${fin_color} ${naranja}$money${fin_color}${gris} dinero${fin_color}"

					if [ "$money" -gt $bet_to_renew ]; then
						echo -e "${naranja}[+]${fin_color} ${gris}Se ha superado el tope establecido de${fin_color} ${purpura}$bet_to_renew ${fin_color} ${gris}para renovar nuestra secuencia${fin_color}"
						let bet_to_renew+=50
						echo -e "${naranja}[+]${fin_color} ${gris}El tope se ha establecido en${fin_color} ${purpura}$bet_to_renew${fin_color}"
						my_secuence=(1 2 3 4)
						bet=$((${my_secuence[0]} + ${my_secuence[-1]}))
						echo -e "${naranja}[+]${fin_color} ${gris}La secuencia ha sido restablecida a ${fin_color} ${purpura}[${my_secuence[@]}]${fin_color}"
					
					elif [ "$money" -lt $(($bet_to_renew - 100)) ]; then # Entra cuando no llegas al maximo, ni a lo inferior.
						echo -e "${naranja}[+]${fin_color} ${gris}Hemos llegado a un minimo critico, se reajusta el tope${fin_color}"
						bet_to_renew=$(($bet_to_renew - 100))
						echo -e "${naranja}[+]${fin_color} ${gris}El tope ha sido renovado a ${fin_color}${purpura}$bet_to_renew${fin_color}"

						my_secuence+=($bet)
						echo -e "\n${naranja}[+]${fin_color} ${gris}Nuestra nueva secuencia es${fin_color} ${purpura} [${my_secuence[@]}] ${fin_color}"

						if [ "${#my_secuence[@]}" -ne 1 ] && [ "${#my_secuence[@]}" -ne 0 ]; then
							bet=$((${my_secuence[0]} + ${my_secuence[-1]}))	
						elif [ "${#my_secuence[@]}" -eq 1 ]; then
							bet=${my_secuence[0]}
						else
							echo -e "\n${rojo}[!] Hemos perdido la secuencia${fin_color}"
							my_secuence=(1 2 3 4)
							echo -e "\n${verde}[+] Restablecemos la secuencia a ${fin_color} ${purpura} [${my_secuence[@]}] ${fin_color}"
							bet=$((${my_secuence[0]} + ${my_secuence[-1]}))
						fi

					
					else
						my_secuence+=($bet)
						echo -e "\n${naranja}[+]${fin_color} ${gris}Nuestra nueva secuencia es${fin_color} ${purpura} [${my_secuence[@]}] ${fin_color}"

						if [ "${#my_secuence[@]}" -ne 1 ] && [ "${#my_secuence[@]}" -ne 0 ]; then
							bet=$((${my_secuence[0]} + ${my_secuence[-1]}))	
						elif [ "${#my_secuence[@]}" -eq 1 ]; then
							bet=${my_secuence[0]}
						else
							echo -e "\n${rojo}[!] Hemos perdido la secuencia${fin_color}"
							my_secuence=(1 2 3 4)
							echo -e "\n${verde}[+] Restablecemos la secuencia a ${fin_color} ${purpura} [${my_secuence[@]}] ${fin_color}"
							bet=$((${my_secuence[0]} + ${my_secuence[-1]}))
					fi
				fi

				elif [ "$((random_number % 2))" -eq 1 ] || [ "$random_number" -eq 0 ]; then
					if [ "$((random_number % 2))" -eq 1 ]; then
						echo -e "${rojo}[!] El numero es impar, pierdes${fin_color}"
					else
						echo -e "${rojo}[!] Ha salido el numero 0, pierdes${fin_color}"
					fi

					unset my_secuence[0]
					unset my_secuence[-1] 2>/dev/null

					my_secuence=(${my_secuence[@]})

					echo -e "${naranja}[+]${fin_color} ${gris}La secuencia queda de la siguiente forma:${fin_color} ${purpura}[${my_secuence[@]}] ${fin_color}"

					if [ "${#my_secuence[@]}" -ne 1 ] && [ "${#my_secuence[@]}" -ne 0 ]; then
						bet=$((${my_secuence[0]} + ${my_secuence[-1]}))
					elif [ "${#my_secuence[@]}" -eq 1 ]; then
						bet=${my_secuence[0]}
					else
						echo -e "\n${rojo}[!] Hemos perdido la secuencia${fin_color}"
						my_secuence=(1 2 3 4)
						echo -e "\n${verde}[+] Restablecemos la secuencia a ${fin_color} ${purpura} [${my_secuence[@]}] ${fin_color}"
						bet=$((${my_secuence[0]} + ${my_secuence[-1]}))
					fi
					
				fi
			fi
		else
			echo -e "\n${rojo}[!] Te has quedado sin nada${fin_color}"
			echo -e "\n${naranja}[+]${fin_color} ${gris}En total han habido${fin_color} ${purpura}$jugadas_totales${purpura} ${gris}jugadas totales${fin_color}"
			exit 1
		fi
	done
	
}


while getopts "m:t:h" arg; do
	case $arg in
		m) money="$OPTARG";;
		t) technique="$OPTARG";;
		h) helpPanel;;
	esac
done

if [ "$money" ] && [ "$technique" ]; then
	if [ "$technique" == "martingala" ]; then
		martingala
	elif [ "$technique" == "inverseLabrouchere" ]; then
		inverseLabrouchere
	else
		echo -e "\n${rojo} [!] La tecnica introducida no existe${fin_color}"
		helpPanel
	fi
else
	helpPanel
fi





