#!/bin/bash -x

rm -rf keys certs newcerts index.txt serial
mkdir keys certs newcerts
touch index.txt
echo 00 >serial

openssl req -new -config openssl.cnf -newkey rsa:4096 -days 36500 -nodes -x509 -subj "/C=DE/ST=Develpoer/L=Develpoer/O=Develpoer/CN=Developer CA" -keyout keys/ca.key  -out certs/ca.cert
openssl genrsa -out keys/server.key 4096 -subj "/C=LO/ST=Localdomain/L=Localhost/O=Dis/CN=*.dev"
openssl req -config openssl.cnf -days 36500 -new -key keys/server.key -out certs/server.csr -subj "/C=DE/ST=Develpoer/L=Develpoer/O=Develpoer/CN=*.dev"
openssl ca -batch -config openssl.cnf -policy policy_anything -out certs/server.cert -infiles certs/server.csr
mv newcerts/00.pem certs/server.pem

security delete-keychain 'Development Certificates' 2>&1
security create-keychain -p '' 'Development Certificates'
security add-trusted-cert -k 'Development Certificates' -r trustRoot certs/ca.cert
#security add-trusted-cert -k 'Development Certificates' -r trustAsRoot certs/server.pem



