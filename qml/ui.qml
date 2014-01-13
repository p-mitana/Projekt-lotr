import QtQuick 2.0
import QtWebKit 3.0
import Ubuntu.Components 0.1
import Ubuntu.Components.Popups 0.1

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
	signal reset();
	signal saveLog();
		
	PageStack
	{
		id: pagestack;
		Component.onCompleted: push(tabs);
		
		Tabs
		{
			id: tabs;
			
			Tab
			{
				title: "Plansza";
				page: Page
				{
					id: simultion;
					
					Flickable
					{
						id: flick;
						
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
						
						ToolbarButton
						{
							id: reset;
							text: "Resetuj";
							iconSource: "../img/icons/reset.svg";
							
							onTriggered:
							{
								root.reset();
							}
						}
						
						/*
						ToolbarButton
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
					
					Dialog
					{
						id: messageDialog;
						
						Button
						{
							text: "Zamknij";
							onClicked: PopupUtils.close(messageDialog);
						}
					}
				}
			}
			
			Tab
			{
				title: "Przebieg bitwy";
				page: Page
				{
					WebView
					{
						width: parent.width;
						height: parent.height;
						
						id: webview;
					}
					
					tools: ToolbarItems
					{
						opened: true;
						locked: true;
						
						ToolbarButton
						{
							text: "Zapisz";
							iconSource: "../img/icons/save.svg";
							
							onTriggered:
							{
								root.saveLog();
								messageDialog.title = "Log bitwy";
								messageDialog.text = "Log został zapisany do pliku.";
								messageDialog.show();
							}
						}
					}
				}
			}
		}
	
		Page
		{
			id: settings;
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
			}
			
			// Liczba mieczników
			Label
			{
				id: swordCountLabel;
				text: "Liczba mieczników";
				anchors.verticalCenter: swordCount.verticalCenter;
				anchors.left: parent.left;
				anchors.leftMargin: units.gu(1);
				width: units.gu(20);
			}
			
			Slider
			{
				id: swordCount;
				minimumValue: 1;
				maximumValue: 30;
				anchors.top: heightSlider.bottom;
				anchors.left: swordCountLabel.right;
				anchors.leftMargin: units.gu(1);
				anchors.topMargin: units.gu(1);
				width: units.gu(20);
			}
			
			// Liczba tarczowników
			Label
			{
				id: shieldCountLabel;
				text: "Liczba tarczowników";
				anchors.verticalCenter: shieldCount.verticalCenter;
				anchors.left: parent.left;
				anchors.leftMargin: units.gu(1);
				width: units.gu(20);
			}
			
			Slider
			{
				id: shieldCount;
				minimumValue: 1;
				maximumValue: 30;
				anchors.top: swordCount.bottom;
				anchors.left: shieldCountLabel.right;
				anchors.leftMargin: units.gu(1);
				anchors.topMargin: units.gu(1);
				width: units.gu(20);
			}
			
			// Liczba łuczników
			Label
			{
				id: bowCountLabel;
				text: "Liczba łuczników";
				anchors.verticalCenter: bowCount.verticalCenter;
				anchors.left: parent.left;
				anchors.leftMargin: units.gu(1);
				width: units.gu(20);
			}
			
			Slider
			{
				id: bowCount;
				minimumValue: 1;
				maximumValue: 30;
				anchors.top: shieldCount.bottom;
				anchors.left: bowCountLabel.right;
				anchors.leftMargin: units.gu(1);
				anchors.topMargin: units.gu(1);
				width: units.gu(20);
			}
			
			// Liczba bohaterów
			Label
			{
				id: heroCountLabel;
				text: "Liczba bohaterów";
				anchors.verticalCenter: heroCount.verticalCenter;
				anchors.left: parent.left;
				anchors.leftMargin: units.gu(1);
				width: units.gu(20);
			}
			
			Slider
			{
				id: heroCount;
				minimumValue: 1;
				maximumValue: 2;
				anchors.top: bowCount.bottom;
				anchors.left: heroCountLabel.right;
				anchors.leftMargin: units.gu(1);
				anchors.topMargin: units.gu(1);
				width: units.gu(20);
			}
			
			// Tereny
			Rectangle
			{
				id: terrainsTitle;
				color: "transparent";
				width: units.gu(50);
				height: units.gu(4);
				anchors.left: heroCount.right;
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
				text: "Losuj";
				anchors.top : terrainGrid.bottom;
				anchors.horizontalCenter: terrainGrid.horizontalCenter;
				anchors.topMargin: units.gu(1);
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
						// Zapisanie ustawień
					}
				}
			}
		}
	}
	
	function updateTurnCount(count)
	{
		turnCount.text = "Czas: " + count;
	}
	
	function showBattleOverDialog(winner)
	{
		messageDialog.title = "Koniec bitwy";
		messageDialog.text = winner + " wygrywa bitwę.";
		messageDialog.show();
		
		// Ustawienie przycisku start/stop
		startstop.text = "Start";
		startstop.iconSource = "../img/icons/start.svg";
	}
	
	function log(html)
	{
		webview.loadHtml('<html><head><style type="text/css">* {font-family: Ubuntu Mono;}</style><head><body>' + html + '</body></html>');
	}
}
