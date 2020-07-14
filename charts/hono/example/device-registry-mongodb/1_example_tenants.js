db = db.getSiblingDB('{{ .Values.mongodb.mongodbDatabase }}')

db.tenants.insert({
        "tenant-id": "DEFAULT_TENANT",
        "tenant": {
            "trusted-ca": [
                {
                    "subject-dn": "CN=DEFAULT_TENANT_CA,OU=Hono,O=Eclipse IoT,L=Ottawa,C=CA",
                    "public-key": "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAElkwCSPlO563eQb6ONdULAISm2XngGGSoAAz+I1s8zkS9guPUpNKoxeczLtKlObelHqBgIZtRXdrPRgXidGOnmQ==",
                    "algorithm": "EC",
                    "not-before": "2019-09-18T10:35:40+02:00",
                    "not-after": "2020-09-17T10:35:40+02:00"
                }
            ],
            "enabled": true
        },
        "version": "62a56c68-4b11-4e77-96eb-3291c66eeb95",
        "updatedOn": "2020-05-19T08:14:38Z"
    }
);

db.tenants.insert({
        "tenant-id": "HTTP_TENANT",
        "tenant": {
            "adapters": [
                {
                    "type": "hono-http",
                    "enabled": true,
                    "device-authentication-required": true
                },
                {
                    "type": "hono-mqtt",
                    "enabled": false,
                    "device-authentication-required": true
                },
                {
                    "type": "hono-kura",
                    "enabled": false,
                    "device-authentication-required": true
                },
                {
                    "type": "hono-coap",
                    "enabled": false,
                    "device-authentication-required": true
                }
            ],
            "enabled": true
        },
        "version": "62a56c68-4b11-4e77-96eb-3291c66eeb91",
        "updatedOn": "2020-05-19T08:14:39Z"
    }
);
