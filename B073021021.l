%{
#include "y.tab.h"
#include <stdio.h>
#include <string.h>

#define CPY strcpy(buf,yytext);

int chars = 0, lines = 1;
char buf[256],**table,num=0;
char store[1000][1000] = {};

struct FieldIDs{
	char *IDstring;
    char *IDtype;
	struct FieldIDs *next;
};

struct Fields{
	struct Fields *prev;
	struct FieldIDs *IDhead;
}*head=NULL,*tail=NULL;

void create();
struct FieldIDs *lookup(char* str); //check duplicate variables
int insert(char* str, char *type); //insert matched string to scope
void delonefield(); //delete scope
int check_str(char* str);
int check_com(char* str); // check comment

%}
Comment	[ ]*"(*"([^*]|\*+[^*)])*\*+")"[ ]*
A [aA]
B [bB]
C [cC]
D [dD]
E [eE]
F [fF]
G [gG]
H [hH]
I [iI]
J [jJ]
K [kK]
L [lL]
M [mM]
N [nN]
O [oO]
P [pP]
Q [qQ]
R [rR]
S [sS]
T [tT]
U [uU]
V [vV]
W [wW]
X [xX]
Y [yY]
Z [zZ]
NQUOTE [^']

%%

{Comment} {
    chars++; CPY 
    int i,l=0;
	for(i=0;i<strlen(buf);i++)
	if(buf[i] == '\n'){ l++; }
	chars = chars + strlen(yytext) - 1; 
    lines += l;
}

{A}{N}{D}                   { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_AND; }
{A}{R}{R}{A}{Y}             { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_ARRAY; }
{B}{E}{G}{I}{N}             { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_BEGIN; }
{C}{A}{S}{E}                { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_CASE; }
{C}{O}{N}{S}{T}             { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_CONST; }
{D}{O}                      { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_DO; }
{D}{O}{W}{N}{T}{O}          { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_DOWNTO; }
{E}{L}{S}{E}                { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_ELSE; }
{E}{N}{D}                   { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_END; }
{F}{O}{R}                   { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_FOR; }
{F}{U}{N}{C}{T}{I}{O}{N}    { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_FUNCTION; }
{G}{O}{T}{O}                { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_GOTO; }
{I}{F}                      { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_IF; }
{M}{O}{D}                   { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_MOD; }
{N}{O}{T}                   { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_NOT; }
{O}{F}                      { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_OF; }
{O}{R}                      { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_OR; }
{P}{R}{O}{C}{E}{D}{U}{R}{E} { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_PROCEDURE; }
{P}{R}{O}{G}{R}{A}{M}       { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_PROGRAM; }
{R}{E}{A}{D}                { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_READ; }
{R}{E}{C}{O}{R}{D}          { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_RECORD; }
{R}{E}{P}{E}{A}{T}          { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_REPEAT; }
{T}{H}{E}{N}                { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_THEN; }
{T}{O}                      { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_TO; }
{T}{Y}{P}{E}                { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_TYPE; }
{U}{N}{T}{I}{L}             { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext);return T_UNTIL; }
{V}{A}{R}                   { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_VAR; }
{W}{H}{I}{L}{E}             { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_WHILE; }

{T}{R}{U}{E}                { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_TRUE; }
{F}{A}{L}{S}{E}             { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_FALSE; }
{M}{A}{X}{I}{N}{T}          { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_MAXINT; }

{A}{B}{S}                   { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_ABS; }
{C}{H}{R}                   { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_CHR; }
{O}{D}{D}                   { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_ODD; }
{O}{R}{D}                   { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_ORD; }
{P}{R}{E}{D}                { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_PRED; }
{S}{Q}{R}                   { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_SQR; }
{S}{Q}{R}{T}                { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_SQRT; }
{S}{U}{C}{C}                { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_SUCC; }

{W}{R}{I}{T}{E}             { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_WRITE; }
{W}{R}{I}{T}{E}{L}{N}       { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_WRITELN; }

{I}{N}{T}{E}{G}{E}{R}       { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_INTEGER_TYPE; }
{R}{E}{A}{L}                { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_REAL_TYPE; }
{C}{H}{A}{R}                { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_CHAR_TYPE; }
{S}{T}{R}{I}{N}{G}          { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_STRING_TYPE; }
{B}{O}{O}{L}{E}{A}{N}       { chars++;  chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_BOOLEAN_TYPE; }

[a-zA-Z]([a-zA-Z0-9_])* {
    chars = chars + strlen(yytext) - 1; 
    strcat(store[lines], yytext);
    yylval.stringVal = strdup(yytext);
    return T_ID;
}


'({NQUOTE}|'')({NQUOTE}|'')+' {
    chars++; CPY 
    chars = chars + strlen(yytext) - 1;
    strcat(store[lines], yytext);
	if(check_str(buf)) {
        yylval.stringVal=strdup(yytext); 
        return T_STRING;
    }else {
        yylval.stringVal=strdup(yytext); 
        return T_STRING;
    }
}

