%{

/* include area */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "y.tab.h"
#include "valid.type.h"

%}
%%
"VAR"                                   return VAR;
"ENDVAR"                                return ENDVAR;
"PRINT"                                 return PRINT;
"READ"                                  return READ;
":="                                    return OP_ASIG;
"("                                     return PARENTESIS_ABRE;
")"                                     return PARENTESIS_CIERRA;
"["                                     return CORCHETE_ABRE;
"]"                                     return CORCHETE_CIERRA;
","                                     return COMA;
":"                                     return DOS_PUNTOS;
"INTEGER"                               { yylval.stringValue = strdup(yytext); return TIPO_INTEGER; }
"STRING"								{ yylval.stringValue = strdup(yytext); return TIPO_STRING; }
[0-9]+                                  { validType(yytext, TYPE_INT); yylval.intValue = atoi(yytext); return CONST_INT; }
[0-9]+"."[0-9\+\-\e]+                   { validType(yytext, TYPE_FLOAT); yylval.floatValue = atof(yytext); return CONST_FLOAT; }
[a-zA-Z][a-zA-Z0-9_]*                   { validType(yytext, TYPE_ID); yylval.stringValue = strdup(yytext); return ID; }
\-\-\/(\\.|[^"\\])*\/\-\-               { char * comentarios;
										  char *segundonivel;
										  comentarios = (strstr(yytext,"/--"));
										  segundonivel = strstr(comentarios +3, "/--");
										  if(segundonivel != NULL){
											if(strstr(segundonivel+3,"/--") != NULL){
												fprintf(stderr, "No se permite un segundo nivel de comentarios...Fin de ejecucion.\n");
												system ("Pause");
												exit (1);
											}
										  }
										 }
\"(\\.|[^"\\])*\"                       { validType(yytext, TYPE_STRING); yylval.stringValue = strdup(yytext); return CONST_STRING; }
\n                                      /* ignore end of line */;
[ \t]+                                  /* ignore whitespace */;
\n|.       		                        { printError("Caracter inesperado", yytext); exit(0); } // hanlde unmatched chars
%%
