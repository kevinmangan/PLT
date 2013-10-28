%{  %}

%token LPAREN RPAREN LBRACE RBRACE LBRACK RBRACK
%token SEMI COMMA ASSIGN COLON ARROW CONCAT ACCESS
%token PLUS MINUS TIMES DIVIDE MOD
%token EQ NEQ LT LEQ GT GEQ AND OR NOT
%token RETURN IF ELIF ELSE FOR WHILE
%token <string> ID
%token <float> NUM_LIT
%token <bool> BOOLEAN_LIT
%token <string> STRING_LIT
%token EOF

%nonassoc IF
%nonassoc ELSE
%nonassoc ELIF
%nonassoc ASSIGN COLON
%left CONCAT
%left AND OR
%left EQ NEQ
%left LT GT LEQ GEQ
%nonassoc NOT
%left PLUS MINUS
%left TIMES DIVIDE MOD
%nonassoc LBRACE RBRACE
%nonassoc LPAREN RPAREN
%nonassoc LBRACK RBRACK
%left ACCESS

%start program
%type <string> program

%%

program:
  stmt_list { $1 }

stmt_list:
   /* nothing */  { "" }
 | stmt_list stmt { $1 ^ " " ^ $2 }

body:
   LBRACE stmt_list RBRACE { "\n{\n" ^ $2 ^ "\n}\n" }

stmt:
    assignment SEMI                                                 { " " ^ $1 ^ ";\n"  }
  | func_call SEMI                                                  { " " ^ $1 ^ ";\n"  }
  | FOR LPAREN assign_opt SEMI expr_opt SEMI assign_opt RPAREN body { "FOR " ^ $3 ^ ";" ^ $5 ^ ";" ^ $7 ^ $9 }
  | WHILE LPAREN expr RPAREN body                                   { "WHILE " ^ $3 ^ $5 }
  | IF LPAREN expr RPAREN body elifs else_opt                       { "IF " ^ $3 ^ " THEN " ^ $5 ^ $6 ^ $7 }
  | RETURN expr SEMI                                                { "RETURN " ^ $2 }

assign_opt:
    /* nothing */ { " " }
  | assignment    { $1 }

assignment:
    ID ASSIGN expr     { $1 ^ " = " ^ $3 }
  | access ASSIGN expr { $1 ^ " = " ^ $3 }

expr_opt:
    /* nothing */ { " " }
  | expr          { $1 }

expr:
    NUM_LIT            { "'" ^ (string_of_float $1) ^ "'" }
  | BOOLEAN_LIT        { "'" ^ (string_of_bool $1) ^ "'" }
  | STRING_LIT         { "'" ^ $1 ^ "'" }
  | ID                 { $1 }
  | func_create        { $1 }
  | func_call          { $1 }
  | access             { $1 }
  | list_create        { $1 }
  | obj_create         { $1 }
  | LPAREN expr RPAREN { "(" ^ $2 ^ ")" }
  | expr CONCAT expr   { $1 ^ " ^ "  ^ $3 }
  | expr PLUS   expr   { $1 ^ " + "  ^ $3 }
  | expr MINUS  expr   { $1 ^ " - "  ^ $3 }
  | expr TIMES  expr   { $1 ^ " * "  ^ $3 }
  | expr DIVIDE expr   { $1 ^ " / "  ^ $3 }
  | expr MOD expr      { $1 ^ " % "  ^ $3 }
  | expr EQ     expr   { $1 ^ " == " ^ $3 }
  | expr NEQ    expr   { $1 ^ " != " ^ $3 }
  | expr LT     expr   { $1 ^ " < "  ^ $3 }
  | expr LEQ    expr   { $1 ^ " <= " ^ $3 }
  | expr GT     expr   { $1 ^ " > "  ^ $3 }
  | expr GEQ    expr   { $1 ^ " >= " ^ $3 }
  | expr AND    expr   { $1 ^ " && " ^ $3 }
  | expr OR     expr   { $1 ^ " || " ^ $3 }
  | NOT expr           { "!" ^ $2 }

elifs:
    /* nothing */                      { " " }
  | ELIF LPAREN expr RPAREN body elifs { "ELIF (" ^ $3 ^ ")" ^ $5 }

else_opt:
    /* nothing */ { " " }
  | ELSE body     { "ELSE " ^ $2 }

/***************
    FUNCTIONS 
***************/

/* 
  1. () -> body
  DON'T FORGET THAT WE DID SOME WACK SHIT HERE YO!!!!!
  2. (x) -> body
  3. x -> body
  4. (x,y,z) -> body 
*/
func_create:
    LPAREN RPAREN ARROW body              { "() -> " ^ $4 }
  | ID ARROW body                         { $1 ^ " -> "  ^ $3 }
  | LPAREN expr RPAREN ARROW body         { $2 ^ " -> " ^ $5 }
  | LPAREN mult_formals RPAREN ARROW body { "(" ^ $2 ^ ") -> " ^ $5 }

mult_formals:
  formal_list COMMA ID { $1 ^ ", " ^ $3 }

formal_list:
    ID                   { $1 }
  | formal_list COMMA ID { $1 ^ ", " ^ $3 }

func_call:
  expr LPAREN actuals_opt RPAREN {$1 ^ "(" ^ $3 ^ ")" }

actuals_opt:
    /* nothing */ { " " }
  | actuals_list  { $1 }

actuals_list:
    expr                    { $1 }
  | actuals_list COMMA expr { $1 ^ ", " ^ $3 }

/***************
    OBJECTS 
***************/

access: 
    expr LBRACK expr RBRACK                    { $1 ^ "[" ^ $3 ^ "]"}
  | expr LBRACK expr_opt COLON expr_opt RBRACK { $1 ^ "[" ^ $3 ^ ":" ^ $5 ^ "]" }
  | expr ACCESS ID                             { $1 ^ "['" ^ $3 ^ "']" }

list_create:
  LBRACK actuals_opt RBRACK { "[" ^ $2 ^ "]" }

obj_create: 
    LBRACE RBRACE            { "{}" }
  | LBRACE properties RBRACE { "{" ^ $2 ^ "}" }

properties: 
    ID COLON expr                  { $1 ^ ": " ^ $3 }
  | properties COMMA ID COLON expr { $1 ^ "," ^ $3 ^ ": " ^ $5 }
