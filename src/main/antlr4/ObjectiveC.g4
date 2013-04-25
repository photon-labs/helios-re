/**
* Objective-C version 2
* Based on ObjectiveC grammar found in Learning Objective-C
* This is a modified version of initial grammar by Cedric Cuche - June 2008
* It's a Work in progress, most of the .h and .m files can be parsed
* April 2013 Nikhil Patel
**/

grammar ObjectiveC;

@header{
	package com.photon.reverseEngg;	
}

translation_unit: external_statement+ EOF;

external_statement	 	:	COMMENT 
						|	LINE_COMMENT 
						| 	preprocessor_declaration
						|	class_declaration
						| 	interface_declaration
						| 	class_implementation
						| 	function_definition
						|	function_declaration
						| 	declaration 
						| 	protocol_declaration
						| 	protocol_declaration_list
						| 	class_declaration
						|	class_method_definition
						| 	instance_method_definition
						|	variable_declaration
						|	property_declaration
						|	class_method_declaration
						|	instance_method_declaration
						|	synthesize_stmt
						|	dynamic_statement
						|	pragma_statement
						|	compound_statement
						;

preprocessor_declaration	:	'#' 'import' file_specification	# Import
							| 	'#include' file_specification	# Include
							| 	'#define' expr? statement? (';')? 			# Define
							| 	'#ifdef' expr 					# Ifdef
							| 	'#if' expr 						# If
							|	'#else'		 					# Else
							| 	'#undef' expr 					# Undef
							|	'#ifndef' expr 					# Ifndef
							| 	'#endif' 						# Endif
							;

macro_specification : .+? '##'? ;

file_specification 	: 	STRING_LITERAL 
					| 	'<' ((IDENTIFIER|'in'|'+') ('/' | '\\' | '.')?)+ '>' 
					;

interface_declaration 	:	'@interface' 
							class_name (':' superclass_name)? 
							( '<' type_specifier preprocessor_declaration* ((',' type_specifier preprocessor_declaration*)*)? '>' | ('(' type_specifier? ')') )*
							(instance_variables)?
							(external_statement+)?
							'@end'? ';'?
						;

property_declaration 	:	req_specifier? '@property' 
							('(' IDENTIFIER('=' IDENTIFIER)? ':'? (',' IDENTIFIER ('=' IDENTIFIER)? ':'?)* ')')?
							(((class_name | type_specifier)+ '*'? IDENTIFIER expr? ';') | declaration)
						;

class_declaration 	:	'@class' class_name (',' class_name)* ';' ;

class_method_declaration 	: 	req_specifier? ('+' method_declaration) ;

instance_method_declaration	: 	req_specifier? ('-' method_declaration) ;

method_declaration 	:	( method_type )? method_selector init_declarator_list? (','expr)? ';' ;

class_implementation 	:	'@implementation'
							class_name ( ':' superclass_name )?
							('(' type_specifier? ')')?
							(instance_variables)?
							(external_statement+)?
							'@end'
						;

req_specifier	:	'@required' | '@optional';

synthesize_stmt 	:	'@synthesize' synthesize_var (',' synthesize_var)* ';' ;
synthesize_var	:	prop_name ( '=' instance_var_name )? ;

variable_declaration 	:	(visibility_specification)? ('__weak')? IDENTIFIER? type_qualifier? ((class_name+ '*'? IDENTIFIER (',' '*'? IDENTIFIER)*) | (type_specifier+ '*'? IDENTIFIER+ ('(' STRING_LITERAL ')' )? (',' IDENTIFIER)*)) ';' ;

class_method_definition 	:	('+' method_definition)	;

instance_method_definition 	:	('-' method_definition)	;
	
method_definition:
	(method_type)? method_selector (init_declarator_list)? (','expr)? '{' ( weak_specifier? statement | preprocessor_declaration)* '}' ';'?;

category_implementation :	'@implementation'(
							class_name '(' category_name ')'
							( implementation_definition_list )?
							)'@end'
						;

autoreleasepool_stmt	:	'@autoreleasepool' statement ;

protocol_declaration 	:	'@protocol'(
							protocol_name ( protocol_reference_list )?
							( interface_declaration_list )?
							)'@end' ';'?
						;	

protocol_declaration_list 	:	('@protocol' protocol_list';');

