import QtQuick 2.0
import Ubuntu.Components 0.1

Grid  // Tutaj przechowujemy planszę
{
	spacing: units.gu(0.2);
	
	function clear()
	{
		for(var i = children.length; i>0; i--)
		{
			children[i-1].destroy();
		}
	}
	
	function appendField(y, x, imagePath)
	{
		var component = Qt.createComponent("Field.qml");
		var field = component.createObject(board);
		
		field.objectName = "field_" + y + "_" + x;
		field.image.source = "../" + imagePath;
	}
}
