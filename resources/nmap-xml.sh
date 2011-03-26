#!/bin/sh
# usage ./nmap-xml.sh IP
nmap -v -v -v -sP -PP --system-dns --max-retries 1 --max-rtt-timeout 1000ms $1 -oX - > nmap-xml/$1
