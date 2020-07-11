#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "archivos.h"
#include "prints.h"
#include "terceto.h"
#include "ts.h"
#define esBlanco(X)((X) == ' ' || (X)  == '\t' ? 1 : 0)
#define esLetra(X)(((X)>='A' && (X)<='Z') || ((X)>='a' && (X) <= 'z') ? 1 : 0)
#define aMinuscula(X)(((X)>='a' && (X)<='z') ? X : X+32)
#define aMayuscula(X)(((X)>='A' && (X)<='Z') ? X : X-32)
void generarAssembler(ArrayTercetos *);
void generarCode(FILE *, ArrayTercetos *);
void generarData(FILE *);
char *eliminar_comillas(char *);
char * normalizarCadenaDeclaracion(char *);
