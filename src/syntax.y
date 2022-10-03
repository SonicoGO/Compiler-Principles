%{
#include "node.h"
#include "lex.yy.c"


Node* root;
extern int errornum;
void yyerror(char* msg);
%}

// Tokens
%token INT FLOAT STRUCT ID TYPE COMMA SEMI DOT
%token PLUS MINUS STAR DIV RELOP ASSIGNOP
%token AND OR NOT IF ELSE WHILE 
%token RETURN LP RP LB RB LC RC 

// High-level Definitions
%type Program ExtDefList ExtDef ExtDecList   
// Specifiers
%type Specifier StructSpecifier OptTag Tag 
// Declarators 
%type VarDec FunDec VarList ParamDec    
// Statements     
%type CompSt StmtList Stmt   
// Local Definitions                
%type DefList Def Dec DecList   
// Expressions
%type Exp Args   

// Precedence & Associativity
%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%right NOT
%left DOT
%left LB RB
%left LP RP
%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE


%%

Program: ExtDefList { $$ = newNode("Program", NULL, @$.first_line, false, 1, $1); root = $$; }
    ;
ExtDefList: ExtDef ExtDefList { $$ = newNode("ExtDefList", NULL, @$.first_line, false, 2, $1, $2); }
    | /* empty */ { $$ = NULL; }
    ;
ExtDef: Specifier ExtDecList SEMI { $$ = newNode("ExtDef", NULL, @$.first_line, false, 3, $1, $2, $3); }
    | Specifier SEMI { $$ = newNode("ExtDef", NULL, @$.first_line, false, 2, $1, $2); }
    | Specifier FunDec CompSt { $$ = newNode("ExtDef", NULL, @$.first_line, false, 3, $1, $2, $3); }
    ;
ExtDecList: VarDec { $$ = newNode("ExtDecList", NULL, @$.first_line, false, 1, $1); }
    | VarDec COMMA ExtDecList { $$ = newNode("ExtDecList", NULL, @$.first_line, false, 3, $1, $2, $3); }
    ;
Specifier: TYPE { $$ = newNode("Specifier", NULL, @$.first_line, false, 1, $1); }
    | StructSpecifier { $$ = newNode("Specifier", NULL, @$.first_line, false, 1, $1); }
    ;
StructSpecifier: STRUCT OptTag LC DefList RC { $$ = newNode("StructSpecifier", NULL, @$.first_line, false, 5, $1, $2, $3, $4, $5); }
    | STRUCT Tag { $$ = newNode("StructSpecifier", NULL, @$.first_line, false, 2, $1, $2); }
    ;
OptTag: ID { $$ = newNode("OptTag", NULL, @$.first_line, false, 1, $1); }
    | /* empty */ { $$ = NULL; }
    ;
Tag: ID { $$ = newNode("Tag", NULL, @$.first_line, false, 1, $1); }
    ;
VarDec: ID { $$ = newNode("VarDec", NULL, @$.first_line, false, 1, $1); }
    | VarDec LB INT RB { $$ = newNode("VarDec", NULL, @$.first_line, false, 4, $1, $2, $3, $4); }
    ;
FunDec: ID LP VarList RP { $$ = newNode("FunDec", NULL, @$.first_line, false, 4, $1, $2, $3, $4); }
    | ID LP RP { $$ = newNode("FunDec", NULL, @$.first_line, false, 3, $1, $2, $3); }
    ;
VarList: ParamDec COMMA VarList { $$ = newNode("VarList", NULL, @$.first_line, false, 3, $1, $2, $3); }
    | ParamDec { $$ = newNode("VarList", NULL, @$.first_line, false, 1, $1); }
    ;
ParamDec: Specifier VarDec { $$ = newNode("ParamDec", NULL, @$.first_line, false, 2, $1, $2); }
    ;
CompSt: LC DefList StmtList RC { $$ = newNode("CompSt", NULL, @$.first_line, false, 4, $1, $2, $3, $4); }
    ;
StmtList: Stmt StmtList { $$ = newNode("StmtList", NULL, @$.first_line, false, 2, $1, $2); }
    | /* empty */ { $$ = NULL; }
    ;
