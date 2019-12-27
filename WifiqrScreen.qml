import QtQuick 2.1
import qb.components 1.0
import BasicUIControls 1.0
import QtQuick.Layouts 1.11

Screen {
    property string hiddenNetworkPass: ""

    // Populate the widgets when explicitly called from the tile
    // Can't use regular show and onShown event handler because that also runs
    // when returning from the virtual keyboard, which would reset everything
    function load() {
	networkNameLabel.inputText = app.settings.network;
	hiddenNetworkPass = app.settings.password;
	passwordLabel.inputText = "*".repeat(hiddenNetworkPass.length);
	typeSelection.currentControlId = app.settings.internal ? 0 : 1;
	hidden.selected = app.settings.hidden === true;
	switch (app.settings.security) {
	  case "":
	    authSelection.currentControlId = 2;
	    break;
	  case "WEP":
	    authSelection.currentControlId = 1;
	    break;
	  default:
	    authSelection.currentControlId = 0;
	    break;
	}
	show();
    }

    function openKeyboard(location) {
	typeSelection.currentControlId = 1
	if (location == 0) {
	    qkeyboard.open(qsTr("Enter the password"), "", savePassword);
	} else {
	    qkeyboard.open(qsTr("Enter the network name"), networkNameLabel.inputText, saveNetworkName);
	}
    }

    function saveNetworkName(text) {
	if (text) {
	    networkNameLabel.inputText = text;
	}
    }

    function savePassword(text) {
	if (text) {
	    hiddenNetworkPass = text;
	    // Mask the password for display
	    passwordLabel.inputText = "*".repeat(text.length);
	}
    }

    screenTitle: qsTr("WiFi network specification")

    onShown: {
	addCustomTopRightButton(qsTr("Save"));
    }

    onCustomButtonClicked: {
	// Save the configuration
	app.settings.network = networkNameLabel.inputText;
	app.settings.password = hiddenNetworkPass;
	app.settings.internal = typeSelection.currentControlId == 0;
	switch (authSelection.currentControlId) {
	  case 0:
	    app.settings.security = "WPA";
	    break;
	  case 1:
	    app.settings.security = "WEP";
	    break;
	  case 2:
	    app.settings.security = "";
	    app.settings.password = "";
	    break;
	}
	app.settings.hidden = hidden.selected;
	hide();
	app.settings = app.settings;
	app.saveSettings();
    }

    // Control group for the radiobuttons for internal or manual wifi
    ControlGroup {
	id: typeSelection
	exclusive: true
    }

    // Control group for the radiobuttons for the authentication method
    ControlGroup {
	id: authSelection
	exclusive: true
    }

    GridLayout {
	anchors.centerIn: parent
	anchors.verticalCenterOffset: -20
	columns: 3
	StandardRadioButton {
	    Layout.columnSpan: 3
	    Layout.fillWidth: true
	    Layout.bottomMargin: 32
	    controlGroupId: 0
	    controlGroup: typeSelection
	    text: qsTr("Use Toon's network configuration")
	}
	StandardRadioButton {
	    Layout.columnSpan: 3
	    Layout.fillWidth: true
	    controlGroupId: 1
	    controlGroup: typeSelection
	    text: qsTr("Manual network specification")
	}
	Text {
	    Layout.leftMargin: 36
	    text: qsTr("Network") + ": "
	}
	EditTextLabel {
	    id: networkNameLabel
	    onClicked: openKeyboard(1)
	}
	IconButton {
	    Layout.preferredWidth: 36
	    iconSource: "qrc:/images/edit.svg"
	    onClicked: openKeyboard(1)
	}
	Text {
	    Layout.leftMargin: 36
	    text: qsTr("Password") + ": "
	}
	EditTextLabel {
	    id: passwordLabel
	    onClicked: openKeyboard(0)
	}
	IconButton {
	    Layout.preferredWidth: 36
	    iconSource: "qrc:/images/edit.svg"
	    onClicked: openKeyboard(0)
	}
	Text {
	    Layout.leftMargin: 36
	    text: qsTr("Security") + ": "
	}
	RowLayout {
	    StandardRadioButton {
		Layout.fillWidth: true
		controlGroupId: 0
		controlGroup: authSelection
		text: "WPA/WPA2"
	    }
	    StandardRadioButton {
		Layout.fillWidth: true
		controlGroupId: 1
		controlGroup: authSelection
		text: "WEP"
	    }
	    StandardRadioButton {
		Layout.fillWidth: true
		controlGroupId: 2
		controlGroup: authSelection
		text: qsTr("None")
	    }
	}
	Text {
	    text: ""
	}
	Text {
	    Layout.leftMargin: 36
	    text: qsTr("Additional") + ": "
	}
	StandardCheckBox {
	    id: hidden
	    Layout.fillWidth: true
	    text: qsTr("Hidden WiFi network")
	}
    }
}
