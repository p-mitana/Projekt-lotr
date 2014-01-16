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
		
		unit.width = 3*width/4;
		unit.height = 3*height/4;
	}
	
	function zoomIn()
	{
		width += units.gu(1);
		height += units.gu(1);
		
		for(var i = children.length; i>0; i--)
		{
			if(children[i-1].objectName == objectName + "_unit")
			{
				children[i-1].width = 3*width/4;
				children[i-1].height = 3*height/4;
			}
		}
	}
	
	function zoomOut()
	{
		if(width <= units.gu(2))
			return;
		
		width -= units.gu(1);
		height -= units.gu(1);
		
		for(var i = children.length; i>0; i--)
		{
			if(children[i-1].objectName == objectName + "_unit")
			{
				children[i-1].width = 3*width/4;
				children[i-1].height = 3*height/4;
			}
		}
	}
}
