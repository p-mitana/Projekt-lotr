/**
 * Główny moduł projektu. Łączy całą funkcjonalność programu i komunikuje 
 * się z modułem grafiki C++/QML.
 */
module main;

import board;
import players;
import terrains;
import units;
import ui;
import utils;

import core.thread;
import core.time;

import std.array;
import std.conv;
import std.datetime;
import std.file;
import std.math;
import std.path;
import std.random;
import std.stdio;
import std.string;
	
static shared(string) log;  /// Kod HTML loga

/**
 * Główna klasa programu - zawiera wszystkie ważne obiekty, łączy wszystkie moduły.
 */
class Main : UICallback
{
	Terrain[string] terrains;  /// Tablica asocjacyjna terenów indeksowana nazwami.
	synchronized Player[] players;  /// Tablica graczy
	synchronized Player winner = null;  /// Zwycięzca
	synchronized Board board;  /// Plansza symulacji
	synchronized UIController ui;  /// Kontroler interfejsu użytkownika
	synchronized int turnCount = 0;  /// Licznik tur
	synchronized int sleepTime = 250;  /// Czas między kolejkami
	synchronized int startingIndex = 0;  /// Indeks rozpoczynającego gracza - domyślnie gracz 1
	
	Thread simulator;  /// Wątek odpowiedzialny za wykonywanie obliczeń
	synchronized bool interrupt;  /// Należy ustawić, żeby przerwać symulację
	
	// Parametry symulacji
	int boardWidth = 70;  /// Szerokość planszy
	int boardHeight = 50;  /// Wysokość planszy
	int eSwordCount = 15;  /// Elfowie - Ilość szermierzy
	int eBowCount = 12;  /// Elfowie - Ilość łuczników
	int eShieldCount = 15;  /// Elfowie - Ilość tarczowników
	int eHeroCount = 2;  /// Elfowie - Ilość bohaterów
	int oSwordCount = 20;  /// Orkowie - Ilość szermierzy
	int oBowCount = 18;  /// Orkowie - Ilość łuczników
	int oShieldCount = 20;  /// IOrkowie - lość tarczowników
	int oHeroCount = 2;  /// Orkowie - Ilość bohaterów
	Terrain[9] sectorTerrains;  /// Tereny w sektorach
	string[] terrainNames = ["grass", "forest", "swamp", "hill", "ruins"];  /// Nazwy terenów, które losujemy
	
	/**
	 * Wczytuje konfigurację programu, tworzy wymagane obiekty oraz GUI (umieszczone
	 * w oddzielnym module napisanym w C++/QML).
	 */
	this()
	{
		// Wczytanie konfiguracji
		terrains = loadTerrains("config/rules.xml");
		loadUnitConfig("config/units");
		
		// Utworzenie wątku symulującego
		simulator = new Thread(&runSimulation);
		
		// Utworzenie interfejsu
		ui = new UIController(this);
		
		// Utworzenie symmulacji
		initSimulation(true, true);
		
		// Uruchomienie interfejsu
		ui.run();
	}
	
	/* ---------- METODY ZWIĄZANE Z PZEPROWADZANIEM SYMULACJI I JEJ WĄTKIEM ---------- */
	
