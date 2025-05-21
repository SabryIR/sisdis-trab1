/* tempo.c: um programa para iniciar a programação de simulação
   Sistemas Distribuídos - Prof. Elias Duarte */

/* Vamos simular N processos, vames ver o seu comportamento ao longo do tempo*/

#include <stdio.h>
#include <stdlib.h>
#include "smpl.h"

// Vamos definir os eventos

#define test 1
#define fault 2
#define recovery 3

// Vamos definir os processos

typedef struct {
    int id; // identificador da facility SMPL
    int *State; // outras variáveis locais de cada processo
} TipoProcesso;

TipoProcesso *processo;

int main (int argc, char *argv[]) {
    static int N, // número total de processos
               token, // indica o processo que está executando
               event, r, i,
               MaxTempoSimulac = 150;
    static char fa_name[5];

    if (argc != 2) {
        puts("Uso correto: tempo <número de processos>");
        exit(1);
    }
    
    N = atoi(argv[1]);

    smpl(0, "Um Exemplo de Simulação: N Processos Executam ao Longo do Tempo");
    reset();
    stream(1);

    // inicializar os processos

    processo = (TipoProcesso *) malloc(sizeof(TipoProcesso)*N);

    for (i = 0; i < N; i++) {
        memset(fa_name, '\0', 5);
        sprintf(fa_name, "%d", i);

        processo[i].id = facility(fa_name, 1);
        processo[i].State = (int *) malloc(sizeof(int)*N);

        for (int j = 0; j < N; j++)
            if (j == i)
                processo[i].State[j] = 0;
            else
                processo[i].State[j] = -1;
    }

    // Vamos escalonar (schedule) os eventos iniciais
    // testes: todos os processos executam em intervalos de testes de 30 unidades de tempo
    // A simulação começa no tempo 0 (zero) e os primeiros testes são escalonados para o tempo 30.0

    for (i = 0; i < N; i++)
        schedule(test, 30.0, i);
    schedule(fault, 31.0, 1);
    schedule(recovery, 61.0, 1);

    // Agora vem o loop principal do simulador

    while(time() <= MaxTempoSimulac) {
        cause(&event, &token);
        switch(event) {
            case test: 
                if (status(processo[token].id) != 0) break; // se o próprio processo estiver falho, não testa!
                i = (token+1) % N;
                while (i != token) {
                    printf("State[%d] no tempo %4.1f: ", token, time());
                    if (status(processo[i].id) != 0) { // processo falho
                        processo[token].State[i] = 1;
                        for (int j = 0; j < N; j++)
                            printf("%d ", processo[token].State[j]);
                        printf("\n");
                    }
                    else { // processo correto
                        processo[token].State[i] = 0;
                        for (int j = i+1; j != token; j = (j+1) % N)
                            processo[token].State[j] = processo[i].State[j];
                        for (int j = 0; j < N; j++)
                            printf("%d ", processo[token].State[j]);
                        printf("\n");
                        break;
                    }
                    i = (i+1) % N;
                }
                //printf("O processo %d testou no tempo %4.1f\n", token, time());
                schedule(test, 30.0, token);
                break;
            case fault:
                r = request(processo[token].id, token, 0);
                printf("O processo %d falhou no tempo %4.1f\n", token, time());
                break;
            case recovery:
                release(processo[token].id, token);
                printf("O processo %d recuperou no tempo %4.1f\n", token, time());
                schedule(test, 1.0, token);
        } // switch
    } // while
} // tempo.c