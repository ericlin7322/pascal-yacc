%{	
#include <stdio.h>
#include <string.h>

#define YYERROR_VERBOSE
#define YELLOW "\e[0;33m"
#define WHITE "\e[m"

int store_line = 0;
int store_char = 0;
char *store_text = "";

// temporarily store one line with many variable
char *def[10] = {};
int def_num = 0;

extern struct FieldIDs{
	char *IDstring;
    char *IDtype;
	struct FieldIDs *next;
};

int yylex();
int linecount = 0;
void yyerror(const char* message);

// look for declaring variable
struct FieldIDs *lookup(char* str);
// add new variable
int insert(char* str, char *type);

extern char* yytext;
extern int yyleng;
extern int chars, lines;
extern struct Fields *head, *tail;

// store origin code
extern char store[1000][1000];

// store error handleling
char store_error[1000][1000] = {};

// if the variable not declarate but used, it will store temporarily
struct FieldIDs *temp_error[10] = {};
int temp_error_num = 0;
%}
%union {
    float 	floatVal;
    int 	intVal;
	char	charVal;
	char	*stringVal;
	struct FieldIDs *fieldIDs;
}
%token <stringVal>  T_PROGRAM T_CONST T_TYPE T_VAR TAB T_RC T_LC T_FUNCTION T_PROCEDURE T_BEGIN T_END T_TRUE T_FALSE T_MAXINT
%token <stringVal> T_READ T_WRITE T_WRITELN T_ABS T_CHR T_ODD T_ORD T_PRED T_SQR T_SQRT T_SUCC
%token <stringVal>  T_IF T_THEN T_ELSE T_REPEAT T_UNTIL T_WHILE T_DO T_CASE T_TO T_DOWNTO T_FOR
%token <stringVal>  T_EQUAL T_UNEQUAL T_GE T_GT T_LE T_LT T_ASSIGN T_PLUS T_MINUS T_MUL T_DIV T_OR T_AND T_NOT T_MOD
%token <stringVal> T_LB T_RB T_LP T_RP T_SEMI T_DOT T_DOTDOT T_COMMA T_COLON
%token <stringVal>  T_INTEGER_TYPE T_BOOLEAN_TYPE T_CHAR_TYPE T_REAL_TYPE T_STRING_TYPE
%token <stringVal>  T_ARRAY T_OF T_RECORD T_GOTO
%token <intVal> T_INT
%token <floatVal> T_REAL
%token <stringVal> T_ID T_CHAR T_STRING ALL NEWLINE

%type <fieldIDs> type varid standtype arraytype varid_dup
%type <fieldIDs> dec_list dec factor term simpexp exp
%%
all:  prog var closure T_DOT
	| prog var closure error {
		sprintf(store_error[lines], "%sLine %d, at char %d, \".\" expect but \"end of file\" found\n", strdup(store_error[lines]), store_line, store_char);
	}

prog: 		T_PROGRAM T_ID T_SEMI
var:		T_VAR dec_list T_SEMI
closure:	T_BEGIN stmt_list T_SEMI T_END
dec_list: 	dec | dec_list T_SEMI dec
dec:
	id T_COLON type {
		if(head==NULL) create();
		for (int i=0;i<def_num;i++) {
			insert(def[i], $3->IDstring);
		}
	}
	| id error type {
		if(head==NULL) create();
		for (int i=0;i<def_num;i++) {
			insert(def[i], $3->IDstring);
		}
		sprintf(store_error[lines], "%sLine %d, at char %d, \":\" expect but \"%s\" found\n", strdup(store_error[lines]), store_line, store_char, store_text);
	}

type: standtype { $$ = $1;}
	| arraytype { $$ = $1;}

standtype:
	T_INTEGER_TYPE {
		insert("integer", "TYPE");
		$$ = lookup("integer");
	} | T_REAL_TYPE {
		insert("real", "TYPE");
		$$ = lookup("real");
	} | T_STRING_TYPE {
		insert("string", "TYPE");
		$$ = lookup("string");
	}

arraytype: T_ARRAY T_LB T_INT T_DOTDOT T_INT T_RB T_OF standtype { $$ = $8; }

