/**
 * Moduł odpowiada za graczy.
 * Zawiera klasę player, po której dziedziczą gracze (np. człowiek lub AI.
 */
module players;

import board;
import main;
import terrains;
import units;
import utils;

import std.conv;
import std.math;
import std.stdio;

/**
 * Klasa reprezentuje gracza komputerowego.
 */
class AIPlayer : Player
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
	 * Wykonuje kolejkę.
	 * Params:
	 * board = Plansza
	 * players = Lista graczy
	 * phase = Faza (0 - ruch, 1 - strzały, 2 - walki, 3 - test odwagi)
	 */
	public override void doYourTurn(Board board, Player[] players, int phase)
	{
		final switch(phase)
		{
			case 0:  // RUCH
			{
				foreach(Unit unit; units)
				{
					int targetX = -1;
					int targetY = -1;
					double bestMark = -double.infinity;
					
					Terrain currentTerrain = board[unit.y][unit.x].terrain;
					
					for(int i = unit.y - currentTerrain.getParamValue(unit, "movement"); i < unit.y + currentTerrain.getParamValue(unit, "movement"); i++)
					{
						for(int j = unit.x - currentTerrain.getParamValue(unit, "movement"); j < unit.x + currentTerrain.getParamValue(unit, "movement"); j++)
						{
							if(i < 0 || i >= board.fields.length || j < 0 || j >= board[0].length)  // Odrzuć pola poza planszą
								continue;
								
							if(board.distance(unit.y, unit.x, i, j) > currentTerrain.getParamValue(unit, "movement"))  // Odrzuć pola poza zasięgiem
								continue;
							
							if(board[i][j].unit !is null && board[i][j].unit != this)  // Odrzuć pola zajęte
								continue;
							
							// Wyznaczamy odległość od najbliższego wroga
							double lowestEnemyDistance = double.infinity;
							
							foreach(Player p; players)
							{
								if(p == this)
								{
									continue;
								}
								
								foreach(Unit target; p.units)
								{
									double dist = board.distance(i, j, target.y, target.x);
									dist = dist < 2 ? 0 : dist;  // Jeżeli stoisz koło wroga, odległość można potraktować jak zero
									
									lowestEnemyDistance = dist < lowestEnemyDistance ? dist : lowestEnemyDistance;
								}
							}
							
							// Określamy bonusy
							int distanceDodgeBonus = sgn(board[i][j].terrain.getParamValue(unit, "distanceDodge") -
										board[unit.y][unit.x].terrain.getParamValue(unit, "distanceDodge"));
							
							int rangeBonus = 0;
							if(unit.isShooter())
							{
								rangeBonus = sgn(board[i][j].terrain.getParamValue(unit, "range") -
											board[unit.y][unit.x].terrain.getParamValue(unit, "range"));
							}
							
							// Sprawdzamy, czy są koledzy na polach przylegających do badenego
							bool hasFriends = false;
							
							for(int k = i-1; k <= i+1; k++)
							{
								for(int l = j-1; l < j+1; l++)
								{
									if(k < 0 || k >= board.fields.length || l < 0 || l >= board[0].length)
										continue;
										
									if(board[k][l].unit is null)
										continue;
										
									if(board[k][l].unit.owner == this)
										hasFriends = true;
								}
							}
							
							// Obliczamy punktację
							double mark = 0;
							
							if(unit.isShooter())
							{
								mark = lowestEnemyDistance < (board[i][j].terrain.getParamValue(unit, "range")) ?
										100 - lowestEnemyDistance : -3*lowestEnemyDistance;
								
								mark += 10*distanceDodgeBonus + 20*rangeBonus + (hasFriends ? 0 : -10);
							}
							else
							{
								mark = -3*lowestEnemyDistance + 10*distanceDodgeBonus + (hasFriends ? 0 : -10);
							}
							
							if(mark > bestMark)
							{
								bestMark = mark;
								targetY = i;
								targetX = j;
							}
							
							if(mark == bestMark && i == unit.y && j == unit.x)  // Nie ruszaj się, jeżeli nie ma lepszego pola
							{
								bestMark = mark;
								targetY = i;
								targetX = j;
							}
						}
					}
					
					unit.move(board, targetY, targetX);
				}
				break;
			}
			
			case 1:  // STRZAŁY
			{
				foreach(Unit unit; units)
				{
					if(!unit.isShooter())  // Tylko strzelający.
						continue;
					
					if(!unit.canShoot())  // Dana jednostka nie może już strzeać
						continue;
					
					Unit bestTarget = null;
					double bestMark = -double.infinity;
					
					// Wyznaczamy odległość od celu
					foreach(Player p; players)
					{
						if(p == this)
							continue;
						
						foreach(Unit target; p.units)
						{
							double dist = board.distance(unit.y, unit.x, target.y, target.x);
							
							if(dist > board[unit.y][unit.x].terrain.getParamValue(unit, "range"))
							{
								continue;
							}
							
							double mark = -1 * dist + (target.isHero() ? 30 : 0) + (target.isShooter() ? 10 : 0);
								
							if(mark > bestMark)
							{
								bestMark = mark;
								bestTarget = target;
							}
						}
					}
					
					if(bestTarget !is null)
					{
						unit.shoot(board, bestTarget);
					}
				}
				break;
			}
			
			case 2:  // WALKI
			{
				foreach(Unit unit; units)
				{
					if(!unit.canFight())
						continue;
					
					Unit bestTarget = null;
					int bestMark = 0;  // będzie 1 dla jednostki, 2 dla strzelca i 3 dla bohatera
					
					for(int i = unit.y-1; i <= unit.y+1; i++)
					{
						for(int j = unit.x-1; j < unit.x+1; j++)
						{
							if(i < 0 || i >= board.fields.length || j < 0 || j >= board.fields[0].length)
								continue;
							
							if(board[i][j].unit !is null)
							{
								if(board[i][j].unit.owner == this)
									continue;
								
								if(board[i][j].unit.isHero && bestMark < 3)
								{
									bestMark = 3;
									bestTarget = board[i][j].unit;
								}
								if(board[i][j].unit.isShooter && bestMark < 2)
								{
									bestMark = 2;
									bestTarget = board[i][j].unit;
								}
								else if(bestMark < 1)
								{
									bestTarget = board[i][j].unit;
								}
							}
						}
					}
					if(bestTarget !is null)
					{
						unit.attack(board, bestTarget);
					}
				}
				break;
			}
			
			case 3:  // ODWAGA
			{
				if(!courageTestDone && units.length < initialCount/2)
				{
					foreach_reverse(Unit unit; units)
					{
						if(rollK6() + rollK6() + unit.params["courage"] < 10)
						{
							unit.runAway(board);
						}
					}
					
					courageTestDone = true;
				}
				break;
			}
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
	int initialCount;  /// Początkowa liczebność armii
	bool courageTestDone;  /// Czy był już test odwagi
	
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
	 * players = Lista graczy
	 * phase = Faza (1 - ruch, 2 - strzały, 3 - walki, 4 - test odwagi)
	 */
	public void doYourTurn(Board board, Player[] players, int phase);
	
	/**
	 * Dodaje jednostkę gracza.
	 * Params:
	 * unit = Jednostka
	 */
	public void addUnit(Unit unit)
	{
		units ~= unit;
		unit.owner = this;
		unit.index = to!(int)(units.length);
		
		initialCount++;
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