	/**
	 * Inicjalizuje/resetuje symulację
	 * 
	 * Params:
	 * resetBoard = Czy resetujemy planszę?
	 * randomTerrains = Czy generujemy nową listę terenów?
	 */
	void initSimulation(bool resetBoard, bool randomTerrains = false)
	{
		// Przerwanie symulacji
		interrupt = true;
		winner = null;
		
		while(simulator.isRunning())
		{
			Thread.getThis().sleep(dur!("msecs")(10));
		}
		
		
		if(resetBoard)
		{
			// Losowanie terenów  (50% szans na trawę, 50% szans na inny teren)
			
			if(randomTerrains)
			{
				for(int i = 0; i < 9; i++)
				{
					int rand = cast(int) uniform!("[]")(0, 2*terrains.length-2);
					
					if(rand < terrains.length)
					{
						sectorTerrains[i] = new Terrain(terrains[terrainNames[rand]]);
						
						if(sectorTerrains[i].name == "hill")
						{
							sectorTerrains[i].params["height"] = uniform!("[]")(1, 5);
						}
					}
				}
			}
			// Tworzymy planszę
			board = new Board(boardWidth, boardHeight, terrains["grass"], sectorTerrains);
			ui.board = board;
		}
		
		else  // Czyścimy jednostki, jeżeli nie resetujemy planszy
		{
			foreach(int i, Field[] row; board.fields)
			{
				foreach(int j, Field field; row)
				{
					if(field.unit !is null)
					{
						field.unit = null;
						board.changed[i][j] = true;
					}
				}
			}
		}
		
		// Tworzymy graczy
		players.length = 0;
		players ~= new AIPlayer("Gracz 1", "#00f000", "#008000");
		players ~= new AIPlayer("Gracz 2", "#ff0000", "#800000");
		
		int offset = 1;
		
		// Ustawiamy łuczników
		for(int i = 0; i < fmax(eBowCount, oBowCount); i++)
		{
			if(i < eBowCount)
			{
				players[0].addUnit(new Unit("Elf łucznik"));
				board[board.height/2 - 5 + i%10][offset+i/10].unit = players[0].getUnit(-1);
				board.changed[board.height/2 - 5 + i%10][offset+i/10] = true;
			}
			
			if(i < oBowCount)
			{
				players[1].addUnit(new Unit("Ork łucznik"));
				board[board.height/2 - 5 + i%10][board.width-offset-1-i/10].unit = players[1].getUnit(-1);
				board.changed[board.height/2 - 5 + i%10][board.width-offset-1-i/10] = true;
			}
		}
		
		offset += fmax(eBowCount, oBowCount)/10 + 2;
		
		// Ustawiamy bohaterów
		if(eHeroCount == 1)
		{
			players[0].addUnit(new Unit("Elrond"));
			board[board.height/2][offset].unit = players[0].getUnit(-1);
			board.changed[board.height/2][offset] = true;
		}
		
		else if(eHeroCount == 2)
		{
			players[0].addUnit(new Unit("Elrond"));
			board[board.height/2-3][offset].unit = players[0].getUnit(-1);
			board.changed[board.height/2-3][offset] = true;
			
			players[0].addUnit(new Unit("Legolas"));
			board[board.height/2+3][offset].unit = players[0].getUnit(-1);
			board.changed[board.height/2+3][offset] = true;
		}
		
		if(oHeroCount == 1)
		{
			players[1].addUnit(new Unit("Gothmog"));
			board[board.height/2][board.width-offset-1].unit = players[1].getUnit(-1);
			board.changed[board.height/2][board.width-offset-1] = true;
		}
		
		else if(oHeroCount == 2)
		{
			players[1].addUnit(new Unit("Gothmog"));
			board[board.height/2-3][board.width-offset-1].unit = players[1].getUnit(-1);
			board.changed[board.height/2-3][board.width-offset-1] = true;
			
			players[1].addUnit(new Unit("Usta Saurona"));
			board[board.height/2+3][board.width-offset-1].unit = players[1].getUnit(-1);
			board.changed[board.height/2+3][board.width-offset-1] = true;
		}
		
		offset += 3;
		
		// Ustawiamy mieczników
		for(int i = 0; i < fmax(eSwordCount, oSwordCount); i++)
		{
			if(i < eSwordCount)
			{
				players[0].addUnit(new Unit("Elf miecznik"));
				board[board.height/2 - 5 + i%10][offset+i/10].unit = players[0].getUnit(-1);
				board.changed[board.height/2 - 5 + i%10][offset+i/10] = true;
			}
			
			if(i < oSwordCount)
			{
				players[1].addUnit(new Unit("Ork miecznik"));
				board[board.height/2 - 5 + i%10][board.width-offset-1-i/10].unit = players[1].getUnit(-1);
				board.changed[board.height/2 - 5 + i%10][board.width-offset-1-i/10] = true;
			}
		}
		
		offset += fmax(eSwordCount, oSwordCount)/10 + 2;
		
		// Ustawiamy tarczowników
		for(int i = 0; i < fmax(eShieldCount, oShieldCount); i++)
		{
			if(i < eShieldCount)
			{
				players[0].addUnit(new Unit("Elf tarczownik"));
				board[board.height/2 - 5 + i%10][offset+i/10].unit = players[0].getUnit(-1);
				board.changed[board.height/2 - 5 + i%10][offset+i/10] = true;
			}
			
			if(i < oShieldCount)
			{
				players[1].addUnit(new Unit("Ork tarczownik"));
				board[board.height/2 - 5 + i%10][board.width-offset-1-i/10].unit = players[1].getUnit(-1);
				board.changed[board.height/2 - 5 + i%10][board.width-offset-1-i/10] = true;
			}
		}
		
		// Czyścimy log i licznik tur
		log = "";
		turnCount = 0;
		
		// Aktualizujemy interfejs
		ui.updateBoard();
		ui.turnCompleted(turnCount);
		ui.log(log);
	}

	
	/**
	 * Wykonuje jedną kolejkę symulacji.
	 */
	void nextTurn()
	{
		turnCount++;
		
		log ~= format(`<div style="font-size: 24px;">Tura %d</div>`, turnCount);
		
		// Określenie gracza zaczynającego
		int player1roll = rollK6();
		int player2roll = rollK6();
		
		if(player2roll > player1roll || (player2roll == player1roll && turnCount > 1))
		{
			Player p = players[0];
			players[0] = players[1];
			players[1] = p;
		}
		
		// 4 fazy: ruch-strzał-walka-test odwagi
		for(int i = 0; i <= 3; i++)
		{
			foreach(Player p; players)  // Iterujemy po graczach - jeżeli ma tyle jednostek, ruszają się
			{
				if(i == 0)
				{
					foreach(Unit u; p.units)
					{
						u.canFight = true;
						u.canShoot = true;
					}
				}
				
				p.doYourTurn(board, players, i);
			}
		}
		
		// Sprawdzenie wyniku bitwy (zwycięztwo, gdy tylko jeden gracz ma jednostki)
		int playersAlive = 0;
		
		foreach(Player p; players)
		{
			if(p.units.length > 0)
			{
				playersAlive++;
				winner = p;
			}
		}
		
		if(playersAlive > 1)
			winner = null;
		
		// Aktualizacja interfejsu
		ui.updateBoard();
		ui.turnCompleted(turnCount);
		
		if(winner !is null)
		{
			log ~= format(`<div style="font-size: 24px;"><span style="color: %s;">%s</span> wygrywa bitwę.</div>`,
					winner.color1, winner.name);
					
			ui.battleOver(winner.name);
		}
		
		// Aktualizacja loga
		ui.log(log);
	}
	
