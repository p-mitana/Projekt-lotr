/**
 * Moduł C++ stworzony do integracji logiki aplikacji napisanej w D
 * z interfejsem graficznym stworzonym w C++ i QML z użyciem bibliotek
 * Qt 5.x.
 * 
 * Moduł zawiera dwie klasy - klasę UI odpowiadającą za interfejs
 * graficzny programu oraz klasę UILink, która jest wyłącznie
 * pośrednikiem między klasą UI a elementami stworzonymi w D.
 */

#ifndef CPP_UI_H
#define CPP_UI_H

#include <QGuiApplication>
#include <QMetaObject>
#include <QObject>
#include <QQmlEngine>
#include <QQuickItem>
#include <QQuickView>

#include <stdlib.h>
#include <string>
#include <sstream>
using namespace std;

// debug
#include <QStringList>
#include <iostream>
//debug end

// Wcześniejsze deklaracje
class UI;
class UILink;
class UICallback;

/**
 * Klasa zarządzająca interfejsem graficznym w QT
 */
class UI : public QQuickView
{
	Q_OBJECT
	
	public:
	UILink *link;
	UICallback *callback;
	
	UI(UICallback *callback);  // Konstruktor
	
	public slots:
	void simulationStart();  // Rozpoczyna/wznawia symulację
	void simulationStop();  // Zatrzymuje symulację
	void simulationStep();  // Wykonuje jedną kolejkę symulacji
	void simulationReset();  // Resetuje symulację
	void saveLog();  // Zapisuje loga
};

/**
 * Klasa obudowująca interfejs UICallback z języka D, służy do wywoływania funkcji klasy Main.
 */
class UICallback
{
	public:
	virtual void simulationStart();  // Rozpoczyna/wznawia symulację
	virtual void simulationStop();  // Zatrzymuje symulację
	virtual void simulationStep();  // Wykonuje jedną kolejkę symulacji
	virtual void simulationReset();  // Resetuje
	virtual void saveLog();  // Zapisujemy loga
};

/**
 * Klasa odpowiada za sterowanie interfejsem.
 */
class UILink
{
	public:
	UI *ui;
	QGuiApplication *app;
	QObject *board;
	
	virtual void run();  // Uruchamia aplikację
	virtual void initBoard(int width, int height);  // Inicjalizuje planszę
	virtual void appendField(int y, int x, char* imagePath);  // Dodaje pole
	virtual void clearField(int y, int x);  // Usuwa jednostkę z pola
	virtual void insertUnit(int y, int x, char *imagePath, char *color1, char *color2);  // Ustawia jednostkę w polu
	virtual void updateTurnCount(int turnCount);  // Aktualizuje licznik tur
	virtual void showBattleOverDialog(char *winner);  // Pokazuje dialog końca bitwy
	virtual void log(char* html);  // Aktualizuje loga
};

UILink *createUI(UICallback *callback);  // Metoda tworząca interfejs

#endif
