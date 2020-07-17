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
char *eliminar_comillas(char *cadena);
char *normalizarCadenaDeclaracion(char *cadena);
char *normalizaCadenaArchivo(char *cad);
void generarData(FILE *fpAss);
void escribir_seccion_codigo(FILE *);

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
    generarData(archivo);

    // escribo header de seccion de codigo
    fprintf(archivo, "\n.CODE\n\nSTART:\n\nMOV AX,@DATA\nMOV DS, AX\nFINIT\n\n");

    // escribo seccion de codigo, usando los tercetos
	escribir_seccion_codigo(archivo);

    // escribo trailer (fijo)
    fprintf(archivo, "\nMOV AH, 1\nINT 21h\nMOV AX, 4C00h\nINT 21h\n\nEND START\n");
    fclose(archivo);
}



char *eliminar_comillas(char *cadena) {
    char *cadena_temporal = malloc(strlen(cadena)+1);
    int j = 0;
	int i;
        for (i=0; i<strlen(cadena); i++) {
            switch (cadena[i]) {
                case '"': break;
                default:
                cadena_temporal[j] = cadena[i];
                j++;
            }
        }

    cadena_temporal[j] = '\0';
    return cadena_temporal;
}



char *normalizarCadenaDeclaracion(char *cadena)
{
	char *recorrerCad = cadena, *aux = recorrerCad;
    int blancoEncontrado = 0, contCaracteres = 0, blancoInicial = 0, primerChar = 0;
    int marca = 0;
    while(*recorrerCad)
    {
        if(esBlanco(*recorrerCad))
        {
            if(contCaracteres == 0)  //para ver si hay blancos iniciales
            {
                blancoInicial = 1;
                primerChar = 1;

            }
            blancoEncontrado = 1;
        }
        else
        {
            if(blancoEncontrado && !blancoInicial) // caso encontrar blanco(que no sea uno inicial)
            {
                *aux = '_';
                aux++;
                primerChar = 1;
            }
            if(blancoInicial)
                blancoInicial = 0;
            blancoEncontrado = 0;
            if(primerChar || !contCaracteres)  //verifico que el primer caracter de una palabra o de la cadena sea una letra
            {
                primerChar = 0;
                if(esLetra(*recorrerCad))
                {
					*recorrerCad = aMayuscula(*recorrerCad);
					*aux = *recorrerCad;
					aux++ ;
				}
			}
        }
        contCaracteres++;
        recorrerCad++; //RECORRO SIEMPRE MI CADENA
    }
    *aux = '\0';
    return cadena;
}

char *normalizaCadenaArchivo(char *cad)
{
    char *aux;
    aux = strchr(cad,' ');
    if(aux != NULL)
        *aux = '\0';
    return cad;
}


void escribir_seccion_codigo(FILE *fpAss)
{
	int i;
    int indice_terceto = obtenerIndiceTercetos();
	char aux[100];
	for(i=0;i <= indice_terceto;i++)
	{	
		if(strcmp(vector_tercetos[i].ope,"WRITE")==0)
		{
			if(strchr(vector_tercetos[i-1].ope,'"') != NULL)
			{
				strcpy(aux,vector_tercetos[i-1].ope);
				char* valueSinComillas = eliminar_comillas(aux);
				char aux2[100];
				strcpy(aux2,normalizarCadenaDeclaracion(valueSinComillas));				
				fprintf(fpAss, "\nDisplayString %s", valueSinComillas);
				fprintf(fpAss, "\nnewLine 1");
			}
		}
	}
}


void generarData(FILE *fpAss)
{
    char linea[1000];
    char lineaValue[36],word[100], type[100],value[100],length[100];;
    int esLineaEncabezado = 0;
    FILE *fpTs = fopen("ts.txt", "r");

    fprintf(fpAss, "\n.DATA\n");

	while(!feof(fpTs))
    {
        strcpy(type,"");
		strcpy(word,"");
		strcpy(value,"");
		strcpy(length,"");
        //sscanf(linea, "'%s' %s '%s' %s", word, type, value, length);
		fscanf(fpTs,"%60[^\n]%20[^\n]%60[^\n]%20[^\n]\n", word, type, value, length);
		trim(word,NULL);
		trim(type,NULL);
		trim(value,NULL);
		trim(length,NULL);
		//fscanf(fpTs,"%[^\n]%[^\n]%[^\n]%[^\n]\n", word, type, value, length);
		if(esLineaEncabezado == 0) {
            esLineaEncabezado = 1;
        } else {
			if(strstr (type, "INTEGER") )
			{
				fprintf(fpAss, "\n%s dd ?", word);
			}
			else if (strstr(type, "CONST_STRING") ) {
				
				char* wordSinComillas = eliminar_comillas(word);
                char* valueSinComillas = eliminar_comillas(value);
                char aux1[45] ;

				fprintf(fpAss, "\n%s\tdb\t'%s','$', %s dup (?)\n",normalizarCadenaDeclaracion(wordSinComillas) , valueSinComillas, length);
			}
			else if(strcmp(type, "CONST_INTE") == 0)
			{
				fprintf(fpAss, "\n%s dd %s", word,value);
			}

        }
    }
	
};






