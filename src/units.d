/**
 * Moduł zajmuje się obsługą jednostek. Zawiera klasę obsługującą
 * jednostkę oraz funkcję wczytującą jednostki.
 */
module units;

import board;
import players;
import utils;

import std.array;
import std.conv;
import std.file;
import std.random;
import std.string;
import std.stdio;
import std.xml;

/**
 * Tablica asocjacyjna wiążąca nazwę jednostki z plikiem konfiguracyjnym.
 */
string[string] unitConfig;

/**
 * Reprezentuje jednostkę.
 */
class Unit
{
	private string v_name;  /// Nazwa jednostki
	private string v_race;  /// Rasa
	private string v_imagePath;  /// Ścieżka do obrazka
	private Player v_owner;  /// Właściciel
	int[string] params;  /// Parametry
	string[] abilities;  /// Zdolności specjalne
	
	/**
	 * Konstruktor jednostki. Wczytuje ustawienia z pliku XML.
	 * Params:
	 * name = Nazwa jednostki
	 * Throws:
	 * RangeError przy braku któregoś z wymaganych parametrów w pliku XML.
	 */
	public this(string name)
	{
		auto parser = new DocumentParser(readText(to!(string)(unitConfig[name])));
		v_name = parser.tag.attr["name"];
		v_race = parser.tag.attr["race"];
		v_imagePath = parser.tag.attr["img"];
	
		parser.onEndTag["param"] = (const Element e)
		{
			params[e.tag.attr["name"]] = to!(int)(e.tag.attr["value"]);
		};

		parser.onEndTag["ability"] = (const Element e)
		{
			abilities ~= e.tag.attr["name"];
		};
	
		parser.parse();
	}
	
	// Akcje jednostek
	
	/**
	 * Jednostka idzie na określone pole.
	 * Params:
	 * board = Plasza
	 * y = Współrzędna Y celu
	 * x = Współrzędna X celu
	 * Returns:
	 * true, jeżeli się udało
	 */
	public bool move(Board board, int y, int x)
	{
		int currY = -1;
		int currX = -1;
		board.getUnitPosition(this, currY, currX);
		
		// Sprawdzamy, czy jednostka w ogóle musi się ruszać
		if(currY == y && currX == x)
			return true;  // true, bo w sumie jednostka ląduje tam, gdzie chce
		
		// Sprawdzamy, czy jednostka ma dość ruchu
		if(board.distance(currY, currX, y, x) > params["movement"])  // Za daleko
			return false;
		
		// Sprawdzamy, czy pole istnieje i czy jest zajęte
		if(y < 0 || y >= board.fields.length || x < 0 || x >= board.fields[0].length)
			return false;
		
		if(board[y][x].unit !is null)
			return false;
		
		// Wykonujemy ruch
		board[y][x].unit = this;
		board[currY][currX].unit = null;
		
		// Zaznaczamy pola do aktualizacji
		board.changed[y][x] = true;
		board.changed[currY][currX] = true;
		
		return true;
	}
	
	/**
	 * Jednostka idzie określoną ilość pól względem aktualnej pozycji.
	 * Params:
	 * board = Plasza
	 * y = Jednoskta pójdzie o tyle pól w dół
	 * x = Jednoskta pójdzie o tyle pól w prawo
	 * Returns:
	 * true, jeżeli się udało
	 */
	public bool moveRel(Board board, int y, int x)
	{
		int currY = -1;
		int currX = -1;
		
		board.getUnitPosition(this, currY, currX);
		
		return move(board, currY + y, currX + x);
	}
	
	/**
	 * Jednostka atakuje wręcz.
	 * Params:
	 * board = Plasza
	 * target = Atakowana jednostka
	 */
	public void attack(Board board, Unit target)
	{
		// Sprawdzenie, czy możemy atakować i wykonanie ataku
		int myY, myX;
		board.getUnitPosition(this, myY, myX);
		
		int targetY, targetX;
		board.getUnitPosition(target, targetY, targetX);
		
		// Współrzędne najbliższego wolnego pola i odległość
		double minDist = double.infinity;
		int attackY, attackX;
		
		// Wyznacz najbliższe pole, z którego możesz zaatakować, sąsiadująće z celem
		for(int y = targetY-1; y <= targetY+1; y++)
		{
			for(int x = targetX-1; x <= targetX+1; x++)
			{
				if(board[y][x].unit !is null && board[y][x].unit != this)  // Pomiń zajęte pola
					continue;
				
				else
				{
					// Wyznacz odległość pola od jednotki
					double dist = board.distance(myY, myX, y, x);
					
					if(dist < minDist)
					{
						minDist = dist;
						attackY = y;
						attackX = x;
					}
				}
			}
		}
		
		if(minDist == double.infinity)  // Nie można dojść
			return;
		
		if(!move(board, attackY, attackX))  // Za daleko
			return;
		
		fight(board, target, false);
	}
	
