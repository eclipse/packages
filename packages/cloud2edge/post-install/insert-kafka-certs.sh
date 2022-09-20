#!/bin/sh
#Necessary transformation in order to comply with the expected format of certificates
#imposed by the Ditto connectivity API: "ca": "-----BEGIN CERTIFICATE-----\n<trusted certificate>\n-----END CERTIFICATE-----"
certPath=/var/run/c2e/kafka-connection-cert/tls.crt
curlHome=/home/curl_user

cp /var/run/c2e/post-install-data/hono-kafka-connection.json $curlHome/hono-kafka-connection.json
chmod 777 $curlHome/hono-kafka-connection.json

jsonPath=$curlHome/hono-kafka-connection.json

if [ -e $certPath ]
  then
    cert="$(cat /var/run/c2e/kafka-connection-cert/tls.crt | tr -d '\n' | sed 's/E-----/E-----\\\\n/g' | sed 's/-----END/\\\\n-----END/g')"
    sed -i '/uri/ a '"\"ca\": \"$cert\","'' $jsonPath
fi
