all:	clean y.tab.c lex.yy.c
	gcc lex.yy.c y.tab.c -ly -lfl -o B073021021

y.tab.c:
	bison  -y -d B073021021.y

lex.yy.c:
	flex B073021021.l

clean:
	rm -f B073021021 lex.yy.c y.tab.c y.tab.h
