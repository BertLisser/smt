module smt::Kripke
import IO;
import Set;
import lang::dot::Dot;
import dotplugin::Display;
import vis::Figure;



alias Kripke[&T]=tuple[set[&T] s, set[&T] s0, rel[&T, &T] r ,int(&T) l, str(&T) id];

set[S] s = {<0,0>,<0,1>, <1,0>, <1,1>};

alias S= tuple[int, int];


/* Example Clarke Model Checking page 16 

int L(S s) {return 0;}

str labe(S s) {return "(<s[0]> <s[1]>)";}

set[S] s0 = {<1, 1>};

rel[S, S] R = {<<1,1>,<0,1>>, <<0,1>,<1,1>>,
               <<1,0>,<1,0>>, <<0,0>,<0,0>>};
               
Kripke[S] M = <s, s0, R, L, labe>;
*/
public DotGraph toDot(Kripke[&T] m, int(&T) subgr) {
    map[&T, int] q = (toList(m.s)[i]:i|i<-[0..size(m.s)]);
    map[int, set[&T]] cls = ();
    for (&T s<-m.s) {
          if (cls[subgr(s)]?) {
             cls[subgr(s)]+= {s};
             }
          else
             cls[subgr(s)]={s};         
           }
    nodes= [S("cluster<d>", [N("N<q[s]>",[<"label", "<m.id(s)>">])|&T s<-cls[d]])|d<-cls];
    list[Stm] stms = nodes
    +[E("N<q[r[0]]>", "N<q[r[1]]>")|r<-m.r];
    return digraph("kripke", stms);
    }

public DotGraph toDot(Kripke[&T] m) {
    map[&T, int] q = (toList(m.s)[i]:i|i<-[0..size(m.s)]);
    list[Stm] stms = [N("N<q[s]>",[<"label", "<m.id(s)>">])|&T s<-m.s]
    +[E("N<q[r[0]]>", "N<q[r[1]]>")|r<-m.r];
    return digraph("kripke", stms);
    }
    
public Figure  toFig(Kripke[&T] m){
   map[&T, int] q = (toList(m.s)[i]:i|i<-[0..size(m.s)]);
   nodes = [box(text("<s>"), id("<q[s]>"), resizable(false))|&T s<-m.s];
   edges = [edge("<q[r[0]]>", "<q[r[1]]>")| r<-m.r];
   return graph(nodes, edges, size(600),gap(200));
}
    

public void main() {
   println(toDot(M));
   dotDisplay(toDot(M));   
}


