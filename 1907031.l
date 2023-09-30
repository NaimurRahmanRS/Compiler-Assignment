%{

// header files
#include<string.h>
#include<stdio.h>
#include<math.h>
#include<stdlib.h>

// keyword and datatype string collection
const char* keywords[] = {"vari","varf","varc","start","end","return","function","is","or","oris","si","loopf","loopw","ls","gr","eq","ge","le","ne","void","as","array",NULL};
const char* datatype[] = {"vari","varf","varc",NULL};

// check if a new variable name is a keyword
int is_keyword(const char* word) {
    for (int i = 0; keywords[i] != NULL; i++) {
        if (strcmp(keywords[i], word) == 0) {
            return 1;
        }
    }
    return 0;
}

// check if a new variable is a datatype
int is_datatype(const char* word) {
    for (int i = 0; datatype[i] != NULL; i++) {
        if (strcmp(datatype[i], word) == 0) {
            return 1;
        }
    }
    return 0;
}

// symbol table linked list that adds new values into head
struct Symbol_Table {
    char* name;
    char* datatype;
    char* value;
    struct Symbol_Table* next;
};

// head pointer for symbol table linked list
struct Symbol_Table* head = NULL;

// insert a new variable into symbol table
void insert_variable(const char* name, const char* datatype, const char* value) {
    struct Symbol_Table* new_symbol = malloc(sizeof(struct Symbol_Table));
    new_symbol->name = strdup(name);
    new_symbol->datatype = strdup(datatype);
    new_symbol->value = strdup(value);
    new_symbol->next = head;
    head = new_symbol;
}

// check if a variable is already declared
int is_declared(const char* name) {
    struct Symbol_Table* tmp = head;
    while (tmp != NULL) {
        if (strcmp(tmp->name, name) == 0) {
            return 1; // variable is already declared
        }
        tmp = tmp->next;
    }
    return 0; // variable is not declared
}

// update the value of a variable in the symbol table
int update_value(const char* name, const char* value) {
    struct Symbol_Table* tmp = head;
    while (tmp != NULL) {
        if (strcmp(tmp->name, name) == 0) {
            free(tmp->value); // free previous value
            tmp->value = strdup(value); // update new value
            return 1; 
        }
        tmp = tmp->next;
    }
    return 0; 
}

char s[1000];
int var_count=0, statement_count=0, function_count=0, header_count=0, temp_var_count=0, i=0;
int Unary_operator_count=0, Relational_operator_count=0, Assignment_operator_count=0, Logical_operator_count=0, Arithmatic_operator_count=0;
int mcmt_count=0, scmt_count=0, array_count=0;
int is_declared_check=0;
%}

/* Labels for future need */
%x CONDITION
%x WHILE_BODY
%x WHILE_BEGIN
%x WHILE_END
%x IF_BODY
%x IF_CONDITION

char [a-zA-Z]
digit [0-9]
special [_@]
space " "
newline "\n"
tabline "\t"
datatype "vari"|"varf"|"varc"
void "void"
Arithmatic_operator "+"|"-"|"*"|"/"|"$"
Logical_operator "&&"|"||"
Not "!"
Unary_operator "++"|"--"
Relational_operator "ls"|"gr"|"eq"|"ge"|"le"|"ne"
Assignment_operator "="|"+="|"-="|"/="|"*="
int [+-]?[0-9]+
float [+-]?[0-9]+[.][0-9]+([eE][+-]?[0-9]+)?|[+-]?[1-9]+[eE][-+][0-9]+
string \"[A-Za-z0-9]+\"
ID [a-zA-Z][a-zA-Z0-9]*
scmt \/\/[^\n]*
mcmt \/\*([^*]|\*[^\/])*\*\/

%%

{scmt} { 
    scmt_count++;
    printf("single line comment\n"); 
}
{mcmt} { 
    mcmt_count++;
    printf("multiple line comment\n");
}


{datatype}[ ]+{ID}("="({ID}|{int}|{float}|{string}))?([ ]*","[ ]*{ID}("="({ID}|{int}|{float}|{string}))?)* {
    char* token = strtok(yytext, " ,\t");
    char* type;
    int invalid = 0;
    temp_var_count=0; // Initialize the counter

    while (token != NULL) {
        if (!is_datatype(token)) {
            if (is_keyword(token)) {
                printf("ERROR: Reserved keyword can't be used as a variable name: %s\n", token);
                invalid = 1;
                break;
            }
            if (is_declared(token)) {
                printf("ERROR: Variable '%s' is already declared.\n", token);
                invalid = 1;
                break;
            } else {
                // Check for initialization
                char* init_value = strchr(token, '=');
                if (init_value != NULL) {
                    // Extract the initialization value
                    *init_value = '\0'; // Null-terminate the variable name
                    const char* varName = token;
                    if (is_declared(varName)) {
                        printf("ERROR: Variable '%s' is already declared.\n", varName);
                        invalid = 1;
                        break;
                    }
                    if (is_keyword(varName)) {
                        printf("ERROR: Reserved keyword can't be used as a variable name: %s\n", varName);
                        invalid = 1;
                        break;
                    }
                    Assignment_operator_count++;
                    printf("Assignment operator found\n");
                    init_value++; // Move to the value part
                    insert_variable(token, type, init_value);
                    printf("Variable name: %s, Datatype: %s, Initialized with: %s\n", token, type, init_value);
                } else {
                    insert_variable(token, type, "");
                    printf("Variable name: %s, Datatype: %s\n", token, type);
                }

                // Increment the counter for successfully declared variables
                temp_var_count++;
                var_count++;
            }
        } else {
            type = token;
        }
        token = strtok(NULL, " ,\t");
    }
    if (!invalid) {
        printf("Total variables declared: %d\n", temp_var_count);
    }
}

