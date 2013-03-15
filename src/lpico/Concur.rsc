module lpico::Concur
import Prelude;
import smt::Kripke;
import lang::dot::Dot;
import dotplugin::Display;
import lpico::Abstract;
import lpico::ControlFlow;
import lpico::Syntax;
import  analysis::graphs::Graph;

int idcf(CFNode nod) {
   switch (nod) {
      case entry(loc x, _): return x.offset;
      case exit():  return -1;
      case choice(loc x, _, _): return x.offset;
      case statement(loc x, _):  return x.offset;
   }
   
   return -2;   
   }
   
str labdecl(DECL d) {
   if (decl(TYPE tp, PicoId name, natCon(int v)):=d) {
        return "<name>=<v>";
        }
   else return ".";
}

str labcf(CFNode nod, str input) {
   switch (nod) {
      case entry(loc x, list[DECL] decls): return "entry:<for (d<-decls) {> <labdecl(d)> <}>";
      case exit():  return "exit";
      case choice(loc x,PicoId id,  EXP exp): return id;
      /*"<id>:<substring(input, x.offset, x.offset+x.length)>";*/
      case statement(loc x, LSTATEMENT  lstat):  return "<lstat.name>:<substring(input, x.offset, x.offset+x.length)>";
   }
   return "";   
   }
     
bool pred(int n) {
   return true;
   }
   
public void visualize(Program x , loc f) {
   PROGRAM m = implode(#PROGRAM, x);
   str input = unparse(x);
   CFGraph CFG = cflowProgram(m);
   map[int, str] nodes =(idcf(k):labcf(k, input)|CFNode k<-carrier(CFG.graph));
   nodes = (idcf(k):labcf(k, input)|CFNode k<-carrier(CFG.graph));
   set[int] entries = {idcf(k)|CFNode k<-carrier(CFG.graph), entry(_):=k};
   rel[int, int] r = {<idcf(g.from), idcf(g.to)>|g<-CFG.graph};
   str labcf(int n) = nodes[n];
   Kripke[int] M = <domain(nodes), entries, 
                 r, pred, labcf>;
   // println(toDot(M));
   dotDisplay(toDot(M)); 
   }
   
public void main() {
   Program p = parse(#Program,|project://smt/src/lpico/test.lpic|);
   visualize(p, |file:///|);
}


