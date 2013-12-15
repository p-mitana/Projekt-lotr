../bin/main : ../obj/board.o ../obj/main.o ../obj/players.o ../obj/terrains.o ../obj/units.o ../obj/ui.o\
				../obj/cpp_ui.o
	dmd -of../bin/main ../obj/*.o -L-lQt5Core -L-lQt5Gui -L-lQt5Quick -L-lQt5Qml -L-lstdc++

../obj/cpp_ui.o : ui/cpp_ui.cpp ui/cpp_ui.h
	cd ui; qmake && make; cd ..
	rm ../bin/*toremove*

../obj/board.o : board.d
	dmd -c -Dd../doc board.d -of../obj/board.o

../obj/main.o : main.d
	dmd -c -Dd../doc main.d -of../obj/main.o

../obj/players.o : players.d
	dmd -c -Dd../doc players.d -of../obj/players.o

../obj/terrains.o : terrains.d
	dmd -c -Dd../doc terrains.d -of../obj/terrains.o

../obj/ui.o : ui.d
	dmd -c -Dd../doc ui.d -of../obj/ui.o

../obj/units.o : units.d
	dmd -c -Dd../doc units.d -of../obj/units.o