id_list:
	T_ID {
		if(lookup($1) == NULL) ;
		else sprintf(store_error[lines],"%sLine %d,error : %s is a duplicate variable!\n", strdup(store_error[lines]),lines,$1);
	}
	| id_list T_COMMA T_ID {
		if(lookup($3) == NULL) ;
		else sprintf(store_error[lines],"%sLine %d,error : %s is a duplicate variable!\n", strdup(store_error[lines]),lines,$3);
	}

id:	T_ID {
		if(head==NULL) create();
		if(lookup($1) == NULL) {def[def_num] = strdup($1);def_num++;}
		else sprintf(store_error[lines],"%sLine %d,error : %s is a duplicate variable!\n", strdup(store_error[lines]),lines,$1);
	}
	| id T_COMMA T_ID {
		if(head==NULL) create();
		if(lookup($3) == NULL) {def[def_num] = strdup($3);def_num++;}
		else sprintf(store_error[lines],"%sLine %d,error : %s is a duplicate variable!\n", strdup(store_error[lines]),lines,$3);
	}
	| id error T_ID {
		sprintf(store_error[lines], "%sLine %d, at char %d, \":\" expect but \"%s\" found\n", strdup(store_error[lines]), store_line, store_char, store_text);
	}

stmt_list:	stmt | stmt_list T_SEMI stmt
stmt:		assign | read | write | for | ifstmt

assign:	
	varid_dup T_ASSIGN simpexp {
		struct FieldIDs *temp = lookup($1->IDstring);
		struct FieldIDs *temp2 = lookup($3->IDstring);
		if (strcmp(temp->IDtype ,temp2->IDtype)) {
			sprintf(store_error[lines], "%sLine %d, at char %d, got \"%s\" expected \"%s\"\n", strdup(store_error[lines]), lines, chars-strlen(yytext)+2, temp->IDtype, temp2->IDtype);
		}
	} 
	| varid_dup T_ASSIGN T_STRING {
		struct FieldIDs *temp = lookup($1->IDstring);
		if (strcmp(temp->IDtype ,"string")) {
			sprintf(store_error[lines],"%sLine %d, at char %d, got \"Constant String\" expected \"SmallInt\"\n", strdup(store_error[lines]), lines, chars-strlen(yytext)+2);
		}
	} 
	| varid_dup error simpexp  {
		sprintf(store_error[lines],"%sLine %d, at char %d, Illegal expression\n", strdup(store_error[lines]), lines, chars + strlen($3->IDstring) );
	} 
	| varid_dup error T_STRING {
		sprintf(store_error[lines],"%sLine %d, at char %d, Illegal expression\n", strdup(store_error[lines]), lines, chars + strlen($3) );
	}

ifstmt:	T_IF T_LP exp T_RP T_THEN body

exp:  simpexp { $$ = $1; } 
	| simpexp relop exp {
	}

relop:	T_GT | T_LT | T_GE | T_LE | T_UNEQUAL | T_EQUAL

simpexp:  term { $$ = $1; } 
		| simpexp T_PLUS term {
			struct FieldIDs *temp = lookup($1->IDstring);
			struct FieldIDs *temp2 = lookup($3->IDstring);

			if (strcmp(temp->IDtype ,temp2->IDtype)) {
				sprintf(store_error[lines],"%sLine %d, at char %d, Operator is not overloaded: \"%s\" + \"%s\"\n", strdup(store_error[lines]), lines, chars+strlen($1->IDstring), temp->IDtype, temp2->IDtype);
			}
		  } 
		| simpexp T_MINUS term

term:
	factor {
		$$ = $1;
	} | factor T_MUL factor {
		if ($1->IDtype == $3->IDtype) {
			$$ = $1;
		}
	} | factor T_DIV factor {
		if ($1->IDtype == $3->IDtype) {
			$$ = $1;
		}
	} | factor T_MOD factor {
		if ($1->IDtype == $3->IDtype) {
			$$ = $1;
		}
	}

