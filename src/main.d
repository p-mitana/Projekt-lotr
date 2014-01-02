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

import core.thread;

import std.array;
import std.file;
import std.path;
import std.stdio;
import std.string;

/**
 * Główna klasa programu - zawiera wszystkie ważne obiekty, łączy wszystkie moduły.
 */
class Main : UICallback
{
	Terrain[string] terrains;  /// Tablica asocjacyjna terenów indeksowana nazwami.
	Player[] players;  /// Tablica graczy
	synchronized Board board;  /// Plansza symulacji
	synchronized UIController ui;  /// Kontroler interfejsu użytkownika
	synchronized int turnCount = 0;  /// Licznik tur
	
	Thread simulator;  /// Wątek odpowiedzialny za wykonywanie obliczeń
	synchronized bool interrupt;  /// Należy ustawić, żeby przerwać symulację
	
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
		
		// ==============================================================================
		/* Ten kod tworzy jakąś domyślną symulację. Bardzo możliwe, że zostanie on
		 * zamieniony na wczytywanie parametrów symulacji z pliku, konsoli lub jakiegoś
		 * formularza w UI.
		 */
		board = new Board(70, 50, terrains["grass"]);
		ui.board = board;
		
		players ~= new TestPlayer("Gracz 1", "#ff0000", "#800000");
		players ~= new TestPlayer("Gracz 2", "#0000ff", "#000080");
		
		for(int i = 3; i < 8; i++)
		{
			for(int j = 5; j < 7; j++)
			{
				players[0].addUnit(new Unit("Elf łucznik"));
				board[i][j].unit = players[0].getUnit(-1);
				board.changed[i][j] = true;
			}
		}
		
		for(int i = 3; i < 8; i++)
		{
			for(int j = 15; j < 17; j++)
			{
				players[1].addUnit(new Unit("Ork łucznik"));
				board[i][j].unit = players[1].getUnit(-1);
				board.changed[i][j] = true;
			}
		}
		
		ui.updateBoard();
		
		// ==============================================================================
		
		// Uruchomienie interfejsu
		ui.run();
	}
	
	
	/* ---------- METODY ZWIĄZANE Z PZEPROWADZANIEM SYMULACJI I JEJ WĄTKIEM ---------- */
	
	/**
	 * Wykonuje jedną kolejkę symulacji.
	 *
	 * Returns:
	 * Zwycięzki gracz
	 */
	Player nextTurn()
	{
		Player winner = null;
		turnCount++;
		
		// Wykonanie ruchu
		foreach(Player p; players)
		{
			p.doYourTurn(board);
		}
		
		// Aktualizacja interfejsu
		ui.updateBoard();
		ui.turnCompleted(turnCount);
		
		//TESTOWE
		if(turnCount == 100)
		{
			return players[0];
		}
		
		// Zwrócenie wartości
		return winner;
	}
	
	/**
	 * Metoda symulująca, wywołuje kolejną kolejkę co chwilę.
	 */
	void runSimulation()
	{
		Player winner = null;
		interrupt = false;
		
		while(winner is null && !interrupt)
		{
			nextTurn();
			simulator.sleep(dur!("msecs")(500));  // Metoda szablonowa dur zwraca wartość Duration
		}
		
		if(winner)
		{
			// ktoś wygrał
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
	 * Rozpoczyna symulację.
	 */
	
	extern(C++) void simulationStep()
	{
		nextTurn();
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
