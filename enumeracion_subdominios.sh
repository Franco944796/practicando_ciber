#!/bin/bash

#Letras
# ñ

#Colores
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

# Variables globales
THREADS=150 # Hilos para ejecucion paralela.

function helpPanel(){
  echo -e "\n${naranja}[+]${fin_color} ${gris}Uso:${fin_color} ${purpura} $0 ${fin_color}"
  echo -e "\n${purpura}d) ${fin_color} ${gris}Especifica el target (domain)${fin_color}"
}


function reconnaissanceSubdomains(){
  # Esta funcion ejecuta un conjunto de herramientas con parametros enfocados a la enumeracion de subdominios, y guarda el total de estos en un unico archivo.txt, sin repeticiones.
  echo -e "\n${naranja}[+]${fin_color} ${gris} Se ejecuta una actualizacion del sistema antes de implementar el flujo de trabajo.${fin_color}"
  sudo apt update &> /dev/null
  sudo apt full-upgrade -y &> /dev/null

  DOMAIN=$1
  SUBDOMAINS_MAIN=subdomains_$DOMAIN_.txt
  TEMP_FILE=temp1.txt #archivo temp.
  TEMP_FILE2=temp2.txt
  TEMP_FILE3=temp3.txt
  TEMP_JSON=temp.json
  TEMP_HTML=temp.html
  WORDLIST=/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
  WORDLIST2=/usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt
  WORDLIST3=/usr/share/seclists/Discovery/DNS/subdomains-top1million-110000.txt

  # Reemplazar luego por banner.
  echo -e "\n${verde}============================================================${fin_color}\n${naranja}[!]${fin_color} ${azul} Ejecutando reconocimiento completo de subdominios para:${fin_color} ${gris} $DOMAIN${fin_color}\n${verde}============================================================${fin_color}"

  # ---Herramientas Pasivas--- (en esta etapa aun no se verifica si los subdominios estan activos):

  echo -e "\n${rojo}[!]${fin_color} ${azul} Enumeracion pasiva (subfinder - CLI)...${fin_color}" # Verificada
  # subfinder -d $DOMAIN -t $THREADS -silent -nW >> $TEMP_FILE 2>/dev/null
  # Si se configura una API key da mejores resultados.

  echo -e "${rojo}[!]${fin_color} ${azul} Enumeracion pasiva (assetfinder - CLI)...${fin_color}" # Verificada
  # assetfinder --subs-only $DOMAIN >> $TEMP_FILE 2>/dev/null

  echo -e "${rojo}[!]${fin_color} ${azul} Enumeracion pasiva (theHarvester - CLI)...${fin_color}" # Verificada
  # theHarvester -d $DOMAIN -b all -q 2>/dev/null | grep ".$DOMAIN" > $TEMP_FILE2
  # grep -v "Target: " $TEMP_FILE2 > $TEMP_FILE
  # Esta herramienta es bastante lenta pero recopila (generalmente) muchos subdominios.

  echo -e "${rojo}[!]${fin_color} ${azul} Enumeracion pasiva (crt.sh - CLI)...${fin_color}" # Verificada
  # curl -s "https://crt.sh/?q=%.$DOMAIN&output=json" | jq -r '.[].name_value' | sort -u >> $TEMP_FILE || echo -e "${gris}Error en el procesamiento${finn_color}" >&2 
  # Esto envia una solicitud curl al endpoint de su API, y procesa la respuesta JSON con jq.

  echo -e "${rojo}[!]${fin_color} ${azul} Enumeracion pasiva (sublist3r - CLI)...${fin_color}" # Verificada
  # sublist3r -d $DOMAIN -t $THREADS -o $TEMP_FILE3 &>/dev/null && batcat $TEMP_FILE3 >> $TEMP_FILE
  



  # ==================    FALTA CONFIGURAR:    ============================================================


  echo -e "${rojo}[!]${fin_color} ${azul} Enumeracion pasiva (github-subdomains - CLI)...${fin_color}"
  github-subdomains -d $DOMAIN # falta agregar "-t" y el token de github.
  # Se debe configurar.

  echo -e "${rojo}[!]${fin_color} ${azul} Enumeracion pasiva (amass - CLI)...${fin_color}"
  # Se debe configurar un API key para mejores resultados.

  # ======================================================================================================
  


  # ---Herramientas Web---

  echo -e "${rojo}[!]${fin_color} ${azul} Enumeracion pasiva (rapidDNS - Web)...${fin_color}" # Verificada.
  # curl -s "https://rapiddns.io/subdomain/$DOMAIN?full=1" | grep -oP "[a-zA-Z0-9._-]+\.$DOMAIN" | sort -u >> $TEMP_FILE
  # Se emplea RapidDNS mediante el uso de curl.


  # ---Herramientas Activas--- (en esta etapa aun no se verifica si los subdominios estan activos):
  
  echo -e "\n${rojo}[!]${fin_color} ${azul} Enumeracion activa (gobuster - CLI)...${fin_color}" #Verificada.
  # gobuster dns -do $DOMAIN -w $WORDLIST -t 5 -o $TEMP_FILE2 --timeout 5s --delay 100ms -q &>/dev/null
  # awk '{print $1}' $TEMP_FILE2 >> $TEMP_FILE
  # Se reducen los hilos debido a que sino se sobrecarga generando solicitudes DNS.

  echo -e "${rojo}[!]${fin_color} ${azul} Enumeracion activa (ffuf - CLI)...${fin_color}" # Verificada.
  # ffuf -u http://$DOMAIN -w $WORDLIST:FUZZ -H "Host: FUZZ.$DOMAIN" -fs 986 -o $TEMP_FILE2 &>/dev/null # Falta filtrar codigos de estado de error y demas.
  # batcat $TEMP_FILE2 | jq -r '.results[].input.FUZZ' >> $TEMP_FILE3
  # sed "s/$/.$DOMAIN/" $TEMP_FILE3 >> $TEMP_FILE
  
  echo -e "${rojo}[!]${fin_color} ${azul} Enumeracion activa (wfuzz - CLI)...${fin_color}" # Verificada.
  wfuzz -Z -t $THREADS -w $WORDLIST3 -H "Host: FUZZ.$DOMAIN" https://$DOMAIN > $TEMP_FILE2 2>/dev/null 
  sed '1, 9d' $TEMP_FILE2 > $TEMP_FILE3
  batcat $TEMP_FILE3 | awk '$2 != 403 {print $13}' > $TEMP_FILE2
  awk 'NF' $TEMP_FILE2 > $TEMP_FILE3
  sed 's/"//g' $TEMP_FILE3 > $TEMP_FILE2
  sed "s/$/.$DOMAIN/" $TEMP_FILE2 >> $TEMP_FILE
  # La herramienta es bastante rapida incluso utilizando la Wordlist3.


  # Se deduplican los resultados:
  echo -e "\n${naranja}[*]${fin_color} ${azul} Validando resultados finales...${fin_color}"
  
  if [ -e "./$TEMP_FILE" ] && [ -s "./$TEMP_FILE" ]; then
    sort -u $TEMP_FILE > $SUBDOMAINS_MAIN
    # Verificacion mediante dnsx:
    rm -f $TEMP_FILE $TEMP_FILE2 $TEMP_FILE3 2>/dev/null
  fi

  # Fin de la func.
}







# Indicadores
declare -i parameter_counter=0

while getopts "d:h" arg; do # Con ":" al inicio suprimes los mensajes de error por defecto.
  case "$arg" in
    d) DOMAIN="$OPTARG"; let parameter_counter+=1;;
    h) helpPanel;;
  esac
done

if [ $parameter_counter -eq 1 ]; then
  reconnaissanceSubdomains $DOMAIN
else
  helpPanel
fi
