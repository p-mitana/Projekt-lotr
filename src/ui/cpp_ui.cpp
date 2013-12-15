/**
 * Moduł C++ stworzony do integracji logiki aplikacji napisanej w D
 * z interfejsem graficznym stworzonym w C++ i QML z użyciem bibliotek
 * Qt 5.x.
 */

#include "cpp_ui.h"

/**
 * Tworzy interfejs użytkownika.
 */
UI::UI()
{
		// Ubuntu SDK wymaga ustawienia zmiennej środowiskowej 	APP_ID.
	setenv("APP_ID", "com.komnata_mitana.lotr", 1);
	
	this->engine()->addImportPath("qml");
	setSource(QUrl("qml/ui.qml"));
	setResizeMode(QQuickView::SizeRootObjectToView);
	
	show();
}

/**
 * Uruchamia interfejs użytkownika.
 */
void UILink::run()
{
	app->exec();
}

/**
 * Inicjalizuje planszę o zadanych wymiarach. Jeżeli wcześniej była
 * wyświetlona jakaś plansza, całkowicie ją czyści.
 * Params:
 * width = Długość planszy
 * height = Wysokość planszy
 */
void UILink::initBoard(int width, int height)
{
	// Ustawienie szerokości i wysokości
	board->setProperty("rows", height);
	board->setProperty("columns", width);
	
	// Wyczyszczenie planszy
	QMetaObject::invokeMethod(board, "clear");
}

/**
 * Dodaje pole do planszy
 */
void UILink::appendField(int y, int x, char *path)
{
	QMetaObject::invokeMethod(board, "appendField", Q_ARG(QVariant, y), Q_ARG(QVariant, x), Q_ARG(QVariant, path));
}

/**
 * Usuwa jednostkę z pola
 */
void UILink::clearField(int y, int x)
{
	stringstream stream;
	stream << "field_" << y << "_" << x;
	
	QObject *field = board->findChild<QObject*>(stream.str().c_str());
	QMetaObject::invokeMethod(field, "clear");
}

/**
 * Ustawia jednostkę w polu
 */
void UILink::insertUnit(int y, int x, char *imagePath, char *color1, char *color2)
{
	stringstream stream;
	stream << "field_" << y << "_" << x;
	
	QObject *field = board->findChild<QObject*>(stream.str().c_str());
	QMetaObject::invokeMethod(field, "insertUnit", Q_ARG(QVariant, y), Q_ARG(QVariant, x), Q_ARG(QVariant, imagePath), Q_ARG(QVariant, color1), Q_ARG(QVariant, color2));
}

/**
 * Tworzy obiekt interfejsu oraz łącznik z językiem D.
 * 
 * Returns:
 * Obiekt sterujący interfejsem
 */
UILink *createUI()
{
	// Tworzenie łącznika
	UILink *link = new UILink();
	
	// Tworzenie aplikacji
	int argc = 0;
	char **argv = NULL;
	link->app = new QGuiApplication(argc, argv);
	
	// Tworzenie interfejsu
	UI *ui = new UI();
	ui->link = link;
	link->ui = ui;
	link->board = ui->rootObject()->findChild<QObject*>("board");
	
	// Zwrócenie wskaźnika na łącznik
	return link;
}
