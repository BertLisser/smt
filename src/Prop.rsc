module Prop
import Prelude;
import IO;
import smt::Propositions;
import smt::SatProp;
import smt::Kripke;
import lang::dot::Dot;
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

Formula rch = R;

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
        return "Q:<n[0]> <n[1]>";
        }
        
set[list[str]] doma(list[str] a, list[str] b) {
   return {[v[0], v[1]]|tuple[str, str] v<- a* b};
   }

public void main() {
     addSignature("P1", "l1", "CR1", "NC1");
     addSignature("P2", "l2", "CR2", "NC2");
     addVariables("P1", "pc1", "pc.1");
     addVariables("P2", "pc2", "pc.2");
     buildTheory(rch);
     // addBoundedVariables(["aap", "noot","mies"], ["z", "z1"]);
     r = nextStates(["pc1","pc2"],["pc.1", "pc.2"], [["l1", "l2"]]);
     println("TEST:<r>");
     Kripke[list[str]] M = <doma(["l1", "CR1", "NC1"],["l2", "CR2", "NC2"]), {["l1","l2"]}, r, pred, labcf>;
     dotDisplay(toDot(M)); 
}