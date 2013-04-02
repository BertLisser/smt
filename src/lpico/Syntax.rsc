module lpico::Syntax

import Prelude;

lexical Id  = [A-Za-z.] [A-Za-z0-9.]* !>> [A-Za-z0-9.];
// lexical Id  = [a-z][a-z0-9]* !>> [a-z0-9];
// lexical Natural = [0-9]+ ;
// lexical String = "\"" ![\"]*  "\"";

/*
syntax Atom = id: Id
            | natural: Natural
            | string: String
            ;
*/

layout Layout = WhitespaceAndComment* !>> [\ \t\n\r%];

lexical WhitespaceAndComment 
   = [\ \t\n\r]
   | @category="Comment" "%" ![%]+ "%"
   | @category="Comment" "%%" ![\n]* $
   ;
   
start syntax Programs = programs: "cobegin" {Program ";"}* prgs "coend" ;

syntax Program 
   = program: "begin"  {LabeledStatement  ";"}* body "end" Id label;

/*
syntax Type 
   = natural:"natural" 
   | string :"string" 
   ;
*/
   
syntax LabeledStatement 
    = lstatement: Id label ":" Statement statement
   ;

syntax Statement 
   = asgStat: Id var ":="  Id vl 
   | ifElseStat: "if" Expression cond "then" {LabeledStatement ";"}*  thenPart "else" {LabeledStatement ";"}* elsePart "fi"
   | whileStat: "while" Expression cond "do" {LabeledStatement ";"}* body "od"
   | waitStat:  "wait" Expression cond
   ;  
   
     
syntax Expression 
   = equal: Id lhs "=" Id rhs
   | T: "T"
   | F: "F"
   ;

public start[Program] program(str s) {
  return parse(#start[Program], s);
}

public start[Program] program(str s, loc l) {
  return parse(#start[Program], s, l);
} 
