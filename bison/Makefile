CC = gcc -g -O0
LEX = flex
LFLAGS = 
YACC = bison
YFLAGS = -v -t
CFLAGS = -ansi -pedantic -Wall -D_GNU_SOURCE
LDFLAGS = 

default: clean ctags myecgif

myecgif: ecgif.lex.o ecgif.tab.o ecgif_ast.o
	$(CC) -o $@ $(LDFLAGS) $^
%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@
ecgif.lex.o: ecgif.lex.c ecgif.tab.c
ecgif.lex.c: ecgif.l 
	$(LEX) $(LFLAGS) -o $@ $^
ecgif.tab.c: ecgif.y 
	$(YACC) $(YFLAGS) -o $@ $^

.PHONY: clean ctags

clean:
	rm -f *.o ecgif.*.c ecgif.*.h ecgif.output myecgif tags

ctags:
	ctags -R *.c *.h
