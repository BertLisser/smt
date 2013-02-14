@license{
  Copyright (c) 2009-2013 CWI
  All rights reserved. This program and the accompanying materials
  are made available under the terms of the Eclipse Public License v1.0
  which accompanies this distribution, and is available at
  http://www.eclipse.org/legal/epl-v10.html
}
@contributor{Jurgen J. Vinju - Jurgen.Vinju@cwi.nl - CWI}
module smt::Propositions

data Formula 
  = \true()
  | \false()
  | v(str x)
  | \not(Formula arg)
  | \and(Formula lhs, Formula rhs)
  | \and(set[Formula] args)
  | \or(Formula lhs, Formula rhs)
  | \or(set[Formula] args)
  | \if(Formula lhs, Formula rhs)
  | \fi(Formula lhs, Formula rhs)
  | \iff(Formula lhs, Formula rhs)   
  ;

public Formula or({Formula x}) = x;
public Formula and({Formula x}) = x;
public Formula and(Formula a, Formula b) = and({a,b});
public Formula or(Formula a, Formula b) = or({a,b});
public Formula and({set[Formula] a, and(set[Formula] b)}) = and(a + b);
public Formula or({set[Formula] a, or(set[Formula] b)}) = or(a + b);