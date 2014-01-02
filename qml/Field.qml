import QtQuick 2.0
import Ubuntu.Components 0.1

UbuntuShape
{
	width: units.gu(4);
	height: units.gu(4);
	
	image: Image{}
	id: field;
	
	function clear()
	{
		for(var i = children.length; i>0; i--)
		{
			if(children[i-1].objectName == objectName + "_unit")
			{
				children[i-1].destroy();
			}
		}
	}
	
	function insertUnit(y, x, imagePath, color1, color2)
	{
		clear();
		
		var component = Qt.createComponent("Unit.qml");
		var unit = component.createObject(field);
		
		unit.objectName = "field_" + y + "_" + x + "_unit";
		unit.children[1].source = "../" + imagePath;
		
		unit.color = color1;
		unit.gradientColor = color2;
	}
}
