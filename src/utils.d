/**
 * Moduł zawiera różne dodatkowe funkcje i zmienne.
 */
module utils;

import std.random;

/**
 * Statyczna tablica minimalnych wartości wymaganych do zadania obrażeń w zależności od
 * ataku i obrony - pierwszy indeks to atak, drugi to obrona.
 * 
 * Wartość 7 - brak obrażeń. Wartości >10 - wymagane dwa rzuty.
 * Zerowe indeksy mają wartość -1 - nigdy nie powinny zostać wywołane.
 */
immutable(int[11][11]) woundChart = 
[[-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1],
 [-1, 4, 5, 5, 6, 6, 64, 65, 66, 7, 7],
 [-1, 4, 4, 5, 5, 6, 6, 64, 65, 66, 7],
 [-1, 3, 4, 4, 5, 5, 6, 6, 64, 65, 7],
 [-1, 3, 3, 4, 4, 5, 5, 6, 6, 64, 66],
 [-1, 3, 3, 3, 4, 4, 5, 5, 6, 6, 65],
 [-1, 3, 3, 3, 3, 4, 4, 5, 5, 6, 64],
 [-1, 3, 3, 3, 3, 3, 4, 4, 5, 5, 6],
 [-1, 3, 3, 3, 3, 3, 3, 4, 4, 5, 6],
 [-1, 3, 3, 3, 3, 3, 3, 3, 4, 4, 5],
 [-1, 3, 3, 3, 3, 3, 3, 3, 3, 4, 5]];

/**
 * Rzut kością k6.
 *
 * Returns:
 * Wynik rzutu z zakresu 1-6.
 */
int rollK6()
{
	return uniform!("[]")(1, 6);
}