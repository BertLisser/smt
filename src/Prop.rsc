module Prop
import Prelude;
import IO;
import smt::Propositions;
import smt::SatProp;

// Formula f = \if(\not(v("y")), \not(v("x")));

Formula f = eq("q", "noot");

/*
Formula f = \and(
 \if(v("x"), v("y"))
, \if(\not(v("y")), \not(v("x")))
 //  ,\false()
);
*/


public void main() {
     addVariables(["q"]);
     addConstants(["aap", "noot"]);
     println("TEST:<findModel(["x", "y"], f, 10)>");
     //  println("TEST:<findModel(["x", "y"], \or(v("x"), v("y")), 10)>");
}