protocol_reference_list 	:	('<' protocol_list '>');

protocol_list 	:	protocol_name (',' protocol_name)*;

class_name 	:	IDENTIFIER;

superclass_name	:	IDENTIFIER;

prop_name 	:	IDENTIFIER;

instance_var_name 	:	IDENTIFIER;

signature_name 	:	IDENTIFIER;

param_name 	:	IDENTIFIER;

category_name 	:	IDENTIFIER;

protocol_name 	:	IDENTIFIER;

instance_variables	:	'{' (instance_variable_declaration| pragma_statement)+ '}';

instance_variable_declaration	:	(visibility_specification | weak_specifier | specifier_qualifier_list | init_declarator_list)+ ';'?	;

visibility_specification 	:	'@private' | '@protected' | '@package' | '@public';

interface_declaration_list	: 	(declaration | class_method_declaration | instance_method_declaration | property_declaration | pragma_statement)+	;

implementation_definition_list 	:	(
									function_definition
									| 	declaration 
									| 	class_method_definition 
									| 	instance_method_definition
									)+
								;

method_selector	:	selector |(keyword_declarator+ (parameter_list)? ) ;

keyword_declarator	:	selector? ':' method_type* IDENTIFIER (',' expr+)?;

selector 	:	IDENTIFIER;

method_type 	:	'(' type_name? ')';

type_specifier 	: 	'void' | 'char' | 'short' | 'int' | 'long' | 'float' | 'double' | 'signed' | 'unsigned' | 'BOOL'
				|	('id' ( protocol_reference_list )? )
				|	(class_name ( protocol_reference_list )?)
				|	struct_or_union_specifier
				|	enum_specifier 
				|	IDENTIFIER
				;

type_qualifier	:	'const' | 'volatile' | 'out' | 'inout' | 'bycopy' | 'byref' | 'oneway' ;

weak_specifier	:	'*'? '__weak';

receiver	:	expr | class_name | 'super';

message_selector:	keyword_argument+ (',' '##'? keyword_argument+ )? | selector ;

keyword_argument:	(selector? ':' (('^'? expr) | ('^()')) compound_statement?) | expr;

selector_name 	:	selector | (selector? ':')+;

exception_declarator:	declarator;

pragma_statement:	req_specifier? '#pragma' 'mark'? (instance_method_definition | class_method_definition | (('-'|'--')* ((IDENTIFIER | pragma_identifier | 'for' | 'in' | STRING_LITERAL | '(' | ')' | '\'' | ',' | '!' | '*' | '&' | '.' ) '/'?)*)) ;	

pragma_identifier 	:	IDENTIFIER '-' IDENTIFIER;

try_statement	:	'@try' statement ;

catch_statement 	:	'@catch' '(' declaration_specifiers declarator ')' statement;

finally_statement 	:	'@finally' statement;

throw_statement 	:	'@throw' '('IDENTIFIER')';

try_block	:	try_statement catch_statement ( finally_statement )?;

synchronized_statement 	:	'@synchronized' '(' expr ')' statement;

dynamic_statement	:	'@dynamic' IDENTIFIER (',' IDENTIFIER)* ';'? ;

function_declaration :	declaration_specifiers declarator+ ';' ;

function_definition :	declaration_specifiers declarator+ compound_statement ;

declaration 	: 	declaration_specifiers ((init_declarator_list? ';'?) | (STRING_LITERAL '{') )  ;

declaration_specifiers 	:	(storage_class_specifier | type_specifier | type_qualifier)+ ;

storage_class_specifier	:	'auto' | 'register' | 'static' | 'extern' | 'typedef';

init_declarator_list 	:	init_declarator (',' init_declarator)* ','? ;
init_declarator 		: 	declarator ('=' initializer)? ;

struct_or_union_specifier: ('struct' | 'union') ( IDENTIFIER | IDENTIFIER? '{' struct_declaration+ '}') ;

struct_declaration 	:	specifier_qualifier_list struct_declarator_list ';' ;

specifier_qualifier_list 	:	(type_specifier | type_qualifier)+ ('(^)' '(' (specifier_qualifier_list init_declarator_list? (',' specifier_qualifier_list init_declarator_list?)*)? ')')?;

