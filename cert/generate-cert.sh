#!/bin/bash

TYPE="${TYPE:-RSA}"
ISSUENAME="${ISSUENAME:-nobody}"

if [ "$TYPE" == "RSA" ]; then
	openssl genrsa -out ca.key 2048
	openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt -subj "/C=CN/CN=Aria2Server Root CA/O=$ISSUENAME"
	openssl genrsa -out server.key 2048
	openssl req -new -sha256 -key server.key -out server.csr -subj "/C=CN/L=Beijing/O=Aria2Server/OU=IT Dept./CN=localhost"
	openssl x509 -req -extfile <(printf "extendedKeyUsage=serverAuth\nsubjectAltName=DNS:localhost,IP:127.0.0.1,IP:0:0:0:0:0:0:0:1") -sha256 -days 825 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt
elif [ "$TYPE" == "ECC" ]; then
	openssl ecparam -genkey -name secp384r1 -out ca.key
	openssl req -x509 -new -nodes -key ca.key -sha384 -days 3650 -out ca.crt -subj "/C=CN/CN=Aria2Server Root CA/O=$ISSUENAME"
	openssl ecparam -genkey -name secp384r1 -out server.key
	openssl req -new -sha384 -key server.key -out server.csr -subj "/C=CN/L=Beijing/O=Aria2Server/OU=IT Dept./CN=localhost"
	openssl x509 -req -extfile <(printf "extendedKeyUsage=serverAuth\nsubjectAltName=DNS:localhost,IP:127.0.0.1,IP:0:0:0:0:0:0:0:1") -sha384 -days 825 -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt
fi
