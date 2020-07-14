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
        generarAssembler(&aTercetos);
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
%type <stringValue> ID CONST_STRING TIPO_INTEGER TIPO_STRING

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
%token ID ASIG

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
                aTercetos.cantidadTotalElementos=cantidadElementosLista;
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
                //uso la pila para declarar el id
                //ponerEnPilaS(&pilaIDDeclare, $2);
                //char *id = sacarDePilaS(&pilaIDDeclare);
                //char *type = sacarDePilaS(&pilaTipoDeclare);
                modifyTypeTs($2, "INTEGER");

                tRead.isOperand = 0;
                tRead.isOperator = 1;
				        tRead.operator = TOP_READ;
                tRead.type = 'S';
                tRead.stringValue = malloc(strlen($2)+1);
                strcpy(tRead.stringValue, $2);

                PInd = crearTerceto("READ", $2, "_", numeracionTercetos);
                tRead.tercetoID = PInd;

                insertarTercetos(&aTercetos, tRead);
				        numeracionTercetos = avanzarTerceto(numeracionTercetos);
        };

io_salida:
        WRITE CONST_STRING {
                //crearTerceto("PRINT", $2, "_", numeracionTercetos);
                //numeracionTercetos = avanzarTerceto(numeracionTercetos);

				            Terceto tPrint;
                tPrint.isOperand = 0;
                tPrint.isOperator = 1;
				            tPrint.operator = TOP_PRINT;
                tPrint.type = 'S';
                tPrint.stringValue = malloc(strlen($2)+1);
                strcpy(tPrint.stringValue, $2);

                PInd = crearTerceto("WRITE", $2, "_", numeracionTercetos);;
                tPrint.tercetoID = PInd;

                insertarTercetos(&aTercetos, tPrint);
				numeracionTercetos = avanzarTerceto(numeracionTercetos);

        } | WRITE ID {
                //crearTerceto("PRINT", $2, "_", numeracionTercetos);
                //numeracionTercetos = avanzarTerceto(numeracionTercetos);
        				Terceto tPrint;
                        tPrint.isOperand = 0;
                        tPrint.isOperator = 1;
        				tPrint.operator = TOP_PRINT;
        				if(getType($2) == 1)
        					tPrint.type = 'I';
                else
                {
                        yyerror("La variable no fue declarada");
                        exit(2);
                }
                tPrint.stringValue = malloc(strlen($2)+1);
                strcpy(tPrint.stringValue, $2);

                PInd = crearTerceto("WRITE", $2, "_", numeracionTercetos);;
                tPrint.tercetoID = PInd;

                insertarTercetos(&aTercetos, tPrint);
				        numeracionTercetos = avanzarTerceto(numeracionTercetos);
        };

        contar:
                CONTAR PARA ID PYC CA lista CC PARC
                {
                  status("CONTAR");
                   Terceto tContar;
                  if(getType($3) == 1)
                    tContar.type = 'I';
                  else
                  {
                          yyerror("La variable no fue declarada para el contar");
                          exit(2);
                  }
                      tContar.isOperand = 0;
                      tContar.isOperator = 1;
                      tContar.operator = 12;
                      status("CONTAR");
                      char nombreTerceto[50];

                      contarInd = crearTerceto("CONTAR", $3, "lista", numeracionTercetos);
                       tContar.tercetoID = contarInd;

                       // Inserto en la lista
                       insertarTercetos(&aTercetos, tContar);

                       // Pido la nueva numeracion
                       numeracionTercetos = avanzarTerceto(numeracionTercetos);


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
                  Terceto tIdAsignacion;
                  tIdAsignacion.isOperand = 1;
                  tIdAsignacion.isOperator = 0;
                  tIdAsignacion.operator = TOP_ID;
				  tIdAsignacion.type = 'I';
                  tIdAsignacion.stringValue = malloc(strlen($1)+1);
                  strcpy(tIdAsignacion.stringValue, $1);
                  AIind = crearTerceto($1, "_", "_", numeracionTercetos);
                  tIdAsignacion.tercetoID = AIind;
                  insertarTercetos(&aTercetos, tIdAsignacion);
                  numeracionTercetos = avanzarTerceto(numeracionTercetos);

                  //reiniciarTipoDato();
                }ASIG contar{
                  pprintf("adentro");
                  Terceto tOpAsignacion;
                  tOpAsignacion.isOperator = 1;
                  tOpAsignacion.isOperand = 0;
                  tOpAsignacion.operator = TOP_ASIG;
                  tOpAsignacion.left = AIind;
                  tOpAsignacion.right = contarInd;
                  Aind = crearTercetoOperacion(":=", AIind, contarInd, numeracionTercetos);
                  tOpAsignacion.tercetoID = Aind;
                  insertarTercetos(&aTercetos, tOpAsignacion);
                  numeracionTercetos = avanzarTerceto(numeracionTercetos);

                  while(!colaVacia(&listaCola))
                  {
                    int valor = atoi(sacarDecola(&listaCola));
                    aTercetos.array[tOpAsignacion.tercetoID].elementos[cantidadElementosListaAux] = valor;
                    aTercetos.totalElementos[cantidadElementosLista] = valor;
                    cantidadElementosListaAux++;
                    cantidadElementosLista++;
                  }
                  aTercetos.array[tOpAsignacion.tercetoID].cantidadElementos = cantidadElementosListaAux;
                  cantidadElementosListaAux = 0;

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
