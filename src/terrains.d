/**
 * Moduł zajmuje się obsługą terenów. Zawiera klasę opisującą teren i funkcję
 * wczytującą listę terenów z pliku.
 */
module terrains;

import std.conv;
import std.xml;
import std.file;
import std.stdio;

/**
 * Reprezentuje teren.
 */
class Terrain
{
	private string v_name;  /// Nazwa terenu
	private string v_imagePath;  /// Ścieżka do pliku z grafiką
	
	public int[string] params;  /// Parametry terenu
	public TerrainModifier[] modifiers;  /// Modyfikatory
	
	/**
	 * Konstruktor terenu.
	 * 
	 * Params:
	 * name = Nazwa terenu
	 * imagePath = Ścieżka dostępu do obrazka
	 */
	public this(string name, string imagePath)
	{
		v_name = name;
		v_imagePath = imagePath;
	}
	
	// Funkcje własności
	public @property string name() {return v_name;}  /// Zwraca nazwę terenu
	public @property string name(string n) {return v_name = n;}  /// Ustawia nazwę terenu
	
	public @property string imagePath() { return v_imagePath;}  /// Zwraca ścieżkę do obrazka
	public @property string imagePath(string n) {return v_imagePath = n;}  /// Ustawia ścieżkę do obrazka
	
}

/**
 * Definiuje modyfikator, jaki teren nakłada na jednostki.
 * 
 * TODO: Właśnie w tej klasie należy dopisać metody wykonujące te modyfikacje.
 */
class TerrainModifier
{
	private string v_param;  /// Parametr jednostki, który zostanie zmodyfikowany
	private string v_modification;  /// Wartość i sposób modyfikacji, np. +1, *2
	private string v_when;  /// Warunek modyfikacji, np. "onExit,{height}5+"
	
	/**
	 * Konstruktor modyfikatora terenu.
	 * 
	 * Params:
	 * param = Parametr jednostki, który zostanie zmodyfikowany
	 * modification = Wartość i sposób modyfikacji parametru
	 * when = warunek, pod którym zachodzi.
	 */
	public this(string param, string modification, string when="")
	{
		v_param = param;
		v_modification = modification;
		v_when = when;
	}
	
	// Funkcje własności
	public @property string param() {return v_param;}  /// Zwrace modifikowany parametr
	public @property string param(string param) {return v_param = param;}  /// Ustawia modyfikowany parametr
	
	public @property string modification() { return v_modification;}  /// Zwraca sposób modyfikacji
	public @property string modification(string modification) {return v_modification = modification;}  /// Ustawia sposób modyfikacji
	
	public @property string when() { return v_when;}  /// Zwraca warunek modyfikacji
	public @property string when(string when) {return v_when = when;}  /// Ustawia waruek modyfikacji
}

/**
 * Wczytuje konfigurację terenów z pliku XML i zwraca ją w tablicy.
 * 
 * Params:
 * path = Ścieżka do pliku konfiguracyjnego
 * Returns:
 * Tablica asocjacyjna terenów indeksowana nazwami
 * Throws:
 * RangeError przy braku któregoś z wymaganych parametrów w pliku XML.
 */
public Terrain[string] loadTerrains(string path)
{
	auto parser = new DocumentParser(readText(path));
	Terrain[string] terrains;
	
	/*
	 * Parsowanie XML zapomocą modułu std.xml biblitoteki Phobos (biblioteka
	 * standardowa języka D) wygląda dość oryginalnie.
	 * 
	 * Poniżej umieszczamy delegaty do anonimowych funkcji wykonujące się przy
	 * napotkaniu określonych tagów XML w tablicach asocjacyjnych obiektu
	 * parser.
	 */
	parser.onStartTag["terrain"] = (ElementParser ep)
	{
		Terrain terrain = new Terrain(ep.tag.attr["name"], ep.tag.attr["img"]);
		
		ep.onEndTag["param"] = (const Element e)
		{
			terrain.params[e.tag.attr["name"]] = to!(int)(e.tag.attr["value"]);
		};
		ep.onEndTag["modifier"] = (const Element e)
		{
			// Ponieważ when nie jest obowiązkowe, pobieramy je inaczej
			TerrainModifier modifier = new TerrainModifier(
						e.tag.attr["param"], e.text(), e.tag.attr.get("when", ""));
			
			terrain.modifiers ~= modifier;
		};
		
		ep.parse();
		terrains[terrain.name] = terrain;
	};
	
	parser.parse();  // Umieściliśmy akcje - możemy dokonać parsowania
	
	return terrains;
}
