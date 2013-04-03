module lpico::Abstract

public data TYPE = natural() | string();    /*1*/
	                /*2*/

public data PROGRAMS = 
  programs(list[PROGRAM] prgs);

	  
public data PROGRAM =                       /*3*/
  program(list[LSTATEMENT] lstats, str label);
  
/*
public data ATOM =
    id(PicoId pid) 
    |string(str s)
    |natural(str d)
    ;
*/

alias PicoId = str;


public data EXP 
     = T()
     | F()
     | equal(str lhs, str rhs)
     ;
     
public data LSTATEMENT =
     lstatement(str name, STATEMENT statement)
     ;
    
public data STATEMENT =
       asgStat(PicoId name, PicoId atom)
     | ifElseStat(EXP exp, list[LSTATEMENT] thenPart, list[LSTATEMENT] elsePart)
     | whileStat(EXP exp, list[LSTATEMENT] lstats)
     | waitStat(EXP exp)
     ;

anno loc TYPE@location;                   /*4*/
anno loc PROGRAM@location;
anno loc PROGRAMS@location;
anno loc EXP@location;
anno loc STATEMENT@location;

public alias Occurrence = tuple[loc location, str name, LSTATEMENT stat];  /*5*/
