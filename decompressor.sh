#!/bin/bash

function ctrl_c(){
	echo -e "\n\n[!]Saliendo...\n"
	exit 1
}

# Ctrl + C
trap ctrl_c iNT

first_file="data.gz"
decompressed_file="$(7z l data.gz | tail -n 3 | head -n 1 | awk 'NF{print $NF}')"

7z x $first_file &>/dev/null

while [ $decompressed_file ]; do
  echo -e "\n[+] Nuevo archivo descomprimido: $decompressed_file"
  7z x $decompressed_file &>/dev/null 
  decompressed_file="$(7z l $decompressed_file 2>/dev/null | tail -n 3 | head -n 1 | awk 'NF{print $NF}')"
done
