module lpico::ControlFlow

import Prelude;
import  analysis::graphs::Graph;
import lpico::Abstract;
import demo::lang::Pico::Load;

public data CFNode                                                                /*1*/
	= entry(loc location, list[DECL] decls)
	| exit()
	| choice(loc location, PicoId id, EXP exp)
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
   E = {choice(Exp@location, id, Exp)}; 
   return < E, (E * CF1.entry) + (E * CF2.entry) + CF1.graph + CF2.graph, CF1.exit + CF2.exit >;
}

CFGraph cflowStat(lstatement(PicoId id, whileStat(EXP Exp, list[LSTATEMENT] Stats))) { 
   E = {choice(Exp@location, id, Exp)}; 
   CFNode e =  getOneFrom(E);
   if (size(Stats)==0) return <E,{<e,e>}, E>;
   CF = cflowStats(Stats);
   // println(E);
   // println(CF.entry);
   CFGraph r =  < E, (E * CF.entry) + CF.graph + (CF.exit * E), E >;
   // for (x<-r.graph) println(x);
   return r;
}

CFGraph cflowStat(lstatement(PicoId id, waitStat(EXP Exp))) { 
   E = {choice(Exp@location, id, Exp)}; 
   CFNode e =  getOneFrom(E);
   return <E,{<e,e>}, E>;
}

CFGraph cflowStats(list[LSTATEMENT] Stats){                                        /*6*/
  if(size(Stats) == 1)
     return cflowStat(Stats[0]);
  CF1 = cflowStat(Stats[0]);
  CF2 = cflowStats(tail(Stats));
  CFGraph r =  < CF1.entry, CF1.graph + CF2.graph + (CF1.exit * CF2.entry), CF2.exit >;
  return  r;
}

public CFGraph cflowProgram(PROGRAM P){                                           /*7*/
  if(program(list[DECL] Decls, list[LSTATEMENT] Series) := P){
     CF = cflowStats(Series);
     Entry = entry(P@location, Decls);
     Exit  = exit();
     return <{Entry}, ({Entry} * CF.entry) + CF.graph /*+ (CF.exit * {Exit}) */, {Exit}>;
  } else
    throw "Cannot happen";
}

CFGraph jon(list[CFGraph] CF) {
    r = {};
    Graph[CFNode] q = {};
    for (g<-CF) {
        r+=g.entry;
        q+=g.graph;
        }
    return <r, q, {}>;
    }
 
 public CFGraph cflowPrograms(PROGRAMS P){
    if (programs(list[PROGRAM] q):=P) 
        // return jon([cflowProgram(p)|p<-q]);
        return cflowProgram(q[0]);
    return <{}, [], {}>;
    }   


public CFGraph cflowProgram(str txt) = cflowProgram(load(txt));                   /*8*/


