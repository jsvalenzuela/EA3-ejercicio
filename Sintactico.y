%{
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "prints.h"
#include "pila-dinamica.h"
#include "tercetos.h"
#include "status.h"
#include "archivos.h"
#include "assembler.h"
#include "ts.h"
#include "cola-dinamica.h"

int yylex();
int yyparse();
void yyerror(const char *str);
void status();
char* getCodOp(char* salto);
void verificarTipoDato(int tipo);
void reiniciarTipoDato();

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

ArrayTercetos aTercetos;

t_cola colaId;
t_cola listaCola;



struct repeat {
	int posicion;
};
struct repeat expr_repeat[1000];
int expr_repeat_index = 0;

struct s_variables {
	int type;
};
struct s_variables variables[1000];

struct s_asignaciones {
	int type;
};
struct s_asignaciones asig[1000];

int main()
{
        clean();
        crearTercetos(&aTercetos, 100);
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

%{
        // Aux
        int numeracionTercetos = 0;
        // Índices

        // Separen los punteros por comentarios que los agrupen
        int Tind = -1;
        int Find = -1;
        int Eind = -1;
        int Eizqind = -1;

        // Asignacion simple
        int Aind = -1;
        int AIind = -1;
        int ASInd = -1;
        int ASSind = -1;

        int LVind = -1;
        int LDind = -1;
        int Tind1 = -1;
        int Tind2 = -1;
        int ELind = -1;
        int Cind = -1;
        char* valor_comparacion;
        int TLind = -1;
        int TLSalto = -1;
        int contarInd = -1;
	int Find1 = -1;
	int cant_if=0;
	int i=0;
	int repeat=0;
	int tipoDatoActual = -1;
	int cant_var = -1;
	int cant_asig=-1;
	int is_or = 0;
	int PInd=-1;
	int Auxind=-1;
	int Auxind2=-1;
	int Auxind3=-1;
  int cantidadElementosLista = 0;
  char elementosListaContar[100];
  int vectorConstantes[100];
  int cantidadElementosListaAux = 0;

%}

%type <intValue> CTE
%type <stringValue> CONST_STRING
%token <stringValue> ID

// Sector declaraciones
%token VAR ENDVAR TIPO_INTEGER TIPO_STRING

// Condiciones
//%token IF THEN ELSE ENDIF

// Operadores de Comparación
//%token OP_MENOR OP_MENOR_IGUAL OP_MAYOR OP_MAYOR_IGUAL
//%token OP_IGUAL OP_DISTINTO
//%token AND NOT OR

// Ciclos
//%token REPEAT UNTIL

// I/O
%token WRITE READ

// MOD / DIV
//%token MOD DIV

// Asignacion
%token ASIG

// Constantes
%token CONST_STRING CTE CONST_FLOAT

// Operadores
//%token OP_MULTIPLICACION OP_SUMA OP_RESTA OP_DIVISION

// Parentesis, corchetes, otros caracteres
%token PARA PARC CA CC COMA PYC

%token CONTAR

%start programa_aumentado
%%
programa_aumentado:
        programa {
                pprints("COMPILACION EXITOSA");
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
				Terceto tRead;

                modifyTypeTs($2, "INTEGER");


        };

io_salida:
        WRITE CONST_STRING {

        } | WRITE ID {
        				if(getType($2) != 1)
                {
                        yyerror("La variable no fue declarada");
                        exit(2);
                }
        };

        contar:
                CONTAR PARA ID PYC CA lista CC PARC
                {

                  if(getType($3) != 1)
                  {
                          yyerror("La variable no fue declarada para el contar");
                          exit(2);
                  }



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
              ID {
                  modifyTypeTs($1, "INTEGER");

                  //reiniciarTipoDato();
                }ASIG contar{


                  while(!colaVacia(&listaCola))
                  {
                    int valor = atoi(sacarDecola(&listaCola));
                  }


                  //Agrego los contadores al codigo
              };

%%

void status(char *str)
{
        crearStatus(str, Eind, Tind, Find, numeracionTercetos);
}

void mostrarTercetos(ArrayTercetos * a){
	int j;
	for(j=0;j<(int)a->tamanioUsado; j++){
		printf("*******************************%d\n",j);

		printf("ISOPERATOR: %d\n", a->array[j].isOperator);
		printf("VALOR: %d\n", a->array[j].left);



	}
}

void verificarTipoDato(int tipo) {

	if(tipoDatoActual == -1) {
		tipoDatoActual = tipo;
	}

	if(tipoDatoActual != tipo) {
		yyerror("No se admiten operaciones aritmeticas con tipo de datos distintos");
		exit(0);
	}

}

void reiniciarTipoDato() {
	tipoDatoActual = -1;
}
