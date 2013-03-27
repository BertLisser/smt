module smt::Main
import demo::lang::Pico::ControlFlow;
import demo::lang::Pico::Load;
import IO;


public void main() {
     CFGraph g = cflowProgram(
         load(readFile(|project://smt/src/concur.pico|)));
     println(g.graph);
     }