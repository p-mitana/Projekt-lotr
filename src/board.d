/**
 * Moduł obsługujący planszę i pola.
 */
module board;

import terrains;
import units;

import std.math;
import std.stdio;

/**
 * Klasa reprezentuje planszę prostokątną o zadanych wymiarach.
 * Konstruktory tej planszy odpowiadają za generowanie planszy na
 * podstawie różnych kryteriów.
 * 
 * Do pól planszy można dostać się za pośrednictwem konstrukcji
 * board[x][y] - zapewnia to przeciążenie operatora [].
 */
class Board
{
	Field[][] fields;  /// Pola
	bool[][] changed;  /// Określa, czy zmieniono. Resetowane w updateBoard
	
	/**
	 * Podstawowy konstruktor. Generuje planszę o wymiarach X na Y
	 * pól i podanym jednolitym terenie.
	 * Params:
	 * h = Szerokość planszy
	 * w = Wysokość planszy
	 * terrain = Teren pokrywający planszę
	 */
	public this(int w, int h, Terrain terrain)
	{
		fields.length = h;
		changed.length = h;
		foreach(int i, ref Field[] row; fields)  // Iterujemy po referencjach, bo będziemy modyfikować.
		{
			row.length = w;
			changed[i].length = w;
			
			foreach(ref Field field; row)
			{
				field = new Field(terrain);
			}
		}
	}
	
	/**
	 * Zwraca do parametrów pozycję jednostki na planszy
	 * Params:
	 * Unit = jednostka
	 * y = tam zostanie zapisania współrzędna Y
	 * x = tam zostanie zapisania współrzędna X
	*/
	void getUnitPosition(Unit unit, out int y, out int x)
	{
		y = -1;
		x = -1;
		
		foreach(int i, Field[] row; fields)
		{
			foreach(int j, Field field; row)
			{
				if(unit is field.unit)
				{
					y = i;
					x = j;
					return;
				}
			}
		}
	}
	
	/**
	 * Zwraca odległość między punktami
	 * Params:
	 * y1 = Współrzędna Y punktu 1
	 * y2 = Współrzędna Y punktu 2
	 * x1 = Współrzędna X punktu 1
	 * x2 = Współrzędna X punktu 2
	 * straight = czy mierzymy w linii prostej
	 * Returns:
	 * Odległość między polami
	 */
	double distance(int y1, int x1, int y2, int x2, bool straight = true)  // TODO: Zmienić straight na false
	{
		if(straight)
			return sqrt(pow(abs(y1-y2), 2.0) + pow(abs(x1-x2), 2.0));
		
		else
			return -1.0;
	}
	
	/**
	 * Przeciążenie operatora [] - umożliwia pobieranie pól za pomocą
	 * wywołania postaci board[x][y].
	 */
	Field[] opIndex(int index)
	{
		return fields[index];
	}
	
	// Funkcje własności - choć nie ma zmiennych, zwrócą wymiary
	public @property int width() {return cast(int) (fields.length > 0 ? fields[0].length : 0);}  /// Zwraca szerokość planszy
	public @property int height() {return cast(int) (fields.length);}  /// Zwraca wysokość planszy
}

/**
 * Klasa reprezentuje pole planszy.
 * Pole zawiera określony teren oraz jednostkę, która na nim stoi.
 */
class Field
{
	private Terrain v_terrain;  /// Teren
	private Unit v_unit;  /// Jednostka stojąca na polu
	
	/**
	 * Konstruktor pola.
	 * Params:
	 * terrain = Teren
	 * unit = Jednostka na tym polu
	 */
	public this(Terrain terrain, Unit unit = null)
	{
		v_terrain = terrain;
		v_unit = unit;
	}
	
	// Funkcje własności
	public @property Terrain terrain() {return v_terrain;}  /// Zwraca teren na tym polu
	public @property Terrain terrain(Terrain terrain) {return v_terrain = terrain;}  // Ustawia teren na tym polu
	
	public @property Unit unit() {return v_unit;}  /// Zwraca jednostkę na tym polu
	public @property Unit unit(Unit unit) {return v_unit = unit;}  // Ustawia jednostkę na tym polu
}
