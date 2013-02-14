package smt;

import org.eclipse.imp.pdb.facts.IInteger;
import org.eclipse.imp.pdb.facts.IValueFactory;
import org.rascalmpl.interpreter.IEvaluatorContext;

public class Aap {

	private final IValueFactory values;

	public Aap(IValueFactory values) {
		super();
		this.values = values;
	}
	
	public IInteger aap(IEvaluatorContext ctx) {
		return values.integer(44);
	}
}