	/**
	 * Metoda symulująca, wywołuje kolejną kolejkę co chwilę.
	 */
	void runSimulation()
	{
		interrupt = false;
		
		while(winner is null && !interrupt)
		{
			nextTurn();
			simulator.sleep(dur!("msecs")(sleepTime));  // Metoda szablonowa dur zwraca wartość Duration
		}
	}
	
	
	/* ---------- METODY INTERFEJSU UICallback ---------- */
	
	/**
	 * Rozpoczyna symulację.
	 */
	extern(C++) void simulationStart()
	{
		if(!simulator.isRunning())
		{
			simulator.start();
		}
	}
	
	/**
	 * Zatrzymuje symulację.
	 */
	extern(C++) void simulationStop()
	{
		interrupt = true;
	}
	
	/**
	 * Wykonuje krok.
	 */
	extern(C++) void simulationStep()
	{
		if(winner is null)
		{
			nextTurn();
		}
		else
		{
			ui.battleOver(winner.name);
		}
	}
	
	/**
	 * Resetuje symulację.
	 */
	extern(C++) void simulationReset()
	{
		initSimulation(false);  // Bez resetowania planszy
	}
	
	/**
	 * Zapisuje loga.
	 */
	extern(C++) void saveLog()
	{
		string toSave = `<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
				<style type="text/css">* {font-family: Ubuntu Mono;}</style><head><body>` ~ log ~ `</body></html>`;
		
		auto time = Clock.currTime();
		time.fracSec = FracSec.zero();
		string filename = time.toSimpleString();
		std.file.write("log/" ~ filename ~ ".html", toSave);
	}
	
