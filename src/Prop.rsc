module Prop
import Prelude;
import IO;
import smt::Propositions;
import smt::SatProp;
import smt::Kripke;
import lang::dot::Dot;
import lpico::Abstract;
// import A;
import lpico::Syntax;
import lpico::ControlEq;
import dotplugin::Display;
import vis::Figure;
import vis::Render;

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

rel[list[str], list[str]] nextStates(list[str] f, list[str] t, set[list[str]] v) {
  rel[list[str], list[str]] r = {};
  for (list[str] w<-v)
     r+= nextState(f, t, w);
  return r;
}

int pred(list[str] n) {
   return toInt(n[2]);
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
   
set[list[str]] newStates(map[list[str], int] visited, rel[list[str], list[str]] r) {
   set[list[str]] nxt = range(r);
   set[list[str]] nw = {x|list[str] x <- nxt, x notin visited};
   return nw;
   }
   
rel[list[str], list[str]] generate() {
   set[list[str]] q = {["L0", "L1","0"], ["L0", "L1","1"]};
   rel[list[str], list[str]] r = {};
   map[list[str], int] visited = ();
   while (!isEmpty(q)) {
         rel[list[str], list[str]] t =  nextStates(["pc0","pc1","turn"],["pc0.", "pc1.", "turn."], q);
         r+=t;
         q = newStates(visited, t);
         for (list[str] s <- q) {
             visited[s]= size(visited);
             }
     }
   return r;
   }

public void main() {
     addSignature("P0", "L0", "CR0", "NC0", "L0.");
     addSignature("P1", "L1", "CR1", "NC1", "L1.");
     addSignature("D",  "0", "1");
     addVariables("P0", "pc0", "pc0.");
     addVariables("P1", "pc1", "pc1.");
     addVariables("D", "turn", "turn.");
     Programs p = parse(#Programs,|project://smt/src/lpico/test.lpic|);
     PROGRAMS m = implode(#PROGRAMS, p);
     Formula rch = cflowPrograms(m);
     buildTheory(rch);
     rel[list[str], list[str]] r = generate();
     println("TEST:<r>");
     // set[list[str]] d = doma(["L0", "CR0", "NC0","L0."],["L1", "CR1", "NC1", "L1."], ["0", "1"]);
     Kripke[list[str]] M = <carrier(r),  {}, r, pred, labcf>;
     // DotGraph z = toDot(M);
     DotGraph z = toDot(M, pred);
     dotDisplay(z); 
     // Figure f = toFig(M);
     // render(f);
}