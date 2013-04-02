module Prop
import Prelude;
import IO;
import smt::Propositions;
import smt::SatProp;
import smt::Kripke;
import lang::dot::Dot;
import lpico::Abstract;
import lpico::Syntax;
import lpico::ControlEq;
import dotplugin::Display;

// Formula f = \if(\not(v("y")), \not(v("x")));

Formula f = equ("q", "noot");
Formula g = equ("r", "aap");

Formula R =  or( 
      {and({equ("pc1","l1"), equ("pc.1","NC1"), equ("pc2", "pc.2")})
      ,and({equ("pc2","l2"), equ("pc.2","NC2"), equ("pc1", "pc.1")})
      ,and({equ("pc1","NC1"), equ("pc.1","CR1"), equ("pc2", "pc.2")})
      }
      )
      ;

// Formula rch = R;

/*
Formula f = \and(
 \if(v("x"), v("y"))
, \if(\not(v("y")), \not(v("x")))
 //  ,\false()
);
*/

rel[list[str], list[str]] nextState(list[str] f, list[str] t, list[str] v) {
   lrel[str, str] r = zip(f, v);
   map[str, str] q = (g[0]:g[1]|tuple[str,str] g<-r);
   list[map[str, str]] m = findModel(q, 10);
   return {<v, [k[g]|str g<-t]>|map[str, str] k<-m};
}

rel[list[str], list[str]] nextStates(list[str] f, list[str] t, list[list[str]] v) {
  rel[list[str], list[str]] r = {};
  for (list[str] w<-v)
     r+= nextState(f, t, w);
  return r;
}

bool pred(list[str] n) {
   return true;
   }

str labcf(list[str] n) {
        return "<n[0]> <n[1]> <n[2]>";
        }
        
set[list[str]] doma(list[str] a, list[str] b) {
   return {[v[0], v[1]]|tuple[str, str] v<- a* b};
   }
   
 set[list[str]] doma(list[str] a, list[str] b, list[str] c) {
   list[tuple[tuple[str, str], str]] g =  a* b *c;
   return {[k[0][0], k[0][1], k[1]]|tuple[tuple[str, str], str] k  <- g};
   }

public void main() {
     addSignature("P0", "L0", "CR0", "NC0", "L0.");
     addSignature("P1", "L1", "CR1", "NC1", "L1.");
     addSignature("D",  "V0", "V1");
     addVariables("P0", "pc0", "pc0.");
     addVariables("P1", "pc1", "pc1.");
     addVariables("D", "turn", "turn.");
     Programs p = parse(#Programs,|project://smt/src/lpico/test.lpic|);
     // println(p);
     PROGRAMS m = implode(#PROGRAMS, p);
     Formula rch = cflowPrograms(m);
     buildTheory(rch);
     // addBoundedVariables(["aap", "noot","mies"], ["z", "z1"]);
     r = nextStates(["pc0","pc1","turn"],["pc0.", "pc1.", "turn."], [["L0", "L1","V0"],["L0", "L1","V1"]]);
     println("TEST:<r>");
     set[list[str]] d = doma(["L0", "CR0", "NC0","L0."],["L1", "CR1", "NC1", "L1."], ["V0", "V1"]);
     Kripke[list[str]] M = <carrier(r),  {}, r, pred, labcf>;
     DotGraph z = toDot(M);
     println(z);
     dotDisplay(z); 
}