Stmt: Exp SEMI { $$ = newNode("Stmt", NULL, @$.first_line, false, 2, $1, $2); }
    | CompSt { $$ = newNode("Stmt", NULL, @$.first_line, false, 1, $1); }
    | RETURN Exp SEMI { $$ = newNode("Stmt", NULL, @$.first_line, false, 3, $1, $2, $3); }
    | IF LP Exp RP Stmt { $$ = newNode("Stmt", NULL, @$.first_line, false, 5, $1, $2, $3, $4, $5); }
    | IF LP Exp RP Stmt ELSE Stmt { $$ = newNode("Stmt", NULL, @$.first_line, false, 7, $1, $2, $3, $4, $5, $6, $7); }
    | WHILE LP Exp RP Stmt { $$ = newNode("Stmt", NULL, @$.first_line, false, 5, $1, $2, $3, $4, $5); }
    ;
DefList: Def DefList { $$ = newNode("DefList", NULL, @$.first_line, false, 2, $1, $2); }
    | /* empty */ { $$ = NULL; }
    ;
Def: Specifier DecList SEMI { $$ = newNode("Def", NULL, @$.first_line, false, 3, $1, $2, $3); }
    ;
DecList: Dec { $$ = newNode("DecList", NULL, @$.first_line, false, 1, $1); }
    | Dec COMMA DecList { $$ = newNode("DecList", NULL, @$.first_line, false, 3, $1, $2, $3); }
    ;
Dec: VarDec { $$ = newNode("Dec", NULL, @$.first_line, false, 1, $1); }
    | VarDec ASSIGNOP Exp { $$ = newNode("Dec", NULL, @$.first_line, false, 3, $1, $2, $3); }
    ;
Exp: Exp ASSIGNOP Exp { $$ = newNode("Exp", NULL, @$.first_line, false, 3, $1, $2, $3); }
    | Exp AND Exp { $$ = newNode("Exp", NULL, @$.first_line, false, 3, $1, $2, $3); }
    | Exp OR Exp { $$ = newNode("Exp", NULL, @$.first_line, false, 3, $1, $2, $3); }
    | Exp RELOP Exp { $$ = newNode("Exp", NULL, @$.first_line, false, 3, $1, $2, $3); }
    | Exp PLUS Exp { $$ = newNode("Exp", NULL, @$.first_line, false, 3, $1, $2, $3); }
    | Exp MINUS Exp { $$ = newNode("Exp", NULL, @$.first_line, false, 3, $1, $2, $3); }
    | Exp STAR Exp { $$ = newNode("Exp", NULL, @$.first_line, false, 3, $1, $2, $3); }
    | Exp DIV Exp { $$ = newNode("Exp", NULL, @$.first_line, false, 3, $1, $2, $3); }
    | LP Exp RP { $$ = newNode("Exp", NULL, @$.first_line, false, 3, $1, $2, $3); }
    | MINUS Exp %prec NOT { $$ = newNode("Exp", NULL, @$.first_line, false, 2, $1, $2); }
    | NOT Exp { $$ = newNode("Exp", NULL, @$.first_line, false, 2, $1, $2); }
    | ID LP Args RP { $$ = newNode("Exp", NULL, @$.first_line, false, 4, $1, $2, $3, $4); }
    | ID LP RP { $$ = newNode("Exp", NULL, @$.first_line, false, 3, $1, $2, $3); }
    | Exp LB Exp RB { $$ = newNode("Exp", NULL, @$.first_line, false, 4, $1, $2, $3, $4); }
    | Exp DOT ID { $$ = newNode("Exp", NULL, @$.first_line, false, 3, $1, $2, $3); }
    | ID { $$ = newNode("Exp", NULL, @$.first_line, false, 1, $1); }
    | INT { $$ = newNode("Exp", NULL, @$.first_line, false, 1, $1); }
    | FLOAT { $$ = newNode("Exp", NULL, @$.first_line, false, 1, $1); }
    ;
Args: Exp COMMA Args { $$ = newNode("Args", NULL, @$.first_line, false, 3, $1, $2, $3); }
    | Exp { $$ = newNode("Args", NULL, @$.first_line, false, 1, $1); }
    ;

%%

void yyerror(char* msg) {
    fprintf(stderr, "Error type B at line %d: %s.\n", yylineno, msg);
}
