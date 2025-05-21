/* tempo.c: um programa para iniciar a programação de simulação
   Sistemas Distribuídos - Prof. Elias Duarte */

/* Vamos simular N processos, vames ver o seu comportamento ao longo do tempo*/

#include <stdio.h>
#include <stdlib.h>
#include "smpl.h"

// Vamos definir os eventos

#define send 1
#define fault 2
#define recovery 3
#define recv_ack 4
#define timeout 5
#define recv_heartbeat 6

// Vamos definir os processos

typedef struct {
    int id; // identificador da facility SMPL
    int *State; // vetor State (-1: desconhecido, 0: correto, 1: falho)
    int s; // processo para o qual token envia um heartbeat
    int hb; // processo que enviou heartbeat para token

} TipoProcesso;

TipoProcesso *processo;

int main (int argc, char *argv[]) {
    static int N, // número total de processos
               token, // indica o processo que está executando
               event, r, i,
               MaxTempoSimulac = 100;
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
        processo[i].s = i;
        processo[i].hb = i;

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
        schedule(send, 10.0, i);
    schedule(fault, 11.0, 1);
    schedule(fault, 11.0, 4);
    schedule(recovery, 21.0, 1);
    schedule(recovery, 21.0, 4);

    // Agora vem o loop principal do simulador

    while(time() <= MaxTempoSimulac) {
        cause(&event, &token);
        switch(event) {
            case send:
                if (status(processo[token].id) != 0) break; // se o próprio processo estiver falho, não testa!
                processo[token].s = (processo[token].s + 1) % N;
                if (token == processo[token].s)
                    break;
                processo[processo[token].s].hb = token;
                printf("O processo %d enviou um heartbeat com 10 segundos de duração para o processso %d no tempo %4.1f\n", token, processo[token].s, time());
                schedule(recv_heartbeat, 2.0, processo[token].s);
                break;

            /*case test: 
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
                break;*/

            case fault:
                r = request(processo[token].id, token, 0);
                printf("O processo %d falhou no tempo %4.1f\n", token, time());
                break;
            case recovery:
                release(processo[token].id, token);
                printf("O processo %d recuperou no tempo %4.1f\n", token, time());
                schedule(send, 1.0, token);
                break;
            case recv_ack:
                printf("O processo %d recebeu um ACK do processo %d no tempo %4.1f\n", token, processo[token].s, time());
                break;
            case timeout:
                printf("O heartbeat do processo %d enviado para o processo %d expirou no tempo %4.1f\n", token, processo[token].s, time());
                processo[token].State[processo[token].s] = 1;
                printf("State[%d] no tempo %4.1f: ", token, time());
                for (int i = 0; i < N; i++)
                    printf("%d ", processo[token].State[i]);
                printf("\n");
                if (processo[token].s == (token-1) % N)
                    printf("O processo %d testou todos os outros processos falhos no tempo %4.1f\n", token, time());
                else
                    schedule(send, 0.0, token);
                break;
            case recv_heartbeat:
                if (status(processo[token].id) != 0) {
                    schedule(timeout, 8.0, processo[token].hb);
                    break;
                }
                printf("O processo %d recebeu um heartbeat do processo %d no tempo %4.1f\n", token, processo[token].hb, time());
                processo[token].State[processo[token].hb] = 0;
                for (int j = (processo[token].hb + 1) % N; j != token; j = (j+1) % N)
                    processo[token].State[j] = processo[processo[token].hb].State[j];
                    
                printf("State[%d] no tempo %4.1f: ", token, time());
                for (int j = 0; j < N; j++)
                    printf("%d ", processo[token].State[j]);
                printf("\n");
                printf("O processo %d reinicializa o seu timeout no tempo %4.1f\n", token, time());
                printf("O processo %d envia um ACK de volta para o processo %d no tempo %4.1f\n", token, processo[token].hb, time());
                if (status(processo[processo[token].hb].id) == 0)
                    schedule(recv_ack, 2.0, processo[token].hb);
                break;

        } // switch
    } // while
} // tempo.c