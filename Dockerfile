FROM ubuntu:latest

LABEL org.opencontainers.image.authors="franco <franco.insua3.0@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive

RUN apt update && apt install -y net-tools \
  iputils-ping \
  curl \
  git \
  nano \
  apache2 \
  php

EXPOSE 80

COPY prueba.txt /var/www/html/

ENTRYPOINT service apache2 start && /bin/bash


