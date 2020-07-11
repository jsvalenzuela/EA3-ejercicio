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
void controlar_if_anidados(int cant);
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

pila pilaFactor;
pila pilaID;
pila_s pilaIDDeclare;
pila_s pilaTipoDeclare;
pila pilaExpresion;
pila pilaTermino;
pila pilaRepeat;
ArrayTercetos aTercetos;

t_cola colaId;

struct ifs {
	int posicion;
	int nro_if;
};
struct ifs expr_if[1000];
int expr_if_index = 0;

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
        crearPila(&pilaRepeat);
        crearPila(&pilaFactor);
        crearPila(&pilaID);
        crearPila(&pilaExpresion);
        crearPila(&pilaTermino);
	crearCola(&colaId);
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
%}

%type <intValue> CONST_INT
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
%token PRINT READ

// MOD / DIV
//%token MOD DIV

// Asignacion
%token ID OP_ASIG

// Constantes
%token CONST_STRING CONST_INT CONST_FLOAT

// Operadores
//%token OP_MULTIPLICACION OP_SUMA OP_RESTA OP_DIVISION

// Parentesis, corchetes, otros caracteres
%token PARENTESIS_ABRE PARENTESIS_CIERRA CORCHETE_ABRE CORCHETE_CIERRA COMA DOS_PUNTOS

%start programa_aumentado
%%
programa_aumentado:
        programa {
                pprints("COMPILACION EXITOSA");
        };

programa:
        //declaraciones cuerpo
      //  | declaraciones|
      cuerpo;

// Declaraciones
/*declaraciones:
        VAR lista_linea_declaraciones ENDVAR;

lista_linea_declaraciones:
        lista_linea_declaraciones linea_declaraciones
        | linea_declaraciones;

linea_declaraciones:
        //CORCHETE_ABRE {
              //  crearPilaS(&pilaIDDeclare);
              //  crearPilaS(&pilaTipoDeclare);
        //} lista_tipo_datos CORCHETE_CIERRA DOS_PUNTOS CORCHETE_ABRE lista_id CORCHETE_CIERRA {
          {
           crearPilaS(&pilaIDDeclare);
           crearPilaS(&pilaTipoDeclare);
          }
           tipo_dato DOS_PUNTOS lista_id {
                while(!pilaVaciaS(&pilaIDDeclare) && !pilaVaciaS(&pilaTipoDeclare)){
                        char *id = sacarDePilaS(&pilaIDDeclare);
                        char *type = sacarDePilaS(&pilaTipoDeclare);
                        modifyTypeTs(id, type);
                }
        };

//lista_tipo_datos:
//        tipo_dato;

lista_id:
        lista_id COMA ID {
                ponerEnPilaS(&pilaIDDeclare, $3);
        }
        | ID {
                ponerEnPilaS(&pilaIDDeclare, $1);
        };

tipo_dato:
        TIPO_INTEGER {
                ponerEnPilaS(&pilaTipoDeclare, $1);
        }
        | TIPO_STRING {
                ponerEnPilaS(&pilaTipoDeclare, $1);
        };

//Fin Declaraciones
*/
//Seccion codigo
cuerpo:
        cuerpo sentencia
        | sentencia;

sentencia:
        asignacion
        | io_lectura
        | io_salida;

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
        PRINT CONST_STRING {
                //crearTerceto("PRINT", $2, "_", numeracionTercetos);
                //numeracionTercetos = avanzarTerceto(numeracionTercetos);

				            Terceto tPrint;
                tPrint.isOperand = 0;
                tPrint.isOperator = 1;
				            tPrint.operator = TOP_PRINT;
                tPrint.type = 'I';
                tPrint.stringValue = malloc(strlen($2)+1);
                strcpy(tPrint.stringValue, $2);

                PInd = crearTerceto("PRINT", $2, "_", numeracionTercetos);;
                tPrint.tercetoID = PInd;

                insertarTercetos(&aTercetos, tPrint);
				numeracionTercetos = avanzarTerceto(numeracionTercetos);

        } | PRINT ID {
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

                PInd = crearTerceto("PRINT", $2, "_", numeracionTercetos);;
                tPrint.tercetoID = PInd;

                insertarTercetos(&aTercetos, tPrint);
				        numeracionTercetos = avanzarTerceto(numeracionTercetos);
        };



