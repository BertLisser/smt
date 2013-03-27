module lpico::ControlEq

import Prelude;
import  analysis::graphs::Graph;
import lpico::Abstract;
import demo::lang::Pico::Load;
import smt::Propositions;


set[str] variables = {"pc0", "pc1", "turn"};

set[str] pcs = {"pc0", "pc1"};

Formula same(set[str] vs) {
   set[Formula] r = {equ("<v>", "<v>.")|v<-vs};
   return and(r);
   }

Formula cflowStat(str pc, s:lstatement(PicoId id, asgStat(PicoId Id, EXP Exp)), str label) {                              /*3*/
   return and({equ("<pc>",l1), equ("<pc>.", label), equ("<Id>.", "<Exp>"), same(variables-{"<pc>", "<Id>"})});
}

Formaula cflowStat(lstatement(str pc, PicoId id, ifElseStat(EXP Exp,                                             /*4*/
                              list[LSTATEMENT] Stats1,
                              list[LSTATEMENT] Stats2)), str label){
                               Formula c = \true();
   Formula c = \true();
   Formula r = \false();
   if (equal(str l, str r):=Exp) {
      c = equ(l, r);  
   }
   if (lstatement(PicoId id1, _):=head(Stats1) && size(Stats2)==0) {
    r = or(\and({c, equ("<pc>", "<id>"),equ("<pc>.", "<id1>")}),
           \and({not(c), equ("<pc>", "<id>"),equ("<pc>.", "<label>")}));  
   } 
   else 
   if (lstatement(PicoId id1, _):=head(Stats1) && lstatement(PicoId id2, _):=head(Stats1))  {  
          r = or(\and({c, equ("<pc>", "<id>"),equ("<pc>.", "<id1>")}),
                  \and({not(c), equ("<pc>", "<id>"),equ("<pc>.", "<id2>")}));   
   }  
   return or({r, cflowStats(pc, Stats1, label), cflowStats(pc, Stats2, label)});                       
}

Formula cflowStat(str pc, lstatement(PicoId id, whileStat(EXP Exp, list[LSTATEMENT] Stats)), str label) { 
   Formula c = \true();
   if (equal(str l, str r):=Exp) {
      c = equ(l, r);  
   }
   Formula r;
   if (size(Stats)==0)
      r = or(\and({c, equ("<pc>", "<id>"),equ("<pc>.", "<id>")}),
             \and({not(c), equ("<pc>", "<id>"),equ("<pc>.", "<label>")})); 
   else {
      if (lstatement(PicoId id1, _):=head(Stats)) {
          r = or(\and({c, equ("<pc>", "<id>"),equ("<pc>.", "<id1>")}),
             \and({not(c), equ("<pc>", "<id>"),equ("<pc>.", "<label>")})); 
          }
      }
   return or(r, cflowStats(pc, Stats, label));      
}

Formula cflowStat(str pc, lstatement(PicoId id, waitStat(EXP Exp)), str label) { 
   r = or(\and({not(c), equ("<pc>", "<id>"),equ("<pc>.", "<id>"), same(variables-{"<pc>"})}),
          \and({c, equ("<pc>", "<id>"),equ("<pc>.", "<label>"),same(variables-{"<pc>"})}));
   return r;        
}

Formula cflowStats(str pc, list[LSTATEMENT] Stats, str label){  
  if (size(Stats)==0) return \false();                                      /*6*/
  if(size(Stats) == 1)
     return cflowStat(Stats[0], label);
  Formula CF1 = cflowStat(pc, Stats[0], head(tail(Stats)).name);
  Formula CF2 = cflowStats(pc, tail(Stats), label);
  Formula r = or(CF1, CF2);
  return  r;
}

public CFGraph cflowProgram(str pc, PROGRAM P){                                           /*7*/
  if(program(list[LSTATEMENT] Series, str label) := P){
     Formula CF = and(cflowStats(pc, Series, label), same(pcs-{pc}));
     return CF;
  } 
}

 
public Formula cflowPrograms(PROGRAMS P){
    if (programs(list[PROGRAM] q):=P) {
        set[Formula] r = {};
        int i = 0;
        for (PROGRAM p <- q) {
          r+=cflowProgram("pc<i>", p);
          i+=1;
        }
      }
    return or(r);
    }   
                 /*8*/


