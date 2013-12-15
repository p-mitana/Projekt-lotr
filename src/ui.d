/**
 * Moduł odpowiada za integrację z interfejsem graficznym tworzonym
 * w językach C++/QML z wykorzystaniem biblioteki Qt 5.x oraz Ubuntu SDK.
 */
module ui;

import board;

import std.stdio;
import std.string;

/**
 * Klasa D kontrolująca interfejs użytkownika. Zajmuje się ona przetwarzaniem
 * przetwarzaniem poleceń dla interfejsu użytkownika i wywoływaniem bardziej
 * niskopoziomowych metod klasy UILink. Konwertuje też typy danych do typów
 * C++.
 */
class UIController
{
	private UILink link;  /// Łącznik między językami D i C++.
	private Board v_board;  /// Plansza
	
	/**
	 * Konstruktor kontrolera
	 */
	public this()
	{
		link = createUI();
	}
	
	/**
	 * Uruchamia interfejs użytkownika.
	 */
	public void run()
	{
		link.run();
	}
	
	/**
	 * Aktualizuje planszę
	 */
	public void updateBoard()
	{
		foreach(int y, Field[] row; v_board.fields)
		{
			foreach(int x, Field field; row)
			{
				if(board.changed[y][x])
				{
					
					if(field.unit !is null)
						link.insertUnit(y, x, toStringz(field.unit.imagePath), 
								toStringz(field.unit.owner.color1), toStringz(field.unit.owner.color2));
				
					else
						link.clearField(y, x);
				}
				
				board.changed[y][x] = false;
			}
		}
	}
	
	// Funkcje własności
	
	/// Ustawia planszę. Powoduje usunięcie planszy i utworzenie jej na nowo.
	public @property Board board(Board board)
	{
		v_board = board;
		
		link.initBoard(v_board.width, v_board.height);
		
		foreach(int y, Field[] row; v_board.fields)
		{
			foreach(int x, Field field; row)
			{
				link.appendField(y, x, toStringz(field.terrain.imagePath));
			}

		}
		
		return v_board;
	}
	
	/// Zwraca planszę
	public @property Board board()
	{
		return v_board;
	}
}

/**
 * Interfejs opakowujący C++'ową klasę UI. Klasa za przechowuje i kontroluje
 * wszystkie obiekty Qt, komunikując się z głównym programem w D.
 */
extern(C++) interface UILink
{
	void run();  /// Uruchamia interfejs użytkownika.
	void initBoard(int width, int height);  /// Inicjalizuje planszę o zadanych wymiarach
	void appendField(int y, int x, immutable(char)* imagePath);  /// Dodaje pole
	void clearField(int y, int x);  /// Usuwa jednostkę z pola
	void insertUnit(int y, int x, immutable(char)* imagePath, immutable(char)* color1, immutable(char)* color2);  /// Ustawia jednostkę w polu
}

/**
 * Funkcja C++ tworząca interfejs.
 */
extern(C++) UILink createUI();
