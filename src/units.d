/**
 * Moduł zajmuje się obsługą jednostek. Zawiera klasę obsługującą
 * jednostkę oraz funkcję wczytującą jednostki.
 */
module units;

import board;
import players;

import std.array;
import std.conv;
import std.file;
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
	 * Jednostka idzie na określone pole. Jeżeli nie może, nic się nie dzieje
	 * Params:
	 * board = Plasza
	 * y = Współrzędna Y celu
	 * x = Współrzędna X celu
	 */
	public void move(Board board, int y, int x)
	{
		int currY = -1;
		int currX = -1;
		board.getUnitPosition(this, currY, currX);
		
		// TODO: Jak określić, czy jednostka ma dość ruchu?
		
		// Sprawdzamy, czy pole istnieje i czy jest zajęte
		if(y < 0 || y >= board.fields.length || x < 0 || x >= board.fields[0].length)
			return;
		
		if(board[y][x].unit !is null)
			return;
		
		// Wykonujemy ruch
		board[y][x].unit = this;
		board[currY][currX].unit = null;
		
		// Zaznaczamy pola do aktualizacji
		board.changed[y][x] = true;
		board.changed[currY][currX] = true;
	}
	
	/**
	 * Jednostka idzie określoną ilość pól względem aktualnej pozycji
	 * . Jeżeli nie może, nic się nie dzieje
	 * Params:
	 * board = Plasza
	 * y = Jednoskta pójdzie o tyle pól w dół
	 * x = Jednoskta pójdzie o tyle pól w prawo
	 */
	public void moveRel(Board board, int y, int x)
	{
		int currY = -1;
		int currX = -1;
		
		board.getUnitPosition(this, currY, currX);
		
		move(board, currY + y, currX + x);
	}
	
	/**
	 * Jednostka atakuje wręcz. Jeżeli wybrano cel, którego nie można
	 * zaatakować, nic się nie dzieje.
	 * Params:
	 * board = Plasza
	 * target = Atakowana jednostka
	 */
	public void attack(Board board, Unit target)
	{
		// Sprawdzenie, czy możemy atakować i wykonanie ataku
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
		// Sprawdzenie, czy możemy stzelić i wykonanie strzału
	}
	
	/**
	 * Sprawdzenie, czy jednostka może strzelać
	 * Returns
	 * true, jeżeli jenostka może strzelać
	 */
	public bool isShooter()
	{
		return false;  // TODO
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
