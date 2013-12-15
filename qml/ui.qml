import QtQuick 2.0
import Ubuntu.Components 0.1

MainView
{
	id: root
	width: units.gu(100);
	height: units.gu(75);
	objectName: "lotr";
	applicationName: "Władca Pierścieni";
	
	headerColor: "#555555";
	backgroundColor: "#888888";
	footerColor: "#aaaaaa";
		
	PageStack
	{
		id: pagestack;
		Component.onCompleted: push(simultion);
		
		Page
		{
			id: simultion;
			title: "Symulacja";
			visible: false;
			
			Flickable
			{
				anchors.fill: parent;
				anchors.topMargin: units.gu(1);
				anchors.leftMargin: units.gu(1);
				anchors.rightMargin: units.gu(1);
				anchors.bottomMargin: units.gu(1);
				
				contentWidth: board.width;
				contentHeight: board.height;
				
				Board
				{
					id: board;
					objectName: "board";
				}

			}
			
			tools: ToolbarItems
			{
				id: toolbar;
				opened: true;
				locked: true;
				
/*				ToolbarButton
				{
					text: "Pomniejsz";
					iconSource: "../img/icons/zoomOut.svg";
				}
				
				ToolbarButton
				{
					text: "Powiększ";
					iconSource: "../img/icons/zoomIn.svg";
				}
*/				
				ToolbarButton
				{
					text: "Parametry";
					iconSource: "../img/icons/properties.svg";
                	onTriggered:
                	{
                		pagestack.push(settings);
						settings.tools.opened = true;
						settings.tools.locked = true;
                	}
            	}
			}
		}
	
		Page
		{
			id: settings;
			title: "Parametry symulacji";
			visible: false;
		}
	}
}
