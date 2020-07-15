#include "assembler.h"
void generarAssembler(ArrayTercetos *a)
{
    pprints("Generando Assembler...");
    FILE *fpAss = fopen("Final.asm", "r");
    fpAss = fopen("Final.asm", "a");
    fprintf(fpAss, "include macros2.asm\n");
	fprintf(fpAss, "include number.asm\n");
	fprintf(fpAss, ".MODEL SMALL \n");
	fprintf(fpAss, ".386\n");
	fprintf(fpAss, ".STACK 200h \n");

	generarData(fpAss);
	generarVariablesContar(fpAss,a);
    fprintf(fpAss, "\n.CODE \n");
    fprintf(fpAss, "\t MOV AX,@DATA 	;inicializa el segmento de datos\n");
    fprintf(fpAss, "\t MOV DS,AX \n");
    fprintf(fpAss, "\t MOV es,ax\n");
    fprintf(fpAss, "\n");

    generarCode(fpAss, a);
	/*generamos el final */
	
	fprintf(fpAss, "\n mov ah, 1 ; pausa, espera que oprima una tecla \n");
	fprintf(fpAss, "int 21h ; AH=1 es el servicio de lectura \n  ");
	fprintf(fpAss, "MOV AX, 4C00h ; Sale del Dos \n");
	fprintf(fpAss, "INT 21h ; Enviamos la interripcion 21h \n  ");
	fprintf(fpAss, "END ; final del archivo. \n");
    fclose(fpAss);
    pprints("Assembler generado...");
}


void generarVariablesContar(FILE *fpAss,ArrayTercetos *a)
{
	int tope = (*a).cantidadTotalElementos;
	int posicion =0;
	int contador = 1;
	while( posicion < tope)
	{
		 fprintf(fpAss, "\nposicion%d dd  %d",contador ,a->totalElementos[posicion]);
		 posicion++;
		 contador++;
	}
}

void generarOperandoIzquierdo(FILE *fpAss, ArrayTercetos *a, int i)
{
    if(a->array[a->array[i].left].type == 'I') {
        fprintf(fpAss, "\nFILD _%d", a->array[a->array[i].left].intValue);
    } else if (a->array[a->array[i].left].type == 'S') {

		if(getType(a->array[a->array[i].left].stringValue) == 1)
			fprintf(fpAss, "\nFILD %s", a->array[a->array[i].left].stringValue);
		else
			fprintf(fpAss, "\nFLD %s", a->array[a->array[i].left].stringValue);
    } else if (a->array[a->array[i].left].type == 'F') {
        fprintf(fpAss, "\nFLD _%f_", a->array[a->array[i].left].floatValue);
    }
}

void generarOperandoDerecho(FILE *fpAss, ArrayTercetos *a, int i)
{
    if(a->array[a->array[i].right].type == 'I') {
        fprintf(fpAss, "\nFILD _%d", a->array[a->array[i].right].intValue);
    } else if (a->array[a->array[i].right].type == 'S') {
        fprintf(fpAss, "\nFLD %s", a->array[a->array[i].right].stringValue);
    } else if (a->array[a->array[i].right].type == 'F') {
        fprintf(fpAss, "\nFLD _%f", a->array[a->array[i].right].floatValue);
    }
}

