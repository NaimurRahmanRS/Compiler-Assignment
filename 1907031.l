%{
#include<string.h>
#include<stdio.h>
#include<math.h>

char s[1000];
int var_count=0, statement_count=0, function_count=0, header_count=0, temp_var_count=0, i=0;
int Unary_operator_count=0, Relational_operator_count=0, Assignment_operator_count=0, Logical_operator_count=0, Arithmatic_operator_count=0;
int mcmt_count=0, scmt_count=0;
%}

char [a-zA-Z]
digit [0-9]
special [_@]
space " "
newline "\n"
tabline "\t"
datatype "vari"|"varf"|"varc"
void "void"
Arithmatic_operator "+"|"-"|"*"|"/"|"$"|"^"
Logical_operator "&&"|"||"
Not "!"
Unary_operator "++"|"--"
Relational_operator "ls"|"gr"|"eq"|"ge"|"le"|"ne"
Assignment_operator "="|"+="|"-="|"/="|"*="
int [+-]?[0-9]+
float [+-]?[0-9]+[.][0-9]+([eE][+-]?[0-9]+)?|[+-]?[1-9]+[eE][-+][0-9]+
chars \"[A-Za-z0-9]+\"
ID [a-zA-Z][a-zA-Z0-9]*
scmt [/][/].*
mcmt [ ]*[/][~][a-zA-Z0-9!@$#*(){}_+\-,.^;&=\[\]:\\|?></\n\t ]*[~][/]

%%

{scmt} { 
    scmt_count++;
    printf("single line comment\n"); 
}
{mcmt} { 
    mcmt_count++;
    printf("multiple line comment\n");
}


{datatype}[ ]+{ID}([ ]*"="[ ]*({ID}|{int}|{float}|{chars})([ ]*{Arithmatic_operator}[ ]*({ID}|{int}|{float}|{chars}))*)?([ ]*","[ ]*{ID}([ ]*"="[ ]*({ID}|{int}|{float}|{chars})([ ]*{Arithmatic_operator}[ ]*({ID}|{int}|{float}|{chars}))*)?)* {
	strcpy(s,yytext);
    temp_var_count=0;
	var_count++;
    temp_var_count++;
	for(i=0; i<strlen(s); i++){
		if(s[i]==',')
		{
			var_count++;
            temp_var_count++;
		}
        else if(s[i]=='=')
        {
            Assignment_operator_count++;
            printf("Assignment operator found\n");
        }
        else if(s[i]=='+' || s[i]=='-' || s[i]=='*' || s[i]=='/' || s[i]=='$' || s[i]=='^'){
            Arithmatic_operator_count++;
            printf("Arithmatic operator found\n");
        }
	}
    printf("%d variables declared\n", temp_var_count);
}


; {statement_count++;}


({datatype}|{void})[ ]"main()"[ \n\t]*"{" { 
    function_count++;
    printf("main function\n"); 
}
({datatype}|{void})[ ]{ID}"("({datatype}[ ]+{ID}([ ]*","[ ]*{datatype}[ ]{ID})*)?")"[ \n\t]*"{" {
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
({ID}|{int}|{float}|{chars})[ ]+{Relational_operator}[ ]+({ID}|{int}|{float}|{chars}) {
    Relational_operator_count++;
    printf("Relational operator found\n");
}
{ID}[ ]*{Assignment_operator}[ ]*({ID}|{int}|{float}|{chars}) {
    Assignment_operator_count++;
    printf("Assignment operator found\n");
}
({ID}|{int}|{float}|{chars})[ ]*{Logical_operator}[ ]*({ID}|{int}|{float}|{chars}) {
    Logical_operator_count++;
    printf("Logical operator found\n");
}
{Not}[ ]*({ID}|{int}|{float}|{chars}) {
    Logical_operator_count++;
    printf("Logical operator found\n");
}
({ID}|{int}|{float}|{chars})[ ]*{Arithmatic_operator}[ ]*({ID}|{int}|{float}|{chars}) {
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