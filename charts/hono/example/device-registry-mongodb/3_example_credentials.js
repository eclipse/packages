db = db.getSiblingDB('{{ .Values.mongodb.mongodbDatabase }}')

db.credentials.insert({
        "tenant-id": "DEFAULT_TENANT",
        "device-id": "4711",
        "credentials": [
            {
                "type": "hashed-password",
                "auth-id": "sensor1",
                "enabled": true,
                "secrets": [
                    {
                        "id": "2edbb8d9-3418-4e1f-a026-58428991a583",
                        "not-before": "2017-05-01T14:00:00+01:00",
                        "not-after": "2037-06-01T14:00:00+01:00",
                        "hash-function": "bcrypt",
                        "comment": "pwd: hono-secret",
                        "pwd-hash": "$2a$10$N7UMjhZ2hYx.yuvW9WVXZ.4y33mr6MvnpAsZ8wgLHnkamH2tZ1jD."
                    }
                ]
            },
            {
                "type": "psk",
                "auth-id": "sensor1",
                "enabled": true,
                "secrets": [
                    {
                        "id": "7e304286-17a4-4d06-ad1b-69633da268a2",
                        "not-before": "2018-01-01T00:00:00+01:00",
                        "not-after": "2037-06-01T14:00:00+01:00",
                        "comment": "key: hono-secret",
                        "key": "aG9uby1zZWNyZXQ="
                    }
                ]
            },
            {
                "type": "x509-cert",
                "auth-id": "CN=Device 4711,OU=Hono,O=Eclipse IoT,L=Ottawa,C=CA",
                "enabled": true,
                "secrets": [
                    {
                        "id": "58a7618f-d476-4fd1-8884-2913fd33951c",
                        "comment": "The secrets array must contain an object, which can be empty."
                    }
                ]
            }],
        "version": "cb789538-143e-4076-9999-93ecdb86a3bd",
        "updatedOn": "2020-05-19T08:14:45Z"
    }
);

db.credentials.insert({
        "tenant-id": "DEFAULT_TENANT",
        "device-id": "gw-1",
        "credentials": [
            {
                "type": "hashed-password",
                "auth-id": "gw",
                "enabled": true,
                "secrets": [
                    {
                        "id": "7d73fd15-4486-4e52-b21a-de38d22f5a5c",
                        "not-before": "2018-01-01T00:00:00+01:00",
                        "not-after": "2037-06-01T14:00:00+01:00",
                        "hash-function": "bcrypt",
                        "comment": "pwd: gw-secret",
                        "pwd-hash": "$2a$10$GMcN0iV9gJV7L1sH6J82Xebc1C7CGJ..Rbs./vcTuTuxPEgS9DOa6"
                    }
                ]
            },
            {
                "type": "psk",
                "auth-id": "gw",
                "enabled": true,
                "secrets": [
                    {
                        "id": "8c224895-05e1-4021-a7fb-179e0da4b9eb",
                        "not-before": "2018-01-01T00:00:00+01:00",
                        "not-after": "2037-06-01T14:00:00+01:00",
                        "comment": "key: gw-secret",
                        "key": "Z3ctc2VjcmV0"
                    }
                ]
            }
        ],
        "version": "84d478b1-f63e-4e08-a38e-c0461d14f8bb",
        "updatedOn": "2020-05-19T08:14:46Z"
    }
);
