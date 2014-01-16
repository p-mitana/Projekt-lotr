import QtQuick 2.0
import Ubuntu.Components 0.1

UbuntuShape
{
	width: units.gu(8);
	height: units.gu(8);
	
	image: Image {}
	
	MouseArea
	{
		anchors.fill: parent;
		
		onClicked:  // Iteruje po terenach
		{
			var terrain = terrainName();
			
			if(terrain == "grass")
				terrain = "forest";
			
			else if(terrain == "forest")
				terrain = "swamp";
			
			else if(terrain == "swamp")
				terrain = "hill";
			
			else if(terrain == "hill")
				terrain = "ruins";
			
			else if(terrain == "ruins")
				terrain = "grass";
			
			setTerrainName(terrain);
		}
	}
	
	function terrainName()
	{
		var terrain = image.source.toString().split("/");  // Wypakowujemy nazwę terenu
		terrain = terrain[terrain.length-1];
		terrain = terrain.split(".");
		terrain = terrain[0];
		
		return terrain;
	}
	
	function setTerrainName(terrain)
	{
		image.source = "../img/terrains/" + terrain + ".png";
	}
}