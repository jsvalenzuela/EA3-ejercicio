%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "tercetos1.h"
#include "pila-dinamica.h"
#include "ts.h"
#include "cola-dinamica.h"

int yylex();
int yyparse();
void yyerror(const char *str);
char* getCodOp(char* salto);

void yyerror(const char *str)
{
        printf("\033[0;31m");
        printf("\t[SYNTAX ERROR]: %s\n", str);
        printf("\033[0m");
}

int yywrap()
{
        return 1;
}


t_cola colaId;
t_cola listaCola;
int idTercetoAsignacion = -1;
int idTercetoPivot = -1;
int idTercetoContar =-1;
char nombrePivotAsignacion[60];

int main()
{
        clean();
        crearCola(&listaCola);
        yyparse();
        exit(0);
}

void pprintf(char *str) {
        printf("\t %s \n", str);
}

void pprintfd(int str) {
        printf("\t %d \n", str);
}

void pprintff(float str) {
        printf("\t %f \n", str);
}

%}

%union
{
        int intValue;
        float floatValue;
        char *stringValue;
}


%type <intValue> CTE
%type <stringValue> CONST_STRING
%token <stringValue> ID

// Sector declaraciones
%token VAR ENDVAR TIPO_INTEGER TIPO_STRING

// I/O
%token WRITE READ

// Asignacion
%token ASIG

// Constantes
%token CONST_STRING CTE

// Parentesis, corchetes, otros caracteres
%token PARA PARC CA CC COMA PYC

%token CONTAR

%start programa_aumentado
%%
programa_aumentado:
        programa {
                pprints("COMPILACION EXITOSA");
                escribir_tercetos();
                //generarAssembler(&aTercetos);
                //aTercetos.cantidadTotalElementos=cantidadElementosLista;
        };

programa:
      cuerpo;

//Seccion codigo
cuerpo:
        cuerpo sentencia
        | sentencia;

sentencia:
        io_lectura
        | io_salida | asig;

io_lectura:
        READ ID {
                modifyTypeTs($2, "INTEGER");
                crear_terceto("READ",$2,"_");
        };

io_salida:
        WRITE CONST_STRING {
          crear_terceto("PRINT",$2,"_");
        } | WRITE ID {
        				if(getType($2) != 1)
                {
                        yyerror("La variable no fue declarada");
                        exit(2);
                }
          crear_terceto("PRINT",$2,"_");
        };

        contar:
                CONTAR PARA ID PYC CA lista CC PARC
                {

                  if(getType($3) != 1)
                  {
                          yyerror("La variable no fue declarada para el contar");
                          exit(2);
                  }
                  strcpy(nombrePivotAsignacion,$3);
                };

        lista:
              CTE {
                  char valorcte[10];
                  itoa ($1,valorcte,10);
                  ponerEncola(&listaCola,valorcte);
              }| lista COMA CTE
              {
                char valorcte1[10];
                itoa ($3,valorcte1,10);
                ponerEncola(&listaCola,valorcte1);
              } ;

        asig:
              ID ASIG contar{
                //Agrego el id a la tabla simbolos
                  modifyTypeTs($1, "INTEGER");
                  int idTercetoAsignacion = crear_terceto($1,"_","_");
                  int idTercetoPivot = crear_terceto(nombrePivotAsignacion,"_","_");
                  int idTercetoContar = crear_terceto("@resContar","_","_");
                  while(!colaVacia(&listaCola))
                  {
                    char valorAux[1];
                    strcpy(valorAux,sacarDecola(&listaCola));
                    int valorTerceto = crear_terceto(valorAux,"_","_");
                  }

                  //Agrego los contadores al codigo
              };

%%
