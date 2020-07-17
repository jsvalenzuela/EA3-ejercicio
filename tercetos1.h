#include <stdio.h>
#include <stdio.h>
#include <string.h>
/* cantidad de tercetos */
static int cant_tercetos = 0;

// /* estrutura de un terceto */
// typedef struct s_terceto {
//     char t1[MAX_STRING],
//          t2[MAX_STRING],
//          t3[MAX_STRING];
// } t_terceto;

// /* coleccion de tercetos */
// t_terceto* tercetos[MAX_TERCETOS];

/* estrutura de un terceto */
	typedef struct terceto {
		int nroTerceto;
		char ope[61];
		char te1[30];
		char te2[30];
		char resultado_aux[10];
		int esEtiqueta;
	}	terceto;

/* coleccion de tercetos */
terceto vector_tercetos[1000];

static int indice_terceto = 0;	

/* reserva memoria para un terceto terceto */
// t_terceto* nuevo_terceto(const char*, const char*, const char*);
/* crea un terceto y lo agrega a la coleccion */
int crear_terceto(char*, char*, char*);
/* escribe los tercetos en un archivo */
void escribir_tercetos();
// /* libera memoria pedida para tercetos */
// void limpiar_tercetos();
// /* devuelve la cantidad de tercetos, funciona como un get de una variable privada 
// si no se usa una funcion, no se puede acceder al valor de la variable no se por que */
int obtenerIndiceTercetos();
void setIndiceTercetos(int);


int  crear_terceto(char* p_ope, char* p_te1, char* p_te2)
{
	terceto res;
	res.nroTerceto = indice_terceto;
	strcpy(res.ope, p_ope);
	strcpy(res.te1, p_te1);
	strcpy(res.te2, p_te2);
	strcpy(res.resultado_aux,"_");
	vector_tercetos[indice_terceto] = res;
	indice_terceto++;
	return indice_terceto-1;
}

void escribir_tercetos()
{
	FILE* arch;
	int i;
	terceto aux;
	arch = fopen("intermedia.txt", "w+");

	for(i = 0; i < indice_terceto; i++)
	{	
		aux =  vector_tercetos[i];
		fprintf(arch, "[%d] (%s,%s,%s)\n", aux.nroTerceto, aux.ope,aux.te1, aux.te2 );
		
	}
	fclose(arch);
}

int obtenerIndiceTercetos()
{
   return indice_terceto;
}

void setIndiceTercetos(int value)
{
   indice_terceto = value;
}
