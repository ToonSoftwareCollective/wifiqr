import QtQuick 2.1
import qb.base 1.0

App {
    property url tileUrl: "WifiqrTile.qml"
    property url screenUrl: "WifiqrScreen.qml"

    // Location of the configuration file
    property url configfile: "file:///HCBv2/qml/config/wifiqr.cfg"

    property WifiqrScreen wifiqrScreen

    // Default settings will use the network configured for toon itself
    property variant settings: {
	"internal": true,
	"network": "",
	"password": "",
	"security": "WPA",
	"hidden": false
    }

    function init() {
	// The language package is currently not loaded by default
	qlanguage.loadLanguagePackage("apps/wifiqr/lang");
	// Tile definition
	const args = {
	    thumbCategory: "general",
	    thumbLabel: qsTr("WiFi QR"),
	    thumbIcon: "qrc:/apps/internetSettings/drawables/wifi-3.svg",
	    thumbIconVAlignment: "center",
	    thumbWeight: 30
	};
	registry.registerWidget("tile", tileUrl, this, null, args);
	registry.registerWidget("screen", screenUrl, this, "wifiqrScreen");
	loadSettings();
    }

    function loadSettings() {
	var cfg = new XMLHttpRequest();
	cfg.onreadystatechange = function() {
	    if (cfg.readyState == XMLHttpRequest.DONE) {
		if (cfg.status == 200) {
		    settings = JSON.parse(cfg.responseText);
		} else {
		    // Generate a settingsChanged event to trigger the
		    // creation of a QR code image
		    settings = settings;
		}
	    }
	}
	cfg.open("GET", configfile);
	cfg.send();
    }

    function saveSettings() {
	var cfg = new XMLHttpRequest();
	cfg.open("PUT", configfile);
	cfg.send(JSON.stringify(settings));
    }
}