	/**
	 * Powiększa.
	 */
	extern(C++) void zoomIn()
	{
		ui.zoomIn();
	}
	
	/**
	 * Pomniejsza.
	 */
	extern(C++) void zoomOut()
	{
		ui.zoomOut();
	}
	
	/**
	 * Otwiera ustawienia.
	 */
	extern(C++) void loadSettings()
	{
		// Rozmiar planszy
		string params = format("%d;%d;", boardWidth, boardHeight);
		
		// Liczby jednostek
		params ~= format("%d;%d;%d;%d;%d;%d;%d;%d;", eSwordCount, eBowCount, eShieldCount,
						eHeroCount, oSwordCount, oBowCount, oShieldCount, oHeroCount);
		
		// Rozkład terenów
		foreach(Terrain t; sectorTerrains)
		{
			params ~= format("%s;", t is null ? "grass" : t.name);
		}
		
		// Losowanie poszczególnych terenów
		int grass = 0, forest = 0, swamp = 0, hill = 0, ruins = 0;
		
		foreach(name; terrainNames)
		{
			if(name == "grass")
				grass = 1;
				
			if(name == "forest")
				forest = 1;
				
			if(name == "swamp")
				swamp = 1;
				
			if(name == "hill")
				hill = 1;
				
			if(name == "ruins")
				ruins = 1;
		}
		
		params ~= format("%d;%d;%d;%d;%d", grass, forest, swamp, hill, ruins);
		
		ui.openSettings(params);
	}
	
	/**
	 * Zapisuje ustawienia
	 */
	extern(C++) void saveSettings(immutable(char)* c_params)
	{
		string[] params = to!(string)(c_params).split(";");
		
		int i=0;
		
		// Rozmiar planszy
		boardWidth = to!(int)(params[i++]);
		boardHeight = to!(int)(params[i++]);
		
		// Ilość jednostek
		eSwordCount = to!(int)(params[i++]);
		eBowCount = to!(int)(params[i++]);
		eShieldCount = to!(int)(params[i++]);
		eHeroCount = to!(int)(params[i++]);
		oSwordCount = to!(int)(params[i++]);
		oBowCount = to!(int)(params[i++]);
		oShieldCount = to!(int)(params[i++]);
		oHeroCount = to!(int)(params[i++]);
		
		// Tereny
		for(int j = 0; j < 9; j++)
		{
			sectorTerrains[j] = new Terrain(params[i], "img/terrains/" ~ params[i++] ~ ".png");
		}
		
		// Zaznaczone pola losowania
		terrainNames.length = 0;
		
		if(params[i++] == "1")
			terrainNames ~= "grass";
		
		if(params[i++] == "1")
			terrainNames ~= "forest";
		
		if(params[i++] == "1")
			terrainNames ~= "swamp";
		
		if(params[i++] == "1")
			terrainNames ~= "hill";
		
		if(params[i++] == "1")
			terrainNames ~= "ruins";
		
		// Reset symulacji i zamknięcie karty ustawień
		initSimulation(true);
		ui.closeSettings();
	}
}

/**
 * Startowa funkcja programu.
 * 
 * Params:
 * args = Argumenty wiersza poleceń
 */
void main(string[] args)
{
	// Ustawię ścieżkę aktualnego katalogu w głównym katalogu projektu
	string path = thisExePath().dirName();
	chdir(path ~ "/..");
	
	Main main = new Main();
}
