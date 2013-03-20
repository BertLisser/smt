module Prop
import Prelude;
import IO;
import smt::Propositions;
import smt::SatProp;

// Formula f = \if(\not(v("y")), \not(v("x")));

Formula f = eq("q", "noot");
Formula g = eq("r", "aap");

Formula R =  or( 
      {and(eq("z","aap"), eq("z1","noot"))
      ,and(eq("z","noot"), eq("z1","mies"))
      }
      );

Formula rch = and(eq("z","aap"), R);

/*
Formula f = \and(
 \if(v("x"), v("y"))
, \if(\not(v("y")), \not(v("x")))
 //  ,\false()
);
*/


public void main() {
     addBoundedVariables(["aap", "noot","mies"], ["z", "z1"]);
     println("TEST:<findModel([], rch, 10)>");
    /* , and(
     or(eq("q", "aap"), eq("q","noot")),
     or(eq("r", "aap"), eq("r","noot"))
     ) */
     //  println("TEST:<findModel(["x", "y"], \or(v("x"), v("y")), 10)>");
}