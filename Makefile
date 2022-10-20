bin/simple: simple.nim
	nim c -o:$@ $<


bin/simplec: simple.c
	gcc -o $@ $< `pkg-config --cflags --libs gtk+-3.0`