struct_declarator_list 	:	struct_declarator (',' struct_declarator)* ;
struct_declarator 	:	declarator | declarator? ':' constant;

enum_specifier 	: 	'enum' ( IDENTIFIER ('{' enumerator_list ','? '}')? | '{' enumerator_list ','? '}') ;

enumerator_list : enumerator (',' enumerator)* ;

enumerator 	:	IDENTIFIER ('=' expr)?;

declarator 	: 	'*' (type_specifier | type_qualifier)* declarator? | direct_declarator ;

direct_declarator 	:	('^')? ((specifier_qualifier_list init_declarator_list?) | IDENTIFIER) declarator_suffix*
                  	| 	'(' declarator ')' declarator_suffix* 
                  	;

declarator_suffix 	:	'[' expr? ']'
		  			| '(' parameter_list? ')'
		  			| '(' exprList? ')'
		  			;

parameter_list 	: 	parameter_declaration_list ( ',' '...' )? ;

parameter_declaration 	:	declaration_specifiers (declarator? | abstract_declarator) ;

initializer 	:	expr+
	    		| 	'{' initializer (',' initializer)* ','? '}' 
	    		;

type_name 	: 	specifier_qualifier_list abstract_declarator? ;

abstract_declarator 	:	'*' type_qualifier* abstract_declarator? 
  						| 	'(' abstract_declarator ')' abstract_declarator_suffix+
  						| 	('[' expr* ']')+
  						;

abstract_declarator_suffix 	:	'[' expr* ']'
  							| 	'('  parameter_declaration_list? ')' 
  							;

parameter_declaration_list 	:	parameter_declaration ( ',' parameter_declaration )* ;

statement 	:	labeled_statement
			|	autoreleasepool_stmt
  			| 	compound_statement
  			|	try_block
  			| 	selection_statement
  			| 	iteration_statement
  			| 	jump_statement
			| 	expr ';'?
  			|	declaration
  			|	synchronized_statement
  			|	dynamic_statement
  			|	pragma_statement
  			|	'#ifdef' expr
  			|	'#endif'
  			| 	'#if' expr 						
			|	'#else'		 					
			| 	'#undef' expr 					
			|	'#ifndef' .+? 					
  			| 	';' 
  			;

labeled_statement	:	IDENTIFIER ':' statement
  					| 	'case' expr ':' statement
  					| 	'default' ':' statement 
  					;

compound_statement 	: 	'{' (statement)* '}' ';'? ;

selection_statement	:	'if' '(' expr ')' statement ('else' statement)?
  					| 	'switch' '(' expr ')' statement 
  					;

iteration_statement	:	'while' '(' expr ')' statement
  					| 	'do' statement 'while' '(' expr ')' ';'?
  					| 	'for' '(' statement? expr? ';' expr? ')' statement
  					|	'for' '(' instance_variable_declaration 'in' expr ')' 
  					;

jump_statement	:	'goto' IDENTIFIER ';'
  				| 	'continue' ';'
  				| 	'break' ';'
  				| 	'return' expr? ';' 
  				;

