module Prop
import Prelude;
import IO;
import lang::logic::ast::Propositions;
import lang::logic::ast::Booleans;
import lang::dimacs::IO;

Formula f = \and(
  \if(v("x"), v("y"))
, \if(\not(v("y")), \not(v("x")))
//  ,\true()
);
public void main() {
     println("TEST:<findModel(["x", "y"], f, 10)>");
     //  println("TEST:<findModel(["x", "y"], \or(v("x"), v("y")), 10)>");
}