/**
 * Moduł zajmuje się obsługą jednostek. Zawiera klasę obsługującą
 * jednostkę oraz funkcję wczytującą jednostki.
 */
module units;

import board;
import main;
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
	private int v_x = -1;  /// X
	private int v_y = -1;  /// Y
	private string v_race;  /// Rasa
	private string v_imagePath;  /// Ścieżka do obrazka
	private Player v_owner;  /// Właściciel
	private int v_index;  /// Indeks - unikalny dla gracza
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
		
		// Sprawdzamy, czy jednostka w ogóle musi się ruszać
		if(this.y == y && this.x == x)
			return true;  // true, bo w sumie jednostka ląduje tam, gdzie chce
		
		// Sprawdzamy, czy jednostka ma dość ruchu
		if(board.distance(this.y, this.x, y, x) > board[this.y][this.x].terrain.getParamValue(this, "movement"))  // Za daleko
			return false;
		
		// Sprawdzamy, czy pole istnieje i czy jest zajęte
		if(y < 0 || y >= board.fields.length || x < 0 || x >= board.fields[0].length)
			return false;
		
		if(board[y][x].unit !is null)
			return false;
		
		// Wykonujemy ruch
		board[y][x].unit = this;
		board[this.y][this.x].unit = null;
		
		// Zaznaczamy pola do aktualizacji
		board.changed[y][x] = true;
		board.changed[this.y][this.x] = true;
		
		log ~= format(`<p><span style="color: %s"><b>%s (#%d)</b></span> idzie na pole (%d, %d)</p>`, owner.color1, name, index, y, x);
		
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
		
		return move(board, this.y + y, this.x + x);
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
		
		// Współrzędne najbliższego wolnego pola i odległość
		double minDist = double.infinity;
		int attackY, attackX;
		
		// Wyznacz najbliższe pole, z którego możesz zaatakować, sąsiadująće z celem
		for(int y = target.y-1; y <= target.y+1; y++)
		{
			for(int x = target.x-1; x <= target.x+1; x++)
			{
				if(board[y][x].unit !is null && board[y][x].unit != this)  // Pomiń zajęte pola
					continue;
				
				else
				{
					// Wyznacz odległość pola od jednotki
					double dist = board.distance(this.y, this.x, y, x);
					
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
		
		// Atak
		log ~= format(`<p><span style="color: %s;"><b>%s (#%d)</b></span> rozpoczyna walkę z 
				<span style="color: %s;"><b>%s (#%d)</b></span>.<br/>`,
				owner.color1, name, index, target.owner.color1, target.name, target.index);
		
		fight(board, target, false);
		
		log ~= `</p>`;
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
		if(board.distance(this.y, this.x, target.y, target.x) > board[this.y][this.x].terrain.getParamValue(this, "range"))  // Cel jest za daleko
			return;
		
		// Strzał
		log ~= format(`<p><span style="color: %s;"><b>%s (#%d)</b></span> strzela do
				<span style="color: %s;"><b>%s (#%d)</b></span>.<br/>`,
				owner.color1, name, index, target.owner.color1, target.name, target.index);
		
		fight(board, target, true);
		
		log ~= `</p>`;
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
		// Sprawdzenie zasięgu
		int distanceDodge = board[target.y][target.x].terrain.getParamValue(target, "distanceDodge");
		
		// Określenie parametrów
		string strengthParam = distance ? "bow_strength" : "strength";
		
		// Kto atakuje?
		Unit attacker, attackee;
		
		if(distance)  // Po prostu sprawdzamy, czy trafi
		{
			for(int i = 0; i < distanceDodge; i++)
			{
				if(rollK6() < params["fight_shoot"])  // Pudło
				{
					log ~= format(`<span style="color: %s;"><b>%s (#%d)</b></span> nie trafia.<br/>`,
							owner.color1, name, index);
					return;
				}
			}
			
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
		
		if(!distance)
		{
			log ~= format(`<span style="color: %s;"><b>%s (#%d)</b></span> zaatakuje.<br/>`,
					attacker.owner.color1, attacker.name, attacker.index);
		}
		
		// Wykonujemy atak
		int woundValue = woundChart[attacker.params[strengthParam]][attackee.params["defence"]];
		int firstRollRequired = woundValue >= 10 ? woundValue / 10 : woundValue;
		int secondRollRequired = woundValue >= 10 ? woundValue % 10 : 1;
		
			// Jeżeli woundValue < 10, to drugi rzut ma być min. 1, a więc zawsze trafi.
		
		int firstRoll = rollK6();
		int secondRoll = rollK6();
		
		if(firstRoll >= firstRollRequired)
		{
			if(secondRoll >= secondRollRequired)  // Atak się powiódł
			{
				attackee.damaged(board);
				return;
			}
		}
		
		log ~= `Atak nie powiódł się.<br/>`;
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
		log ~= format(`<span style="color: %s;"><b>%s (#%d)</b></span> otrzymuje obrażenia.<br/>`, 
				owner.color1, name, index);
						
		params["wounds"]--;
		
		// Usuń jednostkę, jeżeli nie żyje.
		if(!isAlive())
		{
			log ~= format(`<span style="color: %s;"><b>%s (#%d)</b></span> nie żyje.<br/>`, 
					owner.color1, name, index);
			
			
			board[this.y][this.x].unit = null;
			board.changed[this.y][this.x] = true;
		}
		
		return !isAlive();
	}
	
	
	// Funkcje własności
	
	public @property string name() {return v_name;}  /// Zwraca nazwę jednostki
	public @property string name(string name) {return v_name = name;}  /// Ustawia nazwę jednostki
	
	public @property int x() { return v_x;}  /// Zwraca x jednostki
	public @property int x(int x) {return v_x = x;}  /// Ustawia x jednostki
	
	public @property int y() { return v_y;}  /// Zwraca y jednostki
	public @property int y(int y) {return v_y = y;}  /// Ustawia y jednostki
	
	public @property string race() { return v_race;}  /// Zwraca rasę jednostki
	public @property string race(string race) {return v_race = race;}  /// Zwraca rasę jednostki
	
	public @property string imagePath() { return v_imagePath;}  /// Zwraca ścieżkę do obrazka jednostki
	public @property string imagePath(string path) {return v_imagePath = path;}  /// Zwraca ścieżkę do obrazka jednostki
	
	public @property Player owner() { return v_owner;}  /// Zwraca właściciela jednostki
	public @property Player owner(Player owner) {return v_owner = owner;}  /// Ustawia właściciela jednostki
	
	public @property int index() { return v_index;}  /// Zwraca indeks jednostki
	public @property int index(int index) {return v_index = index;}  /// Ustawia indeks jednostki
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
