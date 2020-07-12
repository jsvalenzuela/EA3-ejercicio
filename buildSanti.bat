mkdir build
C:\GnuWin32\bin\bison -dy Sintactico.y
pause
C:\GnuWin32\bin\flex Lexico.l
pause
C:\MinGW\bin\gcc.exe  -std=c99 terceto.c prints.c archivos.c ts.c y.tab.c lex.yy.c assembler.c -o .\build\final.exe
pause
type prueba.txt | .\build\final.exe


pause
:: del ts.txt
::del intermedia.txt
::del status.txt
::echo "PRUEBA - OK TERCETOS ASIG MULT"
::type .\tests\prueba.txt | .\build\Grupo10.exe
::pause
