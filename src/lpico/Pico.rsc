module lpico::Pico

import Prelude;
import util::IDE;

// import vis::Figure;
// import vis::Render;


import lpico::Abstract;
import lpico::Syntax;

import lpico::ControlFlow;
import demo::lang::Pico::Uninit;
// import demo::lang::Pico::Visualize;
// import lpico::Concur;

//  define the language name and extension

private str Pico_NAME = "LPico";
private str Pico_EXT = "lpic";

//  Define the connection with the Pico parser
Tree parser(str x, loc l) {
    return parse(#start[Programs], x, l);
}

//  Define connection with the Pico checkers
// (includes type checking and uninitialized variables check)

public Program checkPicoProgram(Program x) {
	PROGRAMS p = implode(#PROGRAMS, x);
	env = checkProgram(p);
	errors = { error(v, l) | <loc l, PicoId v> <- env.errors };
	if(!isEmpty(errors))
		return x[@messages = errors];
    ids = uninitProgram(p);
	warnings = { warning("Variable <v> maybe uninitialized", l) | <loc l, PicoId v, STATEMENT s> <- ids };
	return x[@messages = warnings];
}



//  Define connection with CFG visualization

public void visualizePicoProgram(Program x, loc selection) {
	m = implode(#PROGRAMS, x); 
	CFG = cflowProgram(m);
	text("dag");
	// render(visCFG(CFG.graph));
}

	
//  Define all contributions to the Pico IDE

/*
public set[Contribution] Pico_CONTRIBS = {
	popup(
		menu("Pico",[	    
    		action("Show Control flow graph", visualize)
	    ])
  	)
};
*/

public void main() {
    registerPico();
    }

//  Register the Pico tools

public void registerPico() {
  registerLanguage(Pico_NAME, Pico_EXT, parser);
  registerAnnotator(Pico_NAME, checkPicoProgram);
  // registerContributions(Pico_NAME, Pico_CONTRIBS);
}

