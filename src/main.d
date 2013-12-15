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

import std.array;
import std.file;
import std.path;
import std.stdio;
import std.string;

/**
 * Główna klasa programu - zawiera wszystkie ważne obiekty, łączy wszystkie moduły.
 */
class Main
{
	Terrain[string] terrains;  /// Tablica asocjacyjna terenów indeksowana nazwami.
	Player[] players;  /// Tablica graczy
	Board board;  /// Plansza symulacji
	
	/**
	 * Wczytuje konfigurację programu, tworzy wymagane obiekty oraz GUI (umieszczone
	 * w oddzielnym module napisanym w C++/QML).
	 */
	this()
	{
		// Wczytanie konfiguracji
		terrains = loadTerrains("config/rules.xml");
		loadUnitConfig("config/units");
		
		// Utworzenie interfejsu
		UIController ui = new UIController();
		
		// ==============================================================================
		/* Ten kod tworzy jakąś domyślną symulację. Bardzo możliwe, że zostanie on
		 * zamieniony na wczytywanie parametrów symulacji z pliku, konsoli lub jakiegoś
		 * formularza w UI.
		 */
		Board board = new Board(27, 13, terrains["grass"]);
		ui.board = board;
		
		players ~= new Player("Gracz 1", "#ff0000", "#800000");
		players ~= new Player("Gracz 2", "#0000ff", "#000080");
		
		for(int i = 3; i < 8; i++)
		{
			for(int j = 5; j < 7; j++)
			{
				players[0].addUnit(new Unit("Elf łucznik"));
				board[i][j].unit = players[0].getUnit(-1);
			}
		}
		
		for(int i = 3; i < 8; i++)
		{
			for(int j = 15; j < 17; j++)
			{
				players[1].addUnit(new Unit("Elf łucznik"));
				board[i][j].unit = players[1].getUnit(-1);
			}
		}
		
		ui.updateBoard();
		
		// ==============================================================================
		
		// Uruchomienie interfejsu
		ui.run();
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
