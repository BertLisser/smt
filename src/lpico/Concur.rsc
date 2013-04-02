module lpico::Concur
import Prelude;
import smt::Kripke;
import lang::dot::Dot;
import dotplugin::Display;
import lpico::Abstract;
import lpico::ControlEq;
import lpico::ControlFlow;
import lpico::Syntax;
import  analysis::graphs::Graph;


int idcf(CFNode nod1, CFNode nod2, map[tuple[str, str], int] code, map[str, int]  var) {
   int d = 0;
   for (str k<-var) d= 10*d+var[k];
   return code[<getLabel(nod1), getLabel(nod2)>]+d;
   }
   
str labdecl(DECL d) {
   if (decl(TYPE tp, PicoId name, natCon(int v)):=d) {
        return "<name>=<v>";
        }
   else return ".";
}
 
 
str labdecl1(DECL d) {
   if (decl(TYPE tp, PicoId name, natCon(int v)):=d) {
        return name;
        }
   else return ".";
}

int labdecl2(DECL d) {
   if (decl(TYPE tp, PicoId name, natCon(int v)):=d) {
        return v;
        }
   else return -1;
}


str labcf(CFNode nod, str input) {
   switch (nod) {
      case entry(loc x, list[DECL] decls): return "entry:<for (d<-decls) {> <labdecl(d)> <}>";
      case exit():  return "exit";
      case choice(loc x,PicoId id,  EXP exp): return id;
      /*"<id>:<substring(input, x.offset, x.offset+x.length)>";*/
      case statement(loc x, LSTATEMENT  lstat):  return "<substring(input, x.offset, x.offset+x.length)>";
   }
   return "";  
   }
     
bool pred(int n) {
   return true;
   }
   
str getLabel(CFNode nod) {
   switch (nod) {
      case entry(loc x, list[DECL] decls): return "entry";
      case exit():  return "exit";
      case choice(loc x,PicoId id,  EXP exp): return id;
      /*"<id>:<substring(input, x.offset, x.offset+x.length)>";*/
      case statement(loc x, LSTATEMENT  lstat):  return lstat.name;
   }
   return "";   
   }
   
map[tuple[str, str], int] getCode(list[tuple[str, str]] c) {
   return (k:indexOf(c, k)|k<-c);
   /*
   int i  = 0;
   map[tuple[str, str], int] r = ();
   for (k<-c) {
      r+=(k:i); 
      i = i+1;    
   }
   // Fout in Rascal return (k:indexOf(c, k)|k<-c);
   return r;
   */
   }
   
public void visualize(Programs x , loc f) {
   str input = unparse(x);
   // println(x);
   PROGRAMS m = implode(#PROGRAMS, x);
   if (programs(list[PROGRAM] q):=m) {
     println(q);
     CFGraph CFG0 = cflowProgram(q[0]);
     CFGraph CFG1 = cflowProgram(q[1]);
     list[tuple[str, str]] labl = [getLabel(k)|CFNode k<-carrier(CFG0.graph)]
         *[getLabel(k)|CFNode k<-carrier(CFG1.graph)];
     map[tuple[str, str], int] code = getCode(labl);
     map[str, int] var  = (labdecl1(d):labdecl2(d)|entry(_,list[DECL] decls)<-carrier(CFG0.graph), d<-decls);
     map[int, str] nodes = (idcf(k, l, code, var):labcf(k, input)|CFNode k<-carrier(CFG0.graph), CFNode l<-carrier(CFG1.graph));
     set[int] entries = {idcf(k, h, code, var)|CFNode k<-carrier(CFG0.graph), entry(_,_):=k, CFNode h<-carrier(CFG1.graph), entry(_,_):=h}
          ;
     rel[int, int] r = {<idcf(g.from, h.from, code, var), idcf(g.to, h.from, code, var)>|g<-CFG0.graph, h<-CFG1.graph};
     str labcf(int n) = "<for(v<-var){> <v>=<var[v]><}> <head(drop(n, labl))> <nodes[n]>";
     Kripke[int] M = <domain(nodes), entries, r, pred, labcf>;
     // println(toDot(M));
     dotDisplay(toDot(M)); 
     }
   }
   
public void main() {
   Programs p = parse(#Programs,|project://smt/src/lpico/test.lpic|);
   println(p);
   // visualize(p, |file:///|);
}


