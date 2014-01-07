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
	synchronized Player winner = null;  /// Zwycięzca
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
		
		players[0].addUnit(new Unit("Elf łucznik"));
		board[3][5].unit = players[0].getUnit(-1);
		board.changed[3][5] = true;
		
		players[1].addUnit(new Unit("Ork łucznik"));
		board[4][8].unit = players[1].getUnit(-1);
		board.changed[4][8] = true;
		
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
		turnCount++;
		
		for(int i = 0; ; i++)  // Pętlę przerwę z wnętrza
		{
			bool unitProcessed = false;
			
			foreach(Player p; players)  // Iterujemy po graczach - jeżeli ma tyle jednostek, ruszają się
			{
				if(i < p.units.length)
				{
					if(!p.units[i].isAlive())  // Jednostka nie żyje, pomijamy ją
						continue;
					
					p.doYourTurn(board, p.units[i]);
					unitProcessed = true;
				}
			}
			
			if(!unitProcessed)  // Jeżeli żadna jednostka nie dostała ruchu w tej iteracji, koniec kolejki
				break;
		}
		
		// Aktualizacja tablic jednostek
		foreach(Player p; players)
		{
			foreach_reverse(Unit u; p.units)
			{
				if(!u.isAlive())
				{
					p.removeUnit(u);
				}
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
		
		//TESTOWE
		if(turnCount == 100)
		{
			winner = players[0];
		}
		
		// Zwrócenie wartości
		return winner;
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
			simulator.sleep(dur!("msecs")(500));  // Metoda szablonowa dur zwraca wartość Duration
		}
		
		if(winner !is null)
			ui.battleOver(winner.name);
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
