@license{
  Copyright (c) 2009-2011 CWI
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Bert B. Lisser - Bert.Lisser@cwi.nl - CWI}

module smt::Dimacs

/*
c A sample .cnf file.
p cnf 3 2
1 -3 0
2 3 -1 0 
*/

layout Layout = [\ \t\r]* !>> [\ \t\r%];

lexical Comment = comment: "c" (![\n])* [\n];
syntax Prologue = prologue: "p" "cnf" Number variables Number clauses  "\n";

lexical Number 
  = positive: [0-9]+ !>> [0-9]
  | non-assoc negative: "-" Number number
  ;
              
start syntax Dimacs
  = Comment* comments  Prologue prologue {Line "\n"}+ lines "\n"?;

syntax Line 
  = disjunct: Disjunct disjunct
  ;

syntax Disjunct = Number+ numbers; 