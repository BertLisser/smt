/* Copyright (c) 2009-2011 CWI
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:

 *   * Jurgen J. Vinju - Jurgen.Vinju@cwi.nl - CWI
 *   * Bert Lisser    - Bert.Lisser@cwi.nl
 *******************************************************************************/
 
module smt::IO


import smt::Propositions;
import smt::Dimacs;
import Prelude;

/*
c A sample .cnf file.
p cnf 3 2
1 -3 0
2 3 -1 0 
*/
public Formula readDimacs(loc l) = dimacsToFormula(parse(#start[Dimacs], l).top);

public list[list[int]] readDimacsCnf(loc l) = dimacsToCnf(parse(#start[Dimacs], l).top);

public void writeDimacsCnf(loc l, list[list[int]] cnf, int nvars) {
     /*
     writeFile(l, "c sudoku\np cnf <size(cnf)> <nvars>\n");
     for (r<-cnf) 
        appendToFile(l, "<for(d<-r){><d> <}>0\n");
     */
     str r = "c sudoku\np cnf <size(cnf)> <nvars>\n";
     for (q<-cnf)  r+= "<for(d<-q){><d> <}>0\n";
     writeFile(l, r);
}

public list[list[int]] dimacsToCnf(Dimacs d) {
    list[int] v = [];
    for ( Line l <- d.lines, l is disjunct) {
       // v+=[n is positive ? toInt("<n>") : -toInt("<n>") |n<-l.disjunct.numbers];
       v+=[toInt("<n>") |n<-l.disjunct.numbers];
    }
    list[list[int]] r = [];
    while  (!isEmpty(v)) {
          list[int] w = takeWhile(v, bool(int x) {return x != 0;});
          r+=[w];
          int n = size(v)-(size(w)+1);
          v = tail(v, n);
          }
     return r;
     }

public Formula dimacsToFormula(Dimacs d) {
    list[list[int]] r = dimacsToCnf(d);
    return and({ or({(m >0) ? v("<m>") : not(v("<m>")) | int m <- l}) | list[int] l <- r});
    }



