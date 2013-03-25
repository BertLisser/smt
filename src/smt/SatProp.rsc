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
public java list[map[str, str]] findModel(list[str] vars, Formula f, int maxSol);


@javaClass{smt.SatProp}
@reflect{Uses URI Resolver Registry}
public java void addVariables(str domainName, str vars...);



@javaClass{smt.SatProp}
@reflect{Uses URI Resolver Registry}
public java void addSignature(str name, str vals...);