asignacion:
        ID {
                if(getType($1) == 0)
                {
                        yyerror("La variable no fue declarada");
                        exit(2);
                }
                Terceto tIdAsignacion;
                tIdAsignacion.isOperand = 1;
                tIdAsignacion.isOperator = 0;
                tIdAsignacion.type = 'S';
                tIdAsignacion.stringValue = malloc(strlen($1)+1);
                strcpy(tIdAsignacion.stringValue, $1);

                AIind = crearTerceto($1, "_", "_", numeracionTercetos);
                tIdAsignacion.tercetoID = AIind;

                insertarTercetos(&aTercetos, tIdAsignacion);

                numeracionTercetos = avanzarTerceto(numeracionTercetos);

                reiniciarTipoDato();
        } OP_ASIG expresion {
                if(getType($1) != tipoDatoActual){
                        yyerror("No se pueden asignar variables de distintos tipos");
                        exit(0);
                }
                Terceto tOpAsignacion;
                tOpAsignacion.isOperator = 1;
                tOpAsignacion.isOperand = 0;
                tOpAsignacion.operator = TOP_ASIG;
                tOpAsignacion.left = AIind;
                tOpAsignacion.right = Eind;

                Aind = crearTercetoOperacion(":=", AIind, Eind, numeracionTercetos);
                tOpAsignacion.tercetoID = Aind;

                insertarTercetos(&aTercetos, tOpAsignacion);
                numeracionTercetos = avanzarTerceto(numeracionTercetos);
        }
        | TIPO_STRING ID OP_ASIG CONST_STRING {

                Terceto tIdAsignacionString;
                tIdAsignacionString.isOperand = 1;
                tIdAsignacionString.isOperator = 0;
                tIdAsignacionString.type = 'S';
                tIdAsignacionString.stringValue = malloc(strlen($2)+1);
                strcpy(tIdAsignacionString.stringValue, $2);

                ASInd = crearTerceto($2, "_", "_", numeracionTercetos);
                tIdAsignacionString.tercetoID = AIind;

                insertarTercetos(&aTercetos, tIdAsignacionString);

                numeracionTercetos = avanzarTerceto(numeracionTercetos);


                // Ingreso la string a asignar a los tercetos
                Terceto tStringAsignada;
                tStringAsignada.isOperator = 0;
                tStringAsignada.isOperand = 1;
                tStringAsignada.stringValue = malloc(strlen($4)+1);
                tStringAsignada.type = 'S';
                strcpy(tStringAsignada.stringValue, $4);

                ASSind = crearTerceto($4, "_", "_", numeracionTercetos);
                tStringAsignada.tercetoID = ASSind;

                insertarTercetos(&aTercetos, tStringAsignada);

                numeracionTercetos = avanzarTerceto(numeracionTercetos);


                Terceto tOpAsignacion;
                tOpAsignacion.isOperator = 1;
                tOpAsignacion.isOperand = 0;
                tOpAsignacion.operator = TOP_ASIG;
                tOpAsignacion.left = ASInd;
                tOpAsignacion.right = ASSind;

                Aind = crearTercetoOperacion(":=", ASInd, ASSind, numeracionTercetos);
                tOpAsignacion.tercetoID = Aind;

                insertarTercetos(&aTercetos, tOpAsignacion);
                numeracionTercetos = avanzarTerceto(numeracionTercetos);
        };







expresion:
         termino {
                Eind = Tind;
                status("termino a exp");
        };

termino:
       factor {
                Tind = Find;
                status("factor a termino");
        };

factor:
        CONST_INT {
                Terceto tConstInt;
                tConstInt.intValue = $1;
                tConstInt.type = 'I';
                tConstInt.isOperand = 1;

                Find = crearTercetoInt($1, "_", "_", numeracionTercetos);
                tConstInt.tercetoID = Find;

                // Inserto en la lista
                insertarTercetos(&aTercetos, tConstInt);

                // Pido la nueva numeracion
                numeracionTercetos = avanzarTerceto(numeracionTercetos);
				verificarTipoDato(1);
                status("int a factor");
        }
        | ID {
                // POC - Tercetos
                Terceto tId;
                tId.stringValue = malloc(strlen($1)+1);
                strcpy(tId.stringValue, $1);
                tId.type = 'S';
                tId.isOperand = 1;


                Find = crearTerceto($1, "_", "_", numeracionTercetos);
                ponerEnPila(&pilaFactor, Find);
                tId.tercetoID = Find;

                insertarTercetos(&aTercetos, tId);
                free(tId.stringValue);
                // fin POC

                numeracionTercetos = avanzarTerceto(numeracionTercetos);
				if(getType($1) == 0){
					yyerror("La variable no fue declarada");
					exit(0);
				}
				verificarTipoDato(getType($1));
                status("id a factor");
        }
        | PARENTESIS_ABRE expresion PARENTESIS_CIERRA {
                Find = Eind;
                status("pa expresion pc a factor");
        }
        | PARENTESIS_ABRE expresion {Find1=Eind;
				//Asignamos a una auxilar 1
				Terceto tIdAsignacion;
                tIdAsignacion.isOperand = 1;
                tIdAsignacion.isOperator = 0;
                tIdAsignacion.type = 'S';
                tIdAsignacion.stringValue = malloc(strlen("auxMod0")+1);
                strcpy(tIdAsignacion.stringValue, "auxMod0");

                Auxind=crearTerceto("auxMod0", "_", "_", numeracionTercetos);
                tIdAsignacion.tercetoID = Auxind;

                insertarTercetos(&aTercetos, tIdAsignacion);

				numeracionTercetos = avanzarTerceto(numeracionTercetos);

				Terceto tOpAsignacion;
                tOpAsignacion.isOperator = 1;
                tOpAsignacion.isOperand = 0;
                tOpAsignacion.operator = TOP_ASIG;
                tOpAsignacion.left = Auxind;
                tOpAsignacion.right = Find1;

                Tind1 = crearTercetoOperacion(":=", Auxind, Find1, numeracionTercetos);
                tOpAsignacion.tercetoID = Tind1;

                insertarTercetos(&aTercetos, tOpAsignacion);
                numeracionTercetos = avanzarTerceto(numeracionTercetos);

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
