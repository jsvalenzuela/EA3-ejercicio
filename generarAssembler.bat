mkdir build
C:\GnuWin32\bin\bison -dy Sintactico.y
pause
C:\GnuWin32\bin\flex Lexico.l
pause
C:\MinGW\bin\gcc.exe prints.c archivos.c ts.c y.tab.c lex.yy.c  -o .\build\final.exe
pause
type testing.txt | .\build\final.exe


pause
:: del ts.txt
::del intermedia.txt
::del status.txt
::pause
