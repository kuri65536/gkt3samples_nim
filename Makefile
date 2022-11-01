bin/draw_image: draw_image.nim
	nim c -o:$@ --threads:on $<


bin/timer: timer.nim
	nim c -o:$@ $<


bin/simple: simple.nim
	nim c -o:$@ $<


bin/simplec: simple.c
	gcc -o $@ $< `pkg-config --cflags --libs gtk+-3.0`