void generarCode(FILE *fpAss, ArrayTercetos *a)
{

    FILE *fpTs = fopen("intermedia.txt", "r");
    char linea[200];
	char aux[100];
	int x;
    ArrayTercetos arrayTercetos;
    crearTercetos(&arrayTercetos, 100);

        if((int)a->tamanioUsado > 0) {
        for(int i=0; i < (int)a->tamanioUsado; i++) {
                char operador = a->array[i].operator;
				if(operador == TOP_PRINT){
					if (a->array[i].type == 'I'){
						fprintf(fpAss, "\nDisplayInteger %s,2", a->array[i].stringValue);
						fprintf(fpAss, "\nnewLine 1");
					}
					else
					{
						strcpy(aux,a->array[i].stringValue);
						char* valueSinComillas = eliminar_comillas(aux);
						char aux2[100];
						strcpy(aux2,normalizarCadenaDeclaracion(valueSinComillas));
						
						fprintf(fpAss, "\nDisplayString %s", valueSinComillas);
						fprintf(fpAss, "\nnewLine 1");
					}
				}
				else if(operador == TOP_READ){
						fprintf(fpAss, "\nGetInteger %s ", a->array[i].stringValue);
						fprintf(fpAss, "\nnewLine 1");
				}
				else if(operador == TOP_CONTAR){
						fprintf(fpAss, "\n\t fild %s ", a->array[i].stringValue);
				}
				else if(operador == TOP_ASIG)
				{
					char *valor = malloc(strlen(a->array[i].stringValue) + 1);
					strcpy(valor,a->array[i].stringValue);
					char valorAux[100];
					for(x=0; x< a->array[i].cantidadElementos; x++)
					{
						
						int siguienteElemento = x + 2;
						if(siguienteElemento > a->array[i].cantidadElementos)
							siguienteElemento = -1;
						
						fprintf(fpAss, "\n\tparte%d:", x+1);
						fprintf(fpAss, "\n\t fild posicion%d", x+1);
						fprintf(fpAss, "\n\t fxch");
						fprintf(fpAss, "\n\t fcom");
						fprintf(fpAss,"\n\t fstsw ax");
						fprintf(fpAss,"\n\tsahf");
						fprintf(fpAss,"\n\tffree st(0)");
						if(siguienteElemento != -1)
						{
							fprintf(fpAss,"\n\tjne parte%d",siguienteElemento);
							fprintf(fpAss,"\n\tinc %s ",valor);
							fprintf(fpAss,"\n\tjmp parte%d",siguienteElemento);
						}
						else
						{
							fprintf(fpAss,"\n\tjne final");
							fprintf(fpAss,"\n\tinc %s ",valor);
							fprintf(fpAss,"\n\tjmp final");
						}
					}	
					fprintf(fpAss, "\n final: \n");
				}  
        }
    }
};

char *getAsmType(char *tsType)
{
    if(strcmp(tsType, "FLOAT") == 0)
    {
        return "dd";
    }
    else if (strcmp(tsType, "INTEGER") == 0) {
        return "dd";
    }
    else if (strcmp(tsType, "CONST_STRING") == 0 ) {
        return "db";
    }
    else if(strcmp(tsType, "CONST_INT") == 0)
    {
        return "dd";
    }
	else if(strcmp(tsType, "CONST_FLOAT") == 0)
    {
        return "dd";
    }
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

void generarData(FILE *fpAss)
{
    char linea[1000];
    char lineaValue[36],word[100], type[100],value[100],length[100];;
    int esLineaEncabezado = 0;
    FILE *fpTs = fopen("ts.txt", "r");

    fprintf(fpAss, "\n.DATA\n");
	//fprintf(fpAss, "\n");
	//fprintf(fpAss, "\nresult dd ?");
	//fprintf(fpAss, "\nR dd ?");

	while(!feof(fpTs))
    {
        strcpy(type,"");
		strcpy(word,"");
		strcpy(value,"");
		strcpy(length,"");
        //sscanf(linea, "'%s' %s '%s' %s", word, type, value, length);
		fscanf(fpTs,"%35[^\n]%20[^\n]%45[^\n]%20[^\n]\n", word, type, value, length);
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
			else if(strcmp(type, "CONST_INT") == 0)
			{
				fprintf(fpAss, "\n%s dd %s", word,value);
			}
			else if(strcmp(type, "CONST_FLOAT") == 0)
			{
				fprintf(fpAss, "\n%s_ dd %s", word,value);
			}

        }
    }
	
};
