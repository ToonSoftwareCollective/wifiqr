import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0
import QtQuick.XmlListModel 2.0

Tile {
    property alias progress: config.status

    onProgressChanged: generate()

    onClicked: {
	if (app.wifiqrScreen) app.wifiqrScreen.load();
    }

    function init() {
	// Reload the configuration file whenever the settings are modified
	// This will then regenerate the QR code when loading is finished
	app.settingsChanged.connect(config.reload);
    }

    function encode(str) {
	if (str.search(/[^0-9a-f]/i) < 0) {
	    // String looks like a hex number
	    return '"' + str + '"';
	} else {
	    // Escape special characters
	    return str.replace(/[\\";,:]/g, "\\$&");
	}
    }

    function generate() {
	var network, password, security, hidden;
	// Wait until parsing of the XML configuration file is complete
	if (config.status == XmlListModel.Ready) {
	    if (app.settings.internal) {
		network = config.get(0).essid;
		password = config.get(0).psk;
		security = config.get(0).auth == "WEP" ? "WEP" : "WPA"
		hidden = config.get(0).visibility === "0";
	    } else {
		network = app.settings.network;
		password = app.settings.password;
		security = app.settings.security;
		hidden = app.settings.hidden;
	    }
	    // Build the string to be represented in the QR code
	    var str = "WIFI:";
	    str += "S:" + encode(network) + ";"
	    if (security != "") {
		str += "T:" + security + ";"
		str += "P:" + encode(password) + ";"
	    } else {
		str += ";;"
	    }
	    if (hidden === true) {
		str += "H:true"
	    }
	    str += ";"
	    // Generate the QR code image
	    qrCode.content = str;
	}
    }

    // Parse the configuration file that holds the wifi settings used by Toon
    XmlListModel {
	id: config
	source: "file:///HCBv2/config/config_hcb_netcon.xml"
	// The config file contains two interfaces: wired and wireless (wifi)
	// Only the wireless interface contains a wifi_essid node
	query: "/Config/device/interfaceSettings/wifi_essid/.."
	XmlRole {
	    name: "essid"
	    query: "wifi_essid/string()"
	}
	XmlRole {
	    name: "psk"
	    query: "wifi_key/string()"
	}
	XmlRole {
	    name: "auth"
	    query: "wifi_auth/string()"
	}
	XmlRole {
	    name: "visibility"
	    query: "../visibility/string()"
	}
    }

    Text {
	text: qsTranslate("WifiqrApp", "WiFi")
	font {
	    family: qfont.bold.name
	    pointSize: 18
	}
	anchors {
	    horizontalCenter: parent.horizontalCenter
	    top: parent.top
	    topMargin: isNxt ? 10 : 8
	}
    }

    QrCode {
	id: qrCode
	anchors {
	    horizontalCenter: parent.horizontalCenter
	    bottom: parent.bottom
	    bottomMargin: isNxt ? 18 : 15
	}
	width: isNxt ? 125 : 100
	height: width
    }
}
