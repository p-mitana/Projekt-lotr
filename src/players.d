/**
 * Moduł odpowiada za graczy.
 * Zawiera klasę player, po której dziedziczą gracze (np. człowiek lub AI.
 */
module players;

import board;
import units;

import std.stdio;

/**
 * Klasa reprezentuje testowego gracza.
 */
class TestPlayer : Player
{
	/**
	 * Konstruktor gracza.
	 * Params:
	 * name = Nazwa gracza
	 * color1 = Górny kolor gradientu gracza
	 * color2 = Dolny kolor gradientu gracza
	 */
	public this(string name, string color1, string color2)
	{
		super(name, color1, color2);
	}
	
	/**
	 * Wykonuje swoją kolejkę.
	 * Params:
	 * board = Plansza
	 */
	public override void doYourTurn(Board board, Unit unit)
	{
		if(name == "Gracz 1")
		{
			unit.attack(board, board[4][8].unit);
		}
		else
		{
		}
	}
}

/**
 * Bazowa, abstrakcyjna klasa reprezentuje gracza.
 */
abstract class Player
{
	private string v_name = "Gracz";  /// Nazwa gracza
	private string v_color1 = "#ff0000";  /// Pierwszy kolor gracza
	private string v_color2 = "#800000";  /// Drugi kolor gracza
	Unit[] units;  /// Jednostki gracza
	
	/*
	 * Mimo faktu, że klasa jest abstrakcyjna, konstruktor jest,
	 * celem wywołania go z klasy podrzędnej.
	 */
	
	/**
	 * Konstruktor gracza.
	 * 
	 * Params:
	 * name = Nazwa gracza
	 * color1 = Górny kolor gradientu gracza
	 * color2 = Dolny kolor gradientu gracza
	 */
	public this(string name, string color1, string color2)
	{
		v_name = name;
		v_color1 = color1;
		v_color2 = color2;
	}
	
	/**
	 * Wykonuje kolejkę.
	 * Params:
	 * board = Plansza
	 */
	public void doYourTurn(Board board, Unit unit);
	
	/**
	 * Dodaje jednostkę gracza.
	 * Params:
	 * unit = Jednostka
	 */
	public void addUnit(Unit unit)
	{
		units ~= unit;
		unit.owner = this;
	}
	
	/**
	 * Usuwa jednostkę gracza.
	 * Params:
	 * unit = Jednostka
	 */
	public void removeUnit(Unit unit)
	{
		for(int i = 0; i < units.length; i++)
		{
			if(units[i] is unit)  // Porównujemy obiekty
			{
				units = units[0..i] ~ units[i+1..$];
				unit.owner = null;
				return;
			}
		}
	}
	
	/**
	 * Zwraca jednostkę gracza
	 * Params:
	 * index = indeks jednostki. Jeżeli jest ujemny, zwraca jednostkę length-abs(index).
	 * Returns:
	 * Jednostka
	 */
	public Unit getUnit(int index)
	{
		if(index < 0)
			index = cast(int) units.length + index;
		
		return units[index];
	}
	
	// Funkcje własności
	
	public @property string name() {return v_name;}  /// Zwraca nazwę jednostki
	public @property string name(string name) {return v_name = name;}  /// Ustawia nazwę jednostki
	
	public @property string color1() {return v_color1;}  /// Zwraca górny kolor gradientu
	public @property string color1(string color1) {return v_color1 = color1;}  /// Ustawia górny kolor gradientu
	
	public @property string color2() {return v_color2;}  /// Zwraca dolny kolor gradientu
	public @property string color2(string color2) {return v_color2 = color2;}  /// Ustawia dolny kolor gradientu
}
