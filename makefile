all: tempo

tempo: tempo4.o smpl.o rand.o
	$(LINK.c) -o $@ -Bstatic tempo4.o smpl.o rand.o -lm

smpl.o: smpl.c smpl.h
	$(COMPILE.c)  -g smpl.c

tempo4.o: tempo4.c smpl.h
	$(COMPILE.c) -g  tempo4.c

rand.o: rand.c
	$(COMPILE.c) -g rand.c

clean:
	$(RM) *.o tempo relat saida

