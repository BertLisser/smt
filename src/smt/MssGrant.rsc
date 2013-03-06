module smt::MssGrant
import demo::lang::MissGrant::ToRelation;
import demo::lang::MissGrant::AST;
import demo::lang::MissGrant::ToDot;
import IO;
import Set;
import demo::lang::MissGrant::Implode;
import dotplugin::Display;

public void main() {
   Controller c = parseAndImplode(|project://smt/src/missgrant.ctl|);
   dotDisplay(toDot(c, "top"));
   }

