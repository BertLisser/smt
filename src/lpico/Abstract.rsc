module lpico::Abstract

public data TYPE = natural() | string();    /*1*/
	  
public alias PicoId = str;                  /*2*/
	  
public data PROGRAM =                       /*3*/
  program(list[DECL] decls, list[LSTATEMENT] lstats);

public data DECL =
  decl(TYPE tp, PicoId name, EXP exp);

public data EXP = 
       id(PicoId name)
     | natCon(int iVal)
     | strCon(str sVal)
     | add(EXP left, EXP right)
     | sub(EXP left, EXP right)
     | conc(EXP left, EXP right)
     ;
     
public data LSTATEMENT =
     lstatement(PicoId name, STATEMENT statement)
     ;
    
public data STATEMENT =
       asgStat(PicoId name, EXP exp)
     | ifElseStat(EXP exp, list[LSTATEMENT] thenPart, list[LSTATEMENT] elsePart)
     | whileStat(EXP exp, list[LSTATEMENT] lstats)
     ;

anno loc TYPE@location;                   /*4*/
anno loc PROGRAM@location;
anno loc DECL@location;
anno loc EXP@location;
anno loc STATEMENT@location;

public alias Occurrence = tuple[loc location, PicoId name, LSTATEMENT stat];  /*5*/