'({NQUOTE}|'')' {
    chars++;
    strcat(store[lines], yytext);
    yylval.stringVal = yytext;
    return T_CHAR;
}

[0-9]+ {
    chars++;
    strcat(store[lines], yytext);
    chars = chars + strlen(yytext) - 1;
    yylval.intVal = atoi(yytext);
    return T_INT;
}

[0-9]+"\."[0-9]+ {
    chars++;
    strcat(store[lines], yytext);
    chars = chars + strlen(yytext) - 1;
    yylval.floatVal = atof(yytext);
    return T_REAL;
}


":=" { chars++;  chars = chars + strlen(yytext) - 1;strcat(store[lines], yytext); return T_ASSIGN; }
":" { chars++; strcat(store[lines], yytext); return T_COLON; }
"," { chars++; strcat(store[lines], yytext); return T_COMMA; }
"." { chars++; strcat(store[lines], yytext); return T_DOT;}
".." { chars++; chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_DOTDOT;}
"=" { chars++; strcat(store[lines], yytext); return T_EQUAL; }
">=" { chars++; chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_GE; }
">" { chars++; strcat(store[lines], yytext); return T_GT; }
"[" { chars++; strcat(store[lines], yytext); return T_LB; }
"<=" { chars++; chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_LE; }
"(" { chars++; strcat(store[lines], yytext); return T_LP; }
"<" { chars++; strcat(store[lines], yytext); return T_LT; }
"-" { chars++; strcat(store[lines], yytext); return T_MINUS; }
"<>" { chars++; chars = chars + strlen(yytext) - 1; strcat(store[lines], yytext); return T_UNEQUAL; }
"+" { chars++; strcat(store[lines], yytext); return T_PLUS; }
"]" { chars++; strcat(store[lines], yytext); return T_RB; }

")" { chars++; strcat(store[lines], yytext); return T_RP; }
";" { chars++; strcat(store[lines], yytext); return T_SEMI; }
"/" { chars++; strcat(store[lines], yytext); return T_DIV; }
"*" { chars++; strcat(store[lines], yytext); return T_MUL; }
"%" { chars++; strcat(store[lines], yytext); return T_MOD; }
"{" { chars++; strcat(store[lines], yytext); return T_LC; }
"}" { chars++; strcat(store[lines], yytext); return T_RC; }

[\t] { chars++; strcat(store[lines], yytext); }

[\f\r] {}

"\n" { 
    if (strlen(store[lines])) {
        strcat(store[lines], yytext);
        // sprintf(store[lines], "Line %d: %s", lines, strdup(store[lines])); 
    }
    lines++; 
    chars = 0; 
}

" " { chars++; strcat(store[lines], yytext); }

. { chars++; strcat(store[lines], yytext); }

%%

int yywrap(){
    return 1;
}

void create(){
	struct Fields *temp = (struct Fields*)malloc(sizeof(struct Fields));

	temp->IDhead = NULL;
	temp->prev = NULL;
	
	if(head==NULL){
		head = temp;
		tail = temp;
	}
	else{
		temp->prev = tail;
		tail = temp;
	}
}

struct FieldIDs *lookup(char* str){
	struct FieldIDs *check;
	
	check = tail->IDhead;
	
	while(check!=NULL){
		if(!strcmp(str,check->IDstring)) return check;
		else check = check->next;
	}
	
	return check;
}

int insert(char* str, char* type){
	struct FieldIDs *temp = (struct FieldIDs*)malloc(sizeof(struct FieldIDs));
	struct FieldIDs *check;

	temp->IDstring = strdup(str);
    temp->IDtype = strdup(type);
	temp->next = NULL;
	
	if(tail->IDhead==NULL){
		tail->IDhead = temp;
	}else{
		check = tail->IDhead;
		while(check->next!=NULL) check = check->next;
		check->next = temp;
	}
}

void delonefield(){
	struct Fields *temp;
	struct FieldIDs *del,*del2;

	temp = tail;
	if(tail->prev!=NULL){
		tail = tail->prev;
	}
	else{
		tail = NULL;
	}
	temp->prev = NULL;

	del = temp->IDhead;
	while(del!=NULL){
		del2 = del;
		del = del->next;
		free(del2);
	}
	free(temp);
}

int check_com(char* str){
	int i;
	for(i=2;i<strlen(str)-2;i++){
		if(str[i]=='*' && str[i+1]=='/')
			return 0;
	}
	return 1;
}

int check_str(char* str){
	int i;
	for(i=1;i<strlen(str)-1;i++){
		if(str[i]=='"'){
			if(!(str[i-1]=='\\' && str[i-2]!='\\')){
				return 0;
			}
		}
	}
	return 1;
}
