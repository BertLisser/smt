module lpico::ControlEq

import Prelude;
import  analysis::graphs::Graph;
import lpico::Abstract;
// import demo::lang::Pico::Load;
import smt::Propositions;


set[str] variables = {"pc0", "pc1", "turn"};

set[str] pcs = {"pc0", "pc1"};

Formula same(set[str] vs) {
   set[Formula] r = {equ("<v>", "<v>.")|v<-vs};
   return and(r);
   }

Formula cflowStat(str pc, s:lstatement(str id, asgStat(str Id, str Exp)), str label) {                              /*3*/
   Formula r = and({equ("<pc>",id), equ("<pc>.", label), equ("<Id>.", "<Exp>"), same(variables-{"<pc>","<Id>"})});
   println(r);
   return r;
}

Formula cflowStat(str pc, lstatement(str id, ifElseStat(EXP Exp,                                             /*4*/
                              list[LSTATEMENT] Stats1,
                              list[LSTATEMENT] Stats2)), str label){
                               Formula c = \true();
   Formula c = \true();
   Formula r = \false();
   if (equal(str l, str d):=Exp) {
      c = equ(l, d);  
   }
   if (lstatement(str id1, _):=head(Stats1) && size(Stats2)==0) {
    r = or(\and({c, equ("<pc>", "<id>"),equ("<pc>.", "<id1>")}),
           \and({not(c), equ("<pc>", "<id>"),equ("<pc>.", "<label>")}));  
   } 
   else 
   if (lstatement(str id1, _):=head(Stats1) && lstatement(str id2, _):=head(Stats1))  {  
          r = or(\and({c, equ("<pc>", "<id>"),equ("<pc>.", "<id1>")}),
                  \and({not(c), equ("<pc>", "<id>"),equ("<pc>.", "<id2>")}));   
   }  
   return or({r, cflowStats(pc, Stats1, label), cflowStats(pc, Stats2, label)});                       
}

Formula cflowStat(str pc, lstatement(str id, whileStat(EXP Exp, list[LSTATEMENT] Stats)), str label) { 
   Formula c = \true();
   if (equal(str l, str r):=Exp) {
      println("whileStat:<Exp>");
      c = equ(l, r);  
   }
   Formula r;
   if (size(Stats)==0)
      r = or(\and({c, equ("<pc>", "<id>"),equ("<pc>.", "<id>"), same(variables-{"<pc>"})}),
             \and({not(c), equ("<pc>", "<id>"),equ("<pc>.", "<label>"), same(variables-{"<pc>"})})); 
   else {
      if (lstatement(str id1, _):=head(Stats)) {
          r = or(\and({c, equ("<pc>", "<id>"),equ("<pc>.", "<id1>"), same(variables-{"<pc>"})}),
             \and({not(c), equ("<pc>", "<id>"),equ("<pc>.", "<label>"), same(variables-{"<pc>"})})); 
          }
      }
   return or(r, cflowStats(pc, Stats, id));      
}

Formula cflowStat(str pc, lstatement(str id, waitStat(EXP Exp)), str label) { 
   Formula c = \true();
   if (equal(str l, str r):=Exp) {
      c = equ(l, r);  
   }
   r = or(\and({not(c), equ("<pc>", "<id>"),equ("<pc>.", "<id>"), same(variables-{"<pc>"})}),
          \and({c, equ("<pc>", "<id>"),equ("<pc>.", "<label>"),same(variables-{"<pc>"})}));
   return r;        
}

Formula cflowStats(str pc, list[LSTATEMENT] Stats, str label){  
  if (size(Stats)==0) return \false();                                      /*6*/
  if(size(Stats) == 1) {
     return cflowStat(pc, Stats[0], label);
     }
  Formula CF1 = cflowStat(pc, Stats[0], head(tail(Stats)).name);
  Formula CF2 = cflowStats(pc, tail(Stats), label);
  Formula r = or(CF1, CF2);
  return  r;
}

public Formula cflowProgram(str pc, PROGRAM P){                                           /*7*/
  if(program(list[LSTATEMENT] Series, str label) := P){
     Formula CF = and(cflowStats(pc, Series, label), same(pcs-{pc}));
     return CF;
  } 
}

 
public Formula cflowPrograms(PROGRAMS P){
    set[Formula] r = {};
    if (programs(list[PROGRAM] q):=P) {
        int i = 0;
        for (PROGRAM p <- q) {
          r+=cflowProgram("pc<i>", p);
          i+=1;
        }
      }
    return or(r);
    }   
                 /*8*/


