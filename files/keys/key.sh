#Create certificate authority (CA)
openssl req -passout pass:password -new -x509 -days 3650 -extensions v3_ca -keyout ca_private.pem -out ca.pem -subj "/CN=CA/OU=MONGO/O=SCALEGRID/L=PUNE/ST=MH/C=IN"

#Create key and certificate signing requests (CSR)
#Clients of replica set
openssl req -newkey rsa:4096 -nodes -out client.csr -keyout client.key -subj '/CN=RManikandan/OU=MONGO_CLIENTS/O=SCALEGRID/L=PUNE/ST=MH/C=IN'

#Members of replica set
openssl req -newkey rsa:4096 -nodes -out mongo1.csr -keyout mongo1.key -subj '/CN=mongo1/OU=MONGO/O=SCALEGRID/L=PUNE/ST=MH/C=IN'
openssl req -newkey rsa:4096 -nodes -out mongo2.csr -keyout mongo2.key -subj '/CN=mongo2/OU=MONGO/O=SCALEGRID/L=PUNE/ST=MH/C=IN'
openssl req -newkey rsa:4096 -nodes -out mongo3.csr -keyout mongo3.key -subj '/CN=mongo3/OU=MONGO/O=SCALEGRID/L=PUNE/ST=MH/C=IN'

#Sign the certificate signing requests with CA
#client
openssl x509 -passin pass:password -sha256 -req -days 365 -in client.csr -CA ca.pem -CAkey ca_private.pem -CAcreateserial -out client-signed.crt
#server
openssl x509 -passin pass:password -sha256 -req -days 365 -in mongo1.csr -CA ca.pem -CAkey ca_private.pem -CAcreateserial -out mongo1-signed.crt -extensions v3_req -extfile <(
cat << EOF
[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = 127.0.0.1
DNS.2 = localhost
DNS.3 = mongo1
EOF
)

# sign node 2 csr
openssl x509 -passin pass:password -sha256 -req -days 365 -in mongo2.csr -CA ca.pem -CAkey ca_private.pem -CAcreateserial -out mongo2-signed.crt -extensions v3_req -extfile <(
cat << EOF
[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = 127.0.0.1
DNS.2 = localhost
DNS.3 = mongo2
EOF
)

# sign node 3 csr
openssl x509 -passin pass:password -sha256 -req -days 365 -in mongo3.csr -CA ca.pem -CAkey ca_private.pem -CAcreateserial -out mongo3-signed.crt -extensions v3_req -extfile <(
cat << EOF
[ v3_req ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = 127.0.0.1
DNS.2 = localhost
DNS.3 = mongo3
EOF
)

#Create the privacy enhanced mail (PEM) file for mongod
cat client-signed.crt client.key > client.pem
cat mongo1-signed.crt mongo1.key > mongo1.pem
cat mongo2-signed.crt mongo2.key > mongo2.pem
cat mongo3-signed.crt mongo3.key > mongo3.pem