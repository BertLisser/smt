module lpico::ControlFlow

import Prelude;
import  analysis::graphs::Graph;
import lpico::Abstract;
import demo::lang::Pico::Load;

public data CFNode                                                                /*1*/
	= entry(loc location)
	| exit()
	| choice(loc location, EXP exp)
	| statement(loc location, LSTATEMENT stat);

alias CFGraph = tuple[set[CFNode] entry, Graph[CFNode] graph, set[CFNode] exit];  /*2*/

CFGraph cflowStat(s:lstatement(PicoId id, asgStat(PicoId Id, EXP Exp))) {  
   if (lstatement(_, STATEMENT v):=s) {                              /*3*/
   S = statement(v@location, s);
   return <{S}, {}, {S}>;
   }
}

CFGraph cflowStat(lstatement(PicoId id, ifElseStat(EXP Exp,                                             /*4*/
                              list[LSTATEMENT] Stats1,
                              list[LSTATEMENT] Stats2))){
   CF1 = cflowStats(Stats1); 
   CF2 = cflowStats(Stats2); 
   E = {choice(Exp@location, Exp)}; 
   return < E, (E * CF1.entry) + (E * CF2.entry) + CF1.graph + CF2.graph, CF1.exit + CF2.exit >;
}

CFGraph cflowStat(lstatement(PicoId id, whileStat(EXP Exp, list[LSTATEMENT] Stats))) { 
   E = {choice(Exp@location, Exp)}; 
   CFNode e =  getOneFrom(E);
   if (size(Stats)==0) return <E,{<e,e>}, E>;
   CF = cflowStats(Stats); 
   return < E, (E * CF.entry) + CF.graph + (CF.exit * E), E >;
}

CFGraph cflowStats(list[LSTATEMENT] Stats){                                        /*6*/
  if(size(Stats) == 1)
     return cflowStat(Stats[0]);
  CF1 = cflowStat(Stats[0]);
  CF2 = cflowStats(tail(Stats));
  return < CF1.entry, CF1.graph + CF2.graph + (CF1.exit * CF2.entry), CF2.exit >;
}

public CFGraph cflowProgram(PROGRAM P){                                           /*7*/
  if(program(list[DECL] Decls, list[LSTATEMENT] Series) := P){
     CF = cflowStats(Series);
     Entry = entry(P@location);
     Exit  = exit();
     return <{Entry}, ({Entry} * CF.entry) + CF.graph + (CF.exit * {Exit}), {Exit}>;
  } else
    throw "Cannot happen";
}

public CFGraph cflowProgram(str txt) = cflowProgram(load(txt));                   /*8*/


