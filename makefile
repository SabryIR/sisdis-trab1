all: tempo

tempo: tempopush.o smpl.o rand.o
	$(LINK.c) -o $@ -Bstatic tempopush.o smpl.o rand.o -lm

smpl.o: smpl.c smpl.h
	$(COMPILE.c)  -g smpl.c

tempopush.o: tempopush.c smpl.h
	$(COMPILE.c) -g  tempopush.c

rand.o: rand.c
	$(COMPILE.c) -g rand.c

clean:
	$(RM) *.o tempo relat saida

