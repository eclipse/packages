// this needs to be JSON encoded and updated in ../post-install/drogue-cloud-connection.json

function mapToDittoProtocolMsg(
    headers,
    textPayload,
    bytePayload,
    contentType) {

    let application = headers["ce_application"].replace("-", "_");
    let device = headers["ce_device"];

    let datacontenttype = headers["content-type"];
    let dataschema = headers["ce_dataschema"];
    let type = headers["ce_type"];
    let subject = headers["ce_subject"];

    if (datacontenttype !== "application/json") {
        return null;
    }
    /*
    if (subject !== "state") {
        return null;
    }
    */
    /*
    if (dataschema !== "urn:drogue:iot:temperature") {
        return null;
    }
    */
    if (type !== "io.drogue.event.v1") {
        return null;
    }

    let payload = JSON.parse(textPayload);

    let attributesObj = {
        drogue: {
            instance: headers["ce_instance"],
            application: headers["ce_application"],
            device: headers["ce_device"],
            modelNumber: payload["metrics"]["modelNumber"],
            serialNumber: payload["metrics"]["serialNumber"]
        }
    };

    let featuresObj = {
        temperature: {
            properties: {
                value: payload["metrics"]["temperature"]
            }
        },
        humidity: {
            properties: {
                value: payload["metrics"]["humidity"]
            }
        }
    };

    // optionally map the battery level
    let battery = payload["batt"];
    if (battery != null) {
        featuresObj["battery"] = {
            properties: {
                value: battery,
            }
        };
    } else {
        featuresObj["battery"] = {
            properties: null
        };
    }

    // optionally map the location
    let geoloc = payload["geoloc"];
    if (geoloc != null && geoloc["lat"] != null && geoloc["lon"] != null ) {
        featuresObj["location"] = {
            properties: {
                latitude: geoloc["lat"],
                longitude: geoloc["lon"]
            }
        };
    } else {
        featuresObj["location"] = {
            properties: null,
        };
    }

    let dittoHeaders = {
        "response-required": false,
        "content-type": "application/merge-patch+json",
        "If-Match": "*"
    };

    return Ditto.buildDittoProtocolMsg(
        application,
        device,
        "things",
        "twin",
        "commands",
        "merge",
        "/",
        dittoHeaders,
        {
            attributes: attributesObj,
            features: featuresObj
        }
    );
}