expr 	:	('[' receiver message_selector ']')				# Message	// access array element or message expr
		| 	'@selector' '(' selector_name ')'				# Selector_expr
		|	'@protocol' '(' protocol_name ')'				# Protocol_expr
		|	'@encode' '(' type_name ')'						# Encode_expr
		|	'(' exprList ')' 								# Parens
		|	'{' exprList '}'								# Curly	
		|	expr '.' expr 									# Dot		// member selection via object name
		|	expr '(' exprList? ')'					# Call2	
		|	expr ('[' expr ']')+							# Index 	// array index - a[i], a[i][j]
		|	expr '->' expr 									# Arrow		// member selection via pointer
		|	('++'<assoc=right>|'--'<assoc=right>) expr 		# PreInc	// pre-increment
		|	expr ('++'<assoc=right>|'--'<assoc=right>) 		# PostInc	// post-increment
		|	('+'<assoc=right>|'-'<assoc=right>) expr 		# AddSub	// unary plus or minus
		|	('!'<assoc=right>|'~'<assoc=right>) expr 		# NegateNot	// logical negation/bitwise complement
		|	'(' specifier_qualifier_list '*'? ')'<assoc=right> expr 		# Cast		// cast
		|	'*'<assoc=right> expr 							# Dereference	// dereference
		|	'&'<assoc=right> expr 							# AddressOf	// address of
		|	'sizeof'<assoc=right> expr 						# SizeOf
		|	expr ('*'|'/'|'%') expr 						# MultDivMod
		|	expr ('+'|'-') expr 							# AddSub
		|	expr ('<<'|'>>') expr 							# ShiftLeftRight	// bitwise shift left/right
		|	expr ('<'|'<='|'>'|'>=') expr 					# LessGreat
		|	expr ('=='|'!=') expr 							# Equal 	// equality comparison
		|	expr '&' expr 									# BitAnd	// bitwise AND
		|	expr '^' expr 									# BitXOR	// bitwise XOR
		| 	expr '|' expr 									# BitOR		// bitwise OR
		|	expr '&&' expr 									# LogicalAnd// logical AND
		|	expr '||' expr 									# LogicalOr	// logical OR
		| 	expr '?' expr ':' expr 							# Ternary	// ternary conditional
		|	expr ('='|'+='|'-='|'*='|'/='|'%='|'&='|'^='|'|='|'<<='|'>>='|'>>>=') expr # OtherOp
		|	expr ',' expr 									# Comma
		|	'^' expr 										# PowerExpr
		|	IDENTIFIER										# Var
		|	'@' STRING_LITERAL							# Label1
		|	'@' '{' expr ':' expr (','? expr ':' expr)* '}'	# AtExpr
		|	STRING_LITERAL									# Label2
		|	INT 											# Int
		|	constant 										# Const
		| 	type_name 										# Typename
		|	'...'											# Dots
		|	'^' compound_statement							# Compound
		|	'#ifdef' expr 									# IfdefExpr
		|	'#endif' 										# EndifExpr
		| 	'#if' expr 										# IfExpr
		|	'#else'		 									# ElseExpr
		| 	'#undef' expr 									# UndefExpr
		|	'#ifndef' .+? 									# IfndefExpr
		|	('##' | '#') IDENTIFIER							# HashVar
		;

exprList	:	expr (','? expr)* ;	// argument list	

constant : DECIMAL_LITERAL | HEX_LITERAL | OCTAL_LITERAL | CHARACTER_LITERAL | FLOATING_WITHOUT_PREFIX | FLOATING_POINT_LITERAL;

IDENTIFIER 	:	LETTER (LETTER|DIGIT)* ;
	
INT : 	DIGIT+;

CHARACTER_LITERAL	:	'\'' ( EscapeSequence | ~('\''|'\\') ) '\'' ;

STRING_LITERAL 	: 	'"' ( '\\"' | . )*? '"' ;

HEX_LITERAL : '0' ('x'|'X') HexDigit+ IntegerTypeSuffix? ;

DECIMAL_LITERAL : ('0' | '1'..'9' '0'..'9'*) IntegerTypeSuffix? ;

OCTAL_LITERAL : '0' [0-7]+ IntegerTypeSuffix? ;

FLOATING_POINT_LITERAL 	:	INT ('.' DIGIT*)? Exponent? FloatTypeSuffix? ;

FLOATING_WITHOUT_PREFIX	:	'.' DIGIT* ;

fragment LETTER 	: [$A-Za-z_] ;

fragment DIGIT	:	[0-9] ;

fragment HexDigit : [0-9a-fA-F] ;

fragment IntegerTypeSuffix 	:	[uUlL] ;

fragment Exponent : [eE] ('+'|'-')? INT ;

fragment FloatTypeSuffix : [fFdD] ;

fragment EscapeSequence	:	'\\' [btnfr\"\'\\] | OctalEscape ;

fragment OctalEscape	:	'\\' [0-3][0-7][0-7] | '\\' [0-7][0-7] | '\\' [0-7] ;

fragment UnicodeEscape 	:   '\\' 'u' HexDigit HexDigit HexDigit HexDigit ;

WS : [ \r\n\t\u000C]+ -> channel(HIDDEN);

COMMENT :	'/*' .*? '*/' -> channel(HIDDEN);

LINE_COMMENT	:	'//' .*? '\r'? '\n' -> channel(HIDDEN) ;

LINE_SLASH	:	'\\' -> channel(HIDDEN);