db = db.getSiblingDB('{{ .Values.mongodb.mongodbDatabase }}')

db.devices.insert({
        "tenant-id": "DEFAULT_TENANT",
        "device-id": "4711",
        "device": {
            "enabled": true,
            "defaults": {
                "content-type": "application/vnd.bumlux",
                "importance": "high"
            }
        },
        "version": "5c10948e-c837-49df-9297-094139eec699",
        "updatedOn": "2020-05-19T08:14:39Z"
    }
);

db.devices.insert({
        "tenant-id": "DEFAULT_TENANT",
        "device-id": "4712",
        "device": {
            "enabled": true,
            "via": [
                "gw-1"
            ]
        },
        "version": "2b3a7fee-9ea1-4b40-abed-b6e8a177ed12",
        "updatedOn": "2020-05-19T08:14:40Z"
    }
);

db.devices.insert({
        "tenant-id": "DEFAULT_TENANT",
        "device-id": "gw-1",
        "device": {
            "enabled": true
        },
        "version": "ffdec048-cc93-4e27-bdb4-54071008f8dc",
        "updatedOn": "2020-05-19T08:14:41Z"
    }
);
