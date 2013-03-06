module Concur
import Prelude;
import smt::Kripke;
import lang::dot::Dot;
import dotplugin::Display;
import demo::lang::Pico::Abstract;
import demo::lang::Pico::ControlFlow;
import demo::lang::Pico::Syntax;
import  analysis::graphs::Graph;

str input = readFile(|project://smt/src/concur.pico|);

map[CFNode, str] loc2lab = ();

int idcf(CFNode n) {
   switch (n) {
      case entry(loc x): return x.offset;
      case exit():  return -1;
      case choice(loc x, EXP exp): return x.offset;
      case statement(loc x, STATEMENT  stat):  return x.offset;
   }
   return -2;   
   }

str labcf(CFNode n) {
   switch (n) {
      case entry(loc x): return "entry";
      case exit():  return "exit";
      case choice(loc x, EXP exp): return substring(input, x.offset, x.offset+x.length);
      case statement(loc x, STATEMENT  stat):  return substring(input, x.offset, x.offset+x.length);
   }
   return "";   
   }
   
str labcf(int n) {
   return labcf(nodes[n]);
   }
   
bool pred(int n) {
   return true;
   }
   
map[int, CFNode] nodes =();

public void main() {
   // println(input);
   Program p = parse(#Program, input);
   PROGRAM m = implode(#PROGRAM, p);
   CFGraph CFG = cflowProgram(m);
   nodes = (idcf(k):k|CFNode k<-carrier(CFG.graph));
   set[int] entries = {idcf(k)|CFNode k<-carrier(CFG.graph), entry(_):=k};
   rel[int, int] r = {<idcf(g.from), idcf(g.to)>|g<-CFG.graph};
   Kripke[int] M = <domain(nodes), entries, 
                 r, pred, labcf>;
   println(toDot(M));
   dotDisplay(toDot(M)); 
}


