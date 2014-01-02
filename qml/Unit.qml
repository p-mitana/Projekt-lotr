import QtQuick 2.0
import Ubuntu.Components 0.1

UbuntuShape
{
	id: unit;
	
	anchors.horizontalCenter: parent.horizontalCenter;
	anchors.verticalCenter: parent.verticalCenter;
	
	width: units.gu(3);
	height: units.gu(3);
	
	Image
	{
		width: units.gu(2);
		height: units.gu(2);
		anchors.horizontalCenter: parent.horizontalCenter;
		anchors.verticalCenter: parent.verticalCenter;
	}
}
