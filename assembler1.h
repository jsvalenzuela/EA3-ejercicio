#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <conio.h>
#include "archivos.h"
#include "prints.h"
#include "tercetos1.h"
#include "ts.h"
#define esBlanco(X)((X) == ' ' || (X)  == '\t' ? 1 : 0)
#define esLetra(X)(((X)>='A' && (X)<='Z') || ((X)>='a' && (X) <= 'z') ? 1 : 0)
#define aMinuscula(X)(((X)>='a' && (X)<='z') ? X : X+32)
#define aMayuscula(X)(((X)>='A' && (X)<='Z') ? X : X-32)

static int aux_tiponumerico=0;
void escribir_assembler();
void escribir_seccion_datos(FILE*, int);
void escribir_seccion_codigo(FILE*);
int esOperacion(int);
void preparar_assembler();
int get_aux_tiponumerico();
void set_aux_tiponumerico(int);
char* asignar_nombre_variable_assembler(char*);
char* obtener_instruccion_assembler(char*);
void prepararAssembler();



void escribir_assembler()
{
    FILE *archivo;

    	if((archivo = fopen("Final.asm", "w"))==NULL){
        printf("No se puede crear el archivo \"Final.asm\"\n");
        exit(2);
    }

    // escribo header (fijo)
	fprintf(archivo, "include macros2.asm\ninclude number.asm\n.MODEL LARGE\n.386\n.STACK 200h\n\nMAXTEXTSIZE EQU 32\n\n");

    // escribo seccion de datos, usando la tabla de simbolos
    //escribir_seccion_datos(archivo, cant_ctes);

    // escribo header de seccion de codigo
    fprintf(archivo, ".CODE\n\nSTART:\n\nMOV AX,@DATA\nMOV DS, AX\nFINIT\n\n");

    // escribo seccion de codigo, usando los tercetos
   // escribir_seccion_codigo(archivo);

    // escribo trailer (fijo)
    fprintf(archivo, "\nMOV AH, 1\nINT 21h\nMOV AX, 4C00h\nINT 21h\n\nEND START\n");

    fclose(archivo);
}







