import QtQuick 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

Page
{
	title: "Parametry symulacji";
	visible: false;
	
	// Szerokość planszy
	Label
	{
		id: widthLabel;
		text: "Szerokość planszy";
		anchors.verticalCenter: widthSlider.verticalCenter;
		anchors.left: parent.left;
		anchors.leftMargin: units.gu(1);
		width: units.gu(20);
	}
	
	Slider
	{
		id: widthSlider;
		minimumValue: 20;
		maximumValue: 70;
		anchors.top: parent.top;
		anchors.left: widthLabel.right;
		anchors.leftMargin: units.gu(1);
		anchors.topMargin: units.gu(1);
		width: units.gu(20);
		height: units.gu(4);
	}
	
	
	// Wysokość planszy
	Label
	{
		id: heightLabel;
		text: "Wysokość planszy";
		anchors.verticalCenter: heightSlider.verticalCenter;
		anchors.left: parent.left;
		anchors.leftMargin: units.gu(1);
		width: units.gu(20);
	}
	
	Slider
	{
		id: heightSlider;
		minimumValue: 15;
		maximumValue: 50;
		anchors.top: widthSlider.bottom;
		anchors.left: heightLabel.right;
		anchors.leftMargin: units.gu(1);
		anchors.topMargin: units.gu(1);
		width: units.gu(20);
		height: units.gu(4);
	}
	
	// Elfowie - liczba jednostek
	Label
	{
		id: eCount;
		text: "Elfowie";
		fontSize: "large";
		anchors.top: heightSlider.bottom;
		anchors.left: parent.left;
		anchors.topMargin: units.gu(1);
		anchors.leftMargin: units.gu(1);
	}
	
	// Liczba mieczników
	Label
	{
		id: eSwordCountLabel;
		text: "Liczba mieczników";
		anchors.verticalCenter: eSwordCount.verticalCenter;
		anchors.left: parent.left;
		anchors.leftMargin: units.gu(1);
		width: units.gu(20);
	}
	
	Slider
	{
		id: eSwordCount;
		minimumValue: 1;
		maximumValue: 30;
		anchors.top: eCount.bottom;
		anchors.left: eSwordCountLabel.right;
		anchors.leftMargin: units.gu(1);
		anchors.topMargin: units.gu(1);
		width: units.gu(20);
		height: units.gu(4);
	}
	
	// Liczba tarczowników
	Label
	{
		id: eShieldCountLabel;
		text: "Liczba tarczowników";
		anchors.verticalCenter: eShieldCount.verticalCenter;
		anchors.left: parent.left;
		anchors.leftMargin: units.gu(1);
		width: units.gu(20);
	}
	
	Slider
	{
		id: eShieldCount;
		minimumValue: 1;
		maximumValue: 30;
		anchors.top: eSwordCount.bottom;
		anchors.left: eShieldCountLabel.right;
		anchors.leftMargin: units.gu(1);
		anchors.topMargin: units.gu(1);
		width: units.gu(20);
		height: units.gu(4);
	}
	
	// Liczba łuczników
	Label
	{
		id: eBowCountLabel;
		text: "Liczba łuczników";
		anchors.verticalCenter: eBowCount.verticalCenter;
		anchors.left: parent.left;
		anchors.leftMargin: units.gu(1);
		width: units.gu(20);
	}
	
	Slider
	{
		id: eBowCount;
		minimumValue: 1;
		maximumValue: 30;
		anchors.top: eShieldCount.bottom;
		anchors.left: eBowCountLabel.right;
		anchors.leftMargin: units.gu(1);
		anchors.topMargin: units.gu(1);
		width: units.gu(20);
		height: units.gu(4);
	}
	
	// Liczba bohaterów
	Label
	{
		id: eHeroCountLabel;
		text: "Liczba bohaterów";
		anchors.verticalCenter: eHeroCount.verticalCenter;
		anchors.left: parent.left;
		anchors.leftMargin: units.gu(1);
		width: units.gu(20);
	}
	
	Slider
	{
		id: eHeroCount;
		minimumValue: 1;
		maximumValue: 2;
		anchors.top: eBowCount.bottom;
		anchors.left: eHeroCountLabel.right;
		anchors.leftMargin: units.gu(1);
		anchors.topMargin: units.gu(1);
		width: units.gu(20);
		height: units.gu(4);
	}
	
	// Orkowie - liczba jednostek
	Label
	{
		id: oCount;
		text: "Orkowie";
		fontSize: "large";
		anchors.top: eHeroCount.bottom;
		anchors.left: parent.left;
		anchors.topMargin: units.gu(1);
		anchors.leftMargin: units.gu(1);
	}
	
	// Liczba mieczników
	Label
	{
		id: oSwordCountLabel;
		text: "Liczba mieczników";
		anchors.verticalCenter: oSwordCount.verticalCenter;
		anchors.left: parent.left;
		anchors.leftMargin: units.gu(1);
		width: units.gu(20);
	}
	
	Slider
	{
		id: oSwordCount;
		minimumValue: 1;
		maximumValue: 30;
		anchors.top: oCount.bottom;
		anchors.left: oSwordCountLabel.right;
		anchors.leftMargin: units.gu(1);
		anchors.topMargin: units.gu(1);
		width: units.gu(20);
		height: units.gu(4);
	}
	
	// Liczba tarczowników
	Label
	{
		id: oShieldCountLabel;
		text: "Liczba tarczowników";
		anchors.verticalCenter: oShieldCount.verticalCenter;
		anchors.left: parent.left;
		anchors.leftMargin: units.gu(1);
		width: units.gu(20);
	}
	
	Slider
	{
		id: oShieldCount;
		minimumValue: 1;
		maximumValue: 30;
		anchors.top: oSwordCount.bottom;
		anchors.left: oShieldCountLabel.right;
		anchors.leftMargin: units.gu(1);
		anchors.topMargin: units.gu(1);
		width: units.gu(20);
		height: units.gu(4);
	}
	
	// Liczba łuczników
	Label
	{
		id: oBowCountLabel;
		text: "Liczba łuczników";
		anchors.verticalCenter: oBowCount.verticalCenter;
		anchors.left: parent.left;
		anchors.leftMargin: units.gu(1);
		width: units.gu(20);
	}
	
	Slider
	{
		id: oBowCount;
		minimumValue: 1;
		maximumValue: 30;
		anchors.top: oShieldCount.bottom;
		anchors.left: oBowCountLabel.right;
		anchors.leftMargin: units.gu(1);
		anchors.topMargin: units.gu(1);
		width: units.gu(20);
		height: units.gu(4);
	}
	
	// Liczba bohaterów
	Label
	{
		id: oHeroCountLabel;
		text: "Liczba bohaterów";
		anchors.verticalCenter: oHeroCount.verticalCenter;
		anchors.left: parent.left;
		anchors.leftMargin: units.gu(1);
		width: units.gu(20);
	}
	
	Slider
	{
		id: oHeroCount;
		minimumValue: 1;
		maximumValue: 2;
		anchors.top: oBowCount.bottom;
		anchors.left: oHeroCountLabel.right;
		anchors.leftMargin: units.gu(1);
		anchors.topMargin: units.gu(1);
		width: units.gu(20);
		height: units.gu(4);
	}
	
	// Tereny
	Rectangle
	{
		id: terrainsTitle;
		color: "transparent";
		width: units.gu(30);
		height: units.gu(4);
		anchors.left: eSwordCount.right;
		anchors.top: parent.top;
		anchors.leftMargin: units.gu(1);
		anchors.topMargin: units.gu(1);
		
		Label
		{
			text: "Tereny";
			fontSize: "large";
			anchors.horizontalCenter: parent.horizontalCenter;
			anchors.verticalCenter: parent.verticalCenter;
		}
	}
	
	Grid
	{
		id: terrainGrid;
		width: units.gu(26);
		height: units.gu(26);
		spacing: units.gu(1);
		rows: 3;
		columns: 3;
		anchors.top: terrainsTitle.bottom;
		anchors.horizontalCenter: terrainsTitle.horizontalCenter;
		
		Terrain {id: sector0;}
		Terrain {id: sector1;}
		Terrain {id: sector2;}
		Terrain {id: sector3;}
		Terrain {id: sector4;}
		Terrain {id: sector5;}
		Terrain {id: sector6;}
		Terrain {id: sector7;}
		Terrain {id: sector8;}
	}
	
	Button
	{
		id: randomButton;
		text: "Losuj";
		anchors.top : terrainGrid.bottom;
		anchors.horizontalCenter: terrainGrid.horizontalCenter;
		anchors.topMargin: units.gu(1);
		
		onClicked:
		{
			var terrains = "";
			
			if(!grass.checked && !forest.checked && !swamp.checked && !hill.checked && !ruins.checked)
				return;
			
			if(grass.checked)
				terrains += "grass;grass;grass;grass;";
			
			if(forest.checked)
				terrains += "forest;";
			
			if(swamp.checked)
				terrains += "swamp;";
			
			if(hill.checked)
				terrains += "hill;";
			
			if(ruins.checked)
				terrains += "ruins;";
			
			terrains = terrains.substring(0, terrains.length-1);  // Obcinamy średnik
			
			var terrains = terrains.split(";");  // Większa szansa na trawę
			
			sector0.setTerrainName(terrains[Math.floor((Math.random()*terrains.length))]);
			sector1.setTerrainName(terrains[Math.floor((Math.random()*terrains.length))]);
			sector2.setTerrainName(terrains[Math.floor((Math.random()*terrains.length))]);
			sector3.setTerrainName(terrains[Math.floor((Math.random()*terrains.length))]);
			sector4.setTerrainName(terrains[Math.floor((Math.random()*terrains.length))]);
			sector5.setTerrainName(terrains[Math.floor((Math.random()*terrains.length))]);
			sector6.setTerrainName(terrains[Math.floor((Math.random()*terrains.length))]);
			sector7.setTerrainName(terrains[Math.floor((Math.random()*terrains.length))]);
			sector8.setTerrainName(terrains[Math.floor((Math.random()*terrains.length))]);
		}
	}
	
	CheckBox
	{
		id: grass;
		anchors.top: terrainGrid.top;
		anchors.left: terrainsTitle.right;
		anchors.leftMargin: units.gu(1);
		anchors.topMargin: units.gu(1);
	}
	
	Label
	{
		id: grassLabel;
		text: "Trawa";
		anchors.left: grass.right;
		anchors.verticalCenter: grass.verticalCenter;
		anchors.leftMargin: units.gu(1);
	}
	
	CheckBox
	{
		id: forest;
		anchors.top: grass.bottom;
		anchors.left: terrainsTitle.right;
		anchors.leftMargin: units.gu(1);
		anchors.topMargin: units.gu(1);
	}
	
	Label
	{
		id: forestLabel;
		text: "Las";
		anchors.left: forest.right;
		anchors.verticalCenter: forest.verticalCenter;
		anchors.leftMargin: units.gu(1);
	}
	
	CheckBox
	{
		id: swamp;
		anchors.top: forest.bottom;
		anchors.left: terrainsTitle.right;
		anchors.leftMargin: units.gu(1);
		anchors.topMargin: units.gu(1);
	}
	
	Label
	{
		id: swampLabel;
		text: "Bagno";
		anchors.left: swamp.right;
		anchors.verticalCenter: swamp.verticalCenter;
		anchors.leftMargin: units.gu(1);
	}
	
	CheckBox
	{
		id: hill;
		anchors.top: swamp.bottom;
		anchors.left: terrainsTitle.right;
		anchors.leftMargin: units.gu(1);
		anchors.topMargin: units.gu(1);
	}
	
	Label
	{
		id: hillLabel;
		text: "Wzgórze";
		anchors.left: hill.right;
		anchors.verticalCenter: hill.verticalCenter;
		anchors.leftMargin: units.gu(1);
	}
	
	CheckBox
	{
		id: ruins;
		anchors.top: hill.bottom;
		anchors.left: terrainsTitle.right;
		anchors.leftMargin: units.gu(1);
		anchors.topMargin: units.gu(1);
	}
	
	Label
	{
		id: ruinsLabel;
		text: "Ruiny";
		anchors.left: ruins.right;
		anchors.verticalCenter: ruins.verticalCenter;
		anchors.leftMargin: units.gu(1);
	}
	
	Dialog
	{
		id: savingDialog;
		
		title: "Zapisywanie ustawień...";
		text: "Jeżeli jednostki nie pojawią się na planszy, naciśnij \"Resetuj\".";
	}
	
	Timer
	{
		id: timer;
		interval: 250;
		repeat: false;
		onTriggered:
		{
			// Rozmiar planszy
			var params = Math.round(widthSlider.value)  + ";";
			params += Math.round(heightSlider.value)  + ";";
			
			// Liczba jednostek
			params += Math.round(eSwordCount.value)  + ";";
			params += Math.round(eBowCount.value)  + ";";
			params += Math.round(eShieldCount.value)  + ";";
			params += Math.round(eHeroCount.value)  + ";";
			params += Math.round(oSwordCount.value)  + ";";
			params += Math.round(oBowCount.value)  + ";";
			params += Math.round(oShieldCount.value)  + ";";
			params += Math.round(oHeroCount.value)  + ";";
			
			// Tereny
			params += sector0.terrainName() + ";";
			params += sector1.terrainName() + ";";
			params += sector2.terrainName() + ";";
			params += sector3.terrainName() + ";";
			params += sector4.terrainName() + ";";
			params += sector5.terrainName() + ";";
			params += sector6.terrainName() + ";";
			params += sector7.terrainName() + ";";
			params += sector8.terrainName() + ";";
			
			// Rodzaje terenów
			params += (grass.checked ? 1 : 0) + ";";
			params += (forest.checked ? 1 : 0) + ";";
			params += (swamp.checked ? 1 : 0) + ";";
			params += (hill.checked ? 1 : 0) + ";";
			params += (ruins.checked ? 1 : 0);
			
			root.saveSettings(params);
		}
	}
	
	// Pasek narzędzi
	tools: ToolbarItems
	{
		opened: true;
		locked: true;
		
		ToolbarButton
		{
			text: "Zastosuj";
			iconSource: "../img/icons/save.svg";
			
			onTriggered:
			{
				savingDialog.show();
				timer.start();
			}
		}
	}
	
	function load(params)
	{
		params = params.split(";");
		
		var i = 0;
		
		// Rozmiar planszy
		widthSlider.value = params[i++];
		heightSlider.value = params[i++];
		
		// Liczba jednostek
		eSwordCount.value = params[i++];
		eBowCount.value = params[i++];
		eShieldCount.value = params[i++];
		eHeroCount.value = params[i++];
		oSwordCount.value = params[i++];
		oBowCount.value = params[i++];
		oShieldCount.value = params[i++];
		oHeroCount.value = params[i++];
		
		// Tereny
		sector0.image.source = "../img/terrains/" + params[i++] + ".png";
		sector1.image.source = "../img/terrains/" + params[i++] + ".png";
		sector2.image.source = "../img/terrains/" + params[i++] + ".png";
		sector3.image.source = "../img/terrains/" + params[i++] + ".png";
		sector4.image.source = "../img/terrains/" + params[i++] + ".png";
		sector5.image.source = "../img/terrains/" + params[i++] + ".png";
		sector6.image.source = "../img/terrains/" + params[i++] + ".png";
		sector7.image.source = "../img/terrains/" + params[i++] + ".png";
		sector8.image.source = "../img/terrains/" + params[i++] + ".png";
		
		// Rodzaje terenów
		grass.checked = params[i++] == 1;
		forest.checked = params[i++] == 1;
		swamp.checked = params[i++] == 1;
		hill.checked = params[i++] == 1;
		ruins.checked = params[i++] == 1;
	}
	
	function closeDialog()
	{
		PopupUtils.close(savingDialog);
	}
}