factor:	
	varid {
		$$ = $1;
	} | T_INT {
		char a[100];
		sprintf(a, "%d", $1);
		insert(a, "integer");
		$$ = lookup(a);
	} | T_REAL {
		char a[100];
		sprintf(a, "%f", $1);
		insert(a, "real");
		$$ = lookup(a);
	} | T_LP simpexp T_RP {

	} | T_PLUS factor {
		char a[100];
		sprintf(a, "+%d", $1);
		insert(a, "integer");
		$$ = lookup(a);
	} | T_MINUS factor {
		char a[100];
		sprintf(a, "-%d", $1);
		insert(a, "integer");
		$$ = lookup(a);
	}

read:	T_READ T_LP write_list T_RP
write:			T_WRITE T_LP write_list T_RP | T_WRITE | T_WRITELN T_LP write_list T_RP | T_WRITELN
write_list: 	write_exp | write_list T_COMMA write_exp
write_exp:		term | T_ID | T_STRING | T_CHAR
for:	T_FOR index_exp T_DO body

index_exp:	varid T_ASSIGN simpexp T_TO exp

varid:	
	T_ID {
		struct FieldIDs *temp = lookup($1);
		if(temp == NULL) {
			sprintf(store_error[lines], "%sLine %d, at char %d, Identifier not found \"%s\"\n", strdup(store_error[lines]), lines, chars+1, $1);
			temp = (struct FieldIDs*)malloc(sizeof(struct FieldIDs));
			temp->IDstring = $1;
    		temp->IDtype = "";
			temp->next = NULL;
			temp_error[temp_error_num] = temp;
			temp_error_num++;
		}
		$$ = temp;
	} | T_ID T_LB simpexp T_RB {
		struct FieldIDs *temp = lookup($1);
		if(temp == NULL) {
			sprintf(store_error[lines], "%sLine %d, at char %d, Identifier not found \"%s\"\n", strdup(store_error[lines]), lines, chars+1, $1);
			temp = (struct FieldIDs*)malloc(sizeof(struct FieldIDs));
			temp->IDstring = $1;
    		temp->IDtype = "";
			temp->next = NULL;
			temp_error[temp_error_num] = temp;
			temp_error_num++;
		}
		$$ = temp;
	}

varid_dup:	
	T_ID {
		struct FieldIDs *temp = lookup($1);
		if(temp == NULL) {
			sprintf(store_error[lines], "%sLine %d, at char %d, Identifier not found \"%s\"\n", strdup(store_error[lines]), lines, chars-strlen(yytext), $1);
			temp = (struct FieldIDs*)malloc(sizeof(struct FieldIDs));
			temp->IDstring = $1;
    		temp->IDtype = "";
			temp->next = NULL;
		}
		$$ = temp;
	} | T_ID T_LB simpexp T_RB {
		struct FieldIDs *temp = lookup($1);
		if(temp == NULL) {
			sprintf(store_error[lines], "%sLine %d, at char %d, Identifier not found \"%s\"\n", strdup(store_error[lines]), lines, chars-strlen(yytext), $1);
			temp = (struct FieldIDs*)malloc(sizeof(struct FieldIDs));
			temp->IDstring = $1;
    		temp->IDtype = "";
			temp->next = NULL;	
		}
		$$ = temp;
	}

body:	stmt | T_BEGIN stmt_list T_SEMI T_END
%%
int main() {
    yyparse();
	for (int i=1;i<=lines;i++) {
		if (strlen(store_error[i]) == 0) {
			if (strlen(store[i]) != 0)
				printf(WHITE"Line %d: %s", i, store[i]);
		}
		else 
			printf(YELLOW"%s"WHITE,store_error[i]);
	}
    return 0;
}

void yyerror(const char *str) {
 	if(strcmp(str,"syntax error") == 0) {
		store_line = lines;
		store_char = chars+1;
		store_text = strdup(yytext);
	}
	else {
		store_line = lines;
		store_char = chars+1;
		store_text = strdup(yytext);
	}
}

struct FieldIDs *look_error_up(char* str) {
	for (int i=0;i<temp_error_num;i++) {
		if(!strcmp(str,temp_error[i]->IDstring)) return temp_error[i];
	}
}