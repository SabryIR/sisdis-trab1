all: tempo

tempo: tempopush2.o smpl.o rand.o
	$(LINK.c) -o $@ -Bstatic tempopush2.o smpl.o rand.o -lm

smpl.o: smpl.c smpl.h
	$(COMPILE.c)  -g smpl.c

tempopush1.o: tempopush2.c smpl.h
	$(COMPILE.c) -g  tempopush2.c

rand.o: rand.c
	$(COMPILE.c) -g rand.c

clean:
	$(RM) *.o tempo relat saida

