all: tempo tempopush

tempo: tempo.o tempo1.o tempo2.o tempo3.o tempo4.o smpl.o rand.o
	$(LINK.c) -o tempo -Bstatic tempo.o smpl.o rand.o -lm
	$(LINK.c) -o tempo1 -Bstatic tempo1.o smpl.o rand.o -lm
	$(LINK.c) -o tempo2 -Bstatic tempo2.o smpl.o rand.o -lm
	$(LINK.c) -o tempo3 -Bstatic tempo3.o smpl.o rand.o -lm
	$(LINK.c) -o tempo4 -Bstatic tempo4.o smpl.o rand.o -lm

tempopush: tempopush.o tempopush1.o tempopush2.o smpl.o rand.o
	$(LINK.c) -o tempopush -Bstatic tempopush.o smpl.o rand.o -lm
	$(LINK.c) -o tempopush1 -Bstatic tempopush1.o smpl.o rand.o -lm
	$(LINK.c) -o tempopush2 -Bstatic tempopush2.o smpl.o rand.o -lm

*.o:
	$(COMPILE.c) -g *.o

clean:
	$(RM) *.o tempo tempo1 tempo2 tempo3 tempo4 tempopush tempopush1 tempopush2 relat saida
