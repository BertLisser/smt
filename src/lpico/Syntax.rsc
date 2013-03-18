module lpico::Syntax

import Prelude;

lexical Id  = [A-Za-z][A-Za-z0-9]* !>> [A-Za-z0-9];
lexical Natural = [0-9]+ ;
lexical String = "\"" ![\"]*  "\"";

layout Layout = WhitespaceAndComment* !>> [\ \t\n\r%];

lexical WhitespaceAndComment 
   = [\ \t\n\r]
   | @category="Comment" "%" ![%]+ "%"
   | @category="Comment" "%%" ![\n]* $
   ;
   
start syntax Programs = programs: "cobegin" {Program ";"}* prgs "coend" ;

syntax Program 
   = program: "begin" Declarations decls {LabeledStatement  ";"}* body "end" ;

syntax Declarations 
   = "declare" {Declaration ","}* decls ";" ;  
 
syntax Declaration = decl: Type tp Id id ":=" Expression ;

syntax Type 
   = natural:"natural" 
   | string :"string" 
   ;
   
syntax LabeledStatement 
    = lstatement: Id label ":" Statement statement
   ;

syntax Statement 
   = asgStat: Id var ":="  Expression val 
   | ifElseStat: "if" Expression cond "then" {LabeledStatement ";"}*  thenPart "else" {LabeledStatement ";"}* elsePart "fi"
   | whileStat: "while" Expression cond "do" {LabeledStatement ";"}* body "od"
   | waitStat:  "wait" Expression cond
   ;  
   
     
syntax Expression 
   = id: Id name
   | strCon: String string
   | natCon: Natural natcon
   | bracket "(" Expression e ")"
   > left eq: Expression lhs "=" Expression rhs
   > left ( add: Expression lhs "+" Expression rhs
          | sub: Expression lhs "-" Expression rhs
          )
  ;

public start[Program] program(str s) {
  return parse(#start[Program], s);
}

public start[Program] program(str s, loc l) {
  return parse(#start[Program], s, l);
} 
