module smt::SatProp
import smt::Propositions;


@javaClass{smt.SatProp}
@reflect{Uses URI Resolver Registry}
public java bool isSatisfiable(list[list[int]] clauses);

@javaClass{smt.SatProp}
@reflect{Uses URI Resolver Registry}
public java list[list[int]] findModel(list[list[int]] clauses, int maxSol);

@javaClass{smt.SatProp}  
@reflect{Uses URI Resolver Registry} 
public java bool isSatisfiable(list[str] vars, Formula f);

@javaClass{smt.SatProp}
@reflect{Uses URI Resolver Registry}
public java list[list[str]] findModel(list[str] vars, Formula f, int maxSol);


@javaClass{smt.SatProp}
@reflect{Uses URI Resolver Registry}
public java void addConstants(list[str] constants);

@javaClass{smt.SatProp}
@reflect{Uses URI Resolver Registry}
public java void addVariables(list[str] variables);


@javaClass{smt.SatProp}
@reflect{Uses URI Resolver Registry}
public java void addBoundedVariables(list[str] constants, list[str] variables);
