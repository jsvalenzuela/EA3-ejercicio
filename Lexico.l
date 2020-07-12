%{

/* include area */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "y.tab.h"
#include "valid.type.h"

%}
%option noyywrap
%option yylineno
DIGITO					[0-9]
LETRA					[a-zA-Z]
CONST_STRING               \"({LETRA}|{DIGITO}|.)+\"
ID						{LETRA}({LETRA}|{DIGITO})*
CTE 					{DIGITO}
%%
"VAR"                                   return VAR;
"ENDVAR"                                return ENDVAR;
"PRINT"                                 return PRINT;
"READ"                                  return READ;
":="                                    return OP_ASIG;
"("                                     return PARA;
")"                                     return PARC;
"["                                     return CA;
"]"                                     return CC;
","                                     return COMA;
";"                                     return PYC;
"CONTAR"                                return CONTAR;
"INTEGER"                               { yylval.stringValue = strdup(yytext); return TIPO_INTEGER; }
"STRING"								{ yylval.stringValue = strdup(yytext); return TIPO_STRING; }
{CONST_STRING}																			{ validType(yytext, TYPE_STRING); yylval.stringValue = strdup(yytext); return CONST_STRING; }
{CTE}																	{ validType(yytext, TYPE_INT); yylval.intValue = atoi(yytext); return CTE; }

{ID}                 { validType(yytext, TYPE_ID); yylval.stringValue = strdup(yytext); return ID; }

%%
