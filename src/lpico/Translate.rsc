module lpico::Translate
import Prelude;
import smt::Kripke;
import lang::dot::Dot;
import dotplugin::Display;
import lpico::Abstract;
import lpico::ControlEq;
import lpico::Syntax;
import smt::Propositions;

public void main() {
   Programs p = parse(#Programs,|project://smt/src/lpico/test.lpic|);
   println(p);
   PROGRAMS m = implode(#PROGRAMS, p);
   println(cflowPrograms(m));
   // visualize(p, |file:///|);
}