	/**
	 * Jednostka strzela. Jeżeli wybrano cel, którego nie można
	 * zaatakować, nic się nie dzieje
	 * Params:
	 * board = Plasza
	 * target = Atakowana jednostka
	 */
	public void shoot(Board board, Unit target)
	{
		if(!isShooter())
		{
			return;  // Nie można strzelać
		}
		
		// Sprawdzenie zasięgu
		int myY, myX;
		board.getUnitPosition(this, myY, myX);
		
		int targetY, targetX;
		board.getUnitPosition(target, targetY, targetX);
		
		if(board.distance(myY, myX, targetY, targetX) > params["range"])  // Cel jest za daleko
			return;
		
		// Strzał
		fight(board, target, true);
	}
	
	/**
	 * Walka między jednostkami
	 * Params:
	 * board = Plansza
	 * target = Cel, z którym jednostka chce walczyć
	 * distance = Czy walka odbywa się na dystans
	 */
	private void fight(Board board, Unit target, bool distance = false)
	{
		// Określenie parametrów
		string strengthParam = distance ? "bow_strength" : "strength";
		
		// Kto atakuje?
		Unit attacker, attackee;
		
		if(distance)  // Po prostu sprawdzamy, czy trafi
		{
			if(rollK6() < params["fight_shoot"])  // Pudło
				return;
			
			attacker = this;
			attackee = target;
		}
		else  // Musimy ustalić, kto atakuje, a kto się broni
		{
			while(attacker is null)
			{
				// Rzuty kostką
				int att = rollK6();
				int def = rollK6();
				
				attacker = att > def ? this : target;
				attackee = att > def ? target : this;
				
				if(att == def)
				{
					attacker = params["fight_melee"] > target.params["fight_melee"] ? this : target;
					attackee = params["fight_melee"] > target.params["fight_melee"] ? target : this;
					
					if(params["fight_melee"] == target.params["fight_melee"])
					{
						attacker = null;
						attackee = null;
					}
				}
			}
		}
		
		// Wykonujemy atak
		int woundValue = woundChart[attacker.params[strengthParam]][attackee.params["defence"]];
		int firstRollRequired = woundValue >= 10 ? woundValue / 10 : woundValue;
		int secondRollRequired = woundValue >= 10 ? woundValue % 10 : 1;
		
			// Jeżeli woundValue < 10, to drugi rzut ma być min. 1, a więc zawsze trafi.
		
		if(rollK6() > firstRollRequired)
		{
			if(rollK6() > secondRollRequired)  // Atak się powiódł
			{
				attackee.damaged(board);
			}
		}
	}
	
	/**
	 * Sprawdzenie, czy jednostka żyje.
	 * Returns:
	 * true, jeżeli żyje
	 */
	public bool isAlive()
	{
		return params["wounds"] > 0;
	}
	
	/**
	 * Sprawdzenie, czy jednostka może strzelać
	 * Returns:
	 * true, jeżeli jenostka może strzelać
	 */
	public bool isShooter()
	{
		return params.get("bow_strength", -1) != -1;
	}
	
	/**
	 * Metoda obsługująca zranienie jednostki
	 * Params:
	 * board = Plansza
	 * Returns:
	 * true, jeżeli jednostka zginęła
	 */
	public bool damaged(Board board)
	{
		params["wounds"]--;
		
		// Usuń jednostkę, jeżeli nie żyje.
		if(!isAlive())
		{
			int y, x;
			board.getUnitPosition(this, y, x);
			board[y][x].unit = null;
			board.changed[y][x] = true;
		}
		
		return !isAlive();
	}
	
	
	// Funkcje własności
	
	public @property string name() {return v_name;}  /// Zwraca nazwę jednostki
	public @property string name(string name) {return v_name = name;}  /// Ustawia nazwę jednostki
	
	public @property string race() { return v_race;}  /// Zwraca rasę jednostki
	public @property string race(string race) {return v_race = race;}  /// Zwraca rasę jednostki
	
	public @property string imagePath() { return v_imagePath;}  /// Zwraca ścieżkę do obrazka jednostki
	public @property string imagePath(string path) {return v_imagePath = path;}  /// Zwraca ścieżkę do obrazka jednostki
	
	public @property Player owner() { return v_owner;}  /// Zwraca właściciela jednostki
	public @property Player owner(Player owner) {return v_owner = owner;}  /// Ustawia właściciela jednostki
}

/**
 * Wczytuje konfigurację jednostek do tablicy asocjacyjnej.
 * Params:
 * path = Ścieżka do pliku z konfiguracją jednostek
 */
public void loadUnitConfig(string path)
{
	// Przeszukujemy cały katalog wgłąb za jednym zamachem
	foreach(DirEntry entry; dirEntries(path, SpanMode.depth))
	{
		if(isDir(entry))
			continue;
		
			// W tej linii konwertujemy funkcją "to" obiekt DirEntry na tekst.
		auto doc = new Document(readText(to!(string)(entry)));
		unitConfig[doc.tag.attr["name"]] = entry;
	}
}