{ID}[ ]*"="[ ]*({ID}|{int}|{float}|{string}) {
    char* var = strtok(yytext, " =");
    char* val = strtok(NULL, " =");
    if (!is_declared(var)) {
        printf("ERROR: Variable '%s' not declared before assignment.\n", var);
    }
    else {
        printf("ASSIGNMENT: Variable '%s' assigned value '%s'\n", var, val);
        update_value(var, val); // Update the variable value
    }
    
}

"array"[ ]+{datatype}[ ]+{ID}[ ]+"of"[ ]+{int} {
    char* token = strtok(yytext, " \t");
    char* type;
    int invalid = 0;
    while (token != NULL) {
        if(strcmp(token, "array")==0){
            
        }
        else if (!is_datatype(token)) {
            if (is_keyword(token)) {
                printf("ERROR: Reserved keyword can't be used as a variable name: %s\n", token);
                invalid = 1;
                break;
            }
            if (is_declared(token)) {
                printf("ERROR: Variable '%s' is already declared.\n", token);
                invalid = 1;
                break;
            } else {
                insert_variable(token, type, "");
                printf("Variable name: %s, Datatype: %s\n", token, type);
            }
            array_count++;
            break;
        }
        else{
            type = token;
        }
        token = strtok(NULL, " \t");
    }
    if (!invalid) {
        printf("Array declared\n");
    }
} 

"loopw"[ ]+"as"[ ]+ { BEGIN(CONDITION); }
<CONDITION>({ID}|{int}|{float}|{string})[ ]+{Relational_operator}[ ]+({ID}|{int}|{float}|{string})({Logical_operator}({ID}|{int}|{float}|{string})[ ]+{Relational_operator}[ ]+({ID}|{int}|{float}|{string}))* {
    printf("while condition\n");
    BEGIN(WHILE_BODY);
}

<WHILE_BODY>"{"  { printf("WHILE LOOP: Start\n"); }
<WHILE_BODY>"}"  { 
    printf("WHILE LOOP: End\n");
    BEGIN(INITIAL);
}
<WHILE_BODY>.*  { 
    // Process the code block here, e.g., "do something"
    printf("WHILE LOOP Code: %s\n", yytext);
}

; {statement_count++;}


({datatype}|{void})[ ]"main()"[ \n\t]*"{" { 
    function_count++;
    printf("main function\n"); 
}
({datatype}|{void})[ ]+"function"[ ]+{ID}"("({datatype}[ ]+{ID}([ ]*","[ ]*{datatype}[ ]{ID})*)?")"[ \n\t]*"{" {
    function_count++;
    printf("function declaration\n");
}


"#include<".*">" { 
    header_count++;
    printf("header file\n");
}


{ID}{Unary_operator} {
    Unary_operator_count++;
    printf("Unary operator found\n");
}
{Unary_operator}{ID} {
    Unary_operator_count++;
    printf("Unary operator found\n");
}
({ID}|{int}|{float}|{string})[ ]+{Relational_operator}[ ]+({ID}|{int}|{float}|{string}) {
    Relational_operator_count++;
    printf("Relational operator found\n");
}
{ID}[ ]*{Assignment_operator}[ ]*({ID}|{int}|{float}|{string}) {
    Assignment_operator_count++;
    printf("Assignment operator found\n");
}
({ID}|{int}|{float}|{string})[ ]*{Logical_operator}[ ]*({ID}|{int}|{float}|{string}) {
    Logical_operator_count++;
    printf("Logical operator found\n");
}
{Not}[ ]*({ID}|{int}|{float}|{string}) {
    Logical_operator_count++;
    printf("Logical operator found\n");
}
({ID}|{int}|{float}|{string})[ ]*{Arithmatic_operator}[ ]*({ID}|{int}|{float}|{string}) {
    Arithmatic_operator_count++;
    printf("Arithmatic operator found\n");
}
. {}

%%

int yywrap()
{
	return 1;
}

int main()
{	
	yyin = fopen( "sample.c", "r" );
	yylex();
    printf("%d variables declared\n", var_count);
    printf("%d arrays declared\n", array_count);
    printf("%d functions declared\n", function_count);
    printf("%d headers declared\n", header_count);
    printf("%d Unary operators\n", Unary_operator_count);
    printf("%d Relational operators\n", Relational_operator_count);
    printf("%d Assignment operators\n", Assignment_operator_count);
    printf("%d Logical operators\n", Logical_operator_count);
    printf("%d Arithmatic operators\n", Arithmatic_operator_count);
    printf("%d single line comments\n", scmt_count);
    printf("%d multiple line comments\n", mcmt_count);
	printf("%d statements\n", statement_count);
	return 0;
}