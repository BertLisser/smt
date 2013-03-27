module smt::Kripke
import IO;
import Set;
import lang::dot::Dot;
import dotplugin::Display;


alias Kripke[&T]=tuple[set[&T] s, set[&T] s0, rel[&T, &T] r ,bool(&T) l, str(&T) id];

set[S] s = {<0,0>,<0,1>, <1,0>, <1,1>};

alias S= tuple[int, int];


/* Example Clarke Model Checking page 16 */

bool L(S s) {return true;}

str label(S s) {return "(<s[0]> <s[1]>)";}

set[S] s0 = {<1, 1>};

rel[S, S] R = {<<1,1>,<0,1>>, <<0,1>,<1,1>>,
               <<1,0>,<1,0>>, <<0,0>,<0,0>>};
               
Kripke[S] M = <s, s0, R, L, label>;

public DotGraph toDot(Kripke[&T] m) {
    map[&T, int] q = (toList(m.s)[i]:i|i<-[0..size(m.s)]);
    list[Stm] stms = [N("N<q[s]>",[<"label", "<m.id(s)>">])|&T s<-m.s]
    +[E("N<q[r[0]]>", "N<q[r[1]]>")|r<-m.r];
    return digraph("kripke", stms);
    }
    

public void main() {
   println(toDot(M));
   dotDisplay(toDot(M));   
}


