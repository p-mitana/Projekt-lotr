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
	
	signal start();
	signal stop();
	signal step();
		
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
				
				Rectangle
				{
					anchors.verticalCenter: parent.verticalCenter;
					width: units.gu(20);
					height: units.gu(4);
					color: "transparent";
					
					Label
					{
						id: turnCount;
						anchors.verticalCenter: parent.verticalCenter;
						anchors.horizontalCenter: parent.horizontalCenter;
						color: "gray";
						fontSize: "large";
						text: "Czas: 0";
					}
				}
				
				ToolbarButton
				{
					id: startstop;
					text: "Start";
					iconSource: "../img/icons/start.svg";
					
					onTriggered:
					{
						if(text == "Start")
						{
							text = "Stop";
							iconSource = "../img/icons/stop.svg";
							step.enabled = "false";
							root.start();
						}
						
						else
						{
							text = "Start";
							iconSource = "../img/icons/start.svg";
							root.stop();
						}
					}
				}
				
				ToolbarButton
				{
					id: step;
					text: "Krok";
					iconSource: "../img/icons/step.svg";
					
					onTriggered:
					{
						if(startstop.text == "Start")  // Nie działa, gdy symulacja jest uruchomiona
						{
							root.step();
						}
					}
				}
				
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
	
	function updateTurnCount(count)
	{
		turnCount.text = "Czas: " + count;
	}
}
