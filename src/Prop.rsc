module Prop
import Prelude;
import IO;
import smt::Propositions;
import smt::SatProp;

// Formula f = \if(\not(v("y")), \not(v("x")));

Formula f = equ("q", "noot");
Formula g = equ("r", "aap");

Formula R =  or( 
      {and({equ("pc1","l1"), equ("pc.1","NC1"), equ("pc2", "pc.2")})
      ,and({equ("pc2","l2"), equ("pc.2","NC2"), equ("pc1", "pc.1")})
      }
      )
      ;

Formula rch = and(equ("pc1","l1"), R);

/*
Formula f = \and(
 \if(v("x"), v("y"))
, \if(\not(v("y")), \not(v("x")))
 //  ,\false()
);
*/


public void main() {
     addSignature("P1", "l1", "CR1", "NC1");
     addSignature("P2", "l2", "CR2", "NC2");
     addVariables("P1", "pc1", "pc.1");
     addVariables("P2", "pc2", "pc.2");
     // addBoundedVariables(["aap", "noot","mies"], ["z", "z1"]);
     list[map[str, str]] r = findModel([], ("pc1":"l1", "pc2":"l2"), rch, 10);
     println("TEST:<r>");
    /* , and(
     or(eq("q", "aap"), eq("q","noot")),
     or(eq("r", "aap"), eq("r","noot"))
     ) */
     //  println("TEST:<findModel(["x", "y"], \or(v("x"), v("y")), 10)>");
}