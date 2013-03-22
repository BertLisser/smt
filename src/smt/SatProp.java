package smt;

/* Copyright (c) 2009-2011 CWI
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Contributors:

 *   * Jurgen J. Vinju - Jurgen.Vinju@cwi.nl - CWI
 *   * Mark Hills - Mark.Hills@cwi.nl (CWI)
 *   * Arnold Lankamp - Arnold.Lankamp@cwi.nl
 *   * Bert Lisser    - Bert.Lisser@cwi.nl
 *******************************************************************************/

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Set;

import org.eclipse.imp.pdb.facts.IBool;
import org.eclipse.imp.pdb.facts.IConstructor;
import org.eclipse.imp.pdb.facts.IInteger;
import org.eclipse.imp.pdb.facts.IList;
import org.eclipse.imp.pdb.facts.ISet;
import org.eclipse.imp.pdb.facts.ISetWriter;
import org.eclipse.imp.pdb.facts.IString;
import org.eclipse.imp.pdb.facts.IListWriter;
import org.eclipse.imp.pdb.facts.IValue;
import org.eclipse.imp.pdb.facts.IValueFactory;
import org.eclipse.imp.pdb.facts.exceptions.FactTypeUseException;
import org.eclipse.imp.pdb.facts.type.Type;
import org.rascalmpl.interpreter.IEvaluatorContext;
import org.sat4j.core.VecInt;
import org.sat4j.minisat.SolverFactory;
import org.sat4j.specs.ContradictionException;
import org.sat4j.specs.ISolver;
import org.sat4j.specs.TimeoutException;
import org.sat4j.tools.GateTranslator;
import org.sat4j.tools.ModelIterator;

public class SatProp {
	final int width = 6;
	private final IValueFactory values;
	private ISolver solver = SolverFactory.newDefault();
	private GateTranslator gateTranslator = new GateTranslator(solver);
	private ModelIterator modelIterator = new ModelIterator(solver);
	private HashMap<String, Integer> str2int = new HashMap<String, Integer>();
	private HashMap<Integer, String> int2str = new HashMap<Integer, String>();
	final private HashMap<String, int[]> constants = new HashMap<String, int[]>();
	final private HashMap<String, String> variables = new HashMap<String, String>();
	private int startVar = 1;
	private int freeVar = 0;
	private HashMap<String, HashMap<String, boolean[]>> domainElm = new HashMap<String, HashMap<String, boolean[]>>();
	private HashMap<String, HashMap<String, int[]>> domainVar = new HashMap<String, HashMap<String, int[]>>();

	IConstructor getAndConstructor(IEvaluatorContext ctx, IValue... args) {
		ISetWriter w = values.setWriter();
		w.insert(args);
		return getAndConstructor(ctx, w.done());
	}

	IConstructor getAndConstructor(IEvaluatorContext ctx, ISet args) {
		Set<Type> cs = ctx.getCurrentEnvt().lookupConstructors("and");
		for (Type t : cs) {
			if (t.isConstructorType() && t.getArity() > 0) {
				if (t.getFieldType(0).isSetType()) {
					return values.constructor(t, args);
				}
			}
		}
		return null;
	}

	IConstructor getOrConstructor(IEvaluatorContext ctx, IValue... args) {
		ISetWriter w = values.setWriter();
		w.insert(args);
		return getOrConstructor(ctx, w.done());
	}

	IConstructor getOrConstructor(IEvaluatorContext ctx, ISet args) {
		Set<Type> cs = ctx.getCurrentEnvt().lookupConstructors("or");
		for (Type t : cs) {
			if (t.isConstructorType() && t.getArity() > 0) {
				if (t.getFieldType(0).isSetType()) {
					return values.constructor(t, args);
				}
			}
		}
		return null;
	}

	IConstructor getEqConstructor(IEvaluatorContext ctx, String varName,
			String constName) {
		Set<Type> cs = ctx.getCurrentEnvt().lookupConstructors("equ");
		for (Type t : cs) {
			if (t.isConstructorType() && t.getArity() == 2) {
				IString var = values.string(varName);
				IString constant = values.string(constName);
				if (t.getFieldType(0).isStringType()
						&& t.getFieldType(1).isStringType()) {
					return values.constructor(t, var, constant);
				}
			}
		}
		return null;
	}

	public SatProp(IValueFactory values) {
		super();
		this.values = values;
	}

	private void solverReset(IList clauses) {
		solver.reset();
		solver.setTimeout(60);
		Iterator<IValue> it = clauses.iterator();
		while (it.hasNext()) {
			IList t = (IList) it.next();
			VecInt v = new VecInt(t.length());
			for (IValue q : t) {
				v.push(((IInteger) q).intValue());
			}
			try {
				solver.addClause(v);
			} catch (ContradictionException e) {
				System.err.println(e.getMessage());
			}

		}
	}

	public IBool isSatisfiable(IList clauses, IEvaluatorContext ctx) {
		// 1 minute timeout
		solverReset(clauses);
		try {
			return values.bool(solver.isSatisfiable());
		} catch (TimeoutException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return values.bool(false);
		}
	}

	// public IBool isSatisfiable(IList clauses) {
	// boolean r = false;
	// try {
	// r = solver.isSatisfiable();
	// } catch (TimeoutException e) {
	// // TODO Auto-generated catch block
	// e.printStackTrace();
	// }
	// return values.bool(r);
	// }

	public int createGate(IConstructor c) throws ContradictionException {
		if (c.getName().equals("v")) {
			IString s = (IString) c.get(0);
			return str2int.get(s.getValue());
		}
		int fv = (freeVar++);
		if (c.getName().equals("false"))
			gateTranslator.gateFalse(fv);
		else if (c.getName().equals("true"))
			gateTranslator.gateTrue(fv);
		else if (c.getName().equals("equ")) {
			String vname = ((IString) c.get(0)).getValue();
			String cname = ((IString) c.get(1)).getValue();
			String domain = variables.get(vname);
			int[] var = domainVar.get(domain).get(vname);
			int[] consts = constants.get(cname);
			VecInt w = new VecInt(var.length);
			for (int i = 0; i < var.length; i++) {
				int fw = (freeVar++);
				VecInt v = new VecInt(2);
				v.push(var[i]);
				v.push(consts[i]);
				gateTranslator.iff(fw, v);
				w.push(fw);
			}
			gateTranslator.and(fv, w);
		} else if (c.getName().equals("not")) {
			gateTranslator.not(fv, createGate((IConstructor) c.get(0)));
		} else if (c.getName().equals("and")) {
			ISet s = ((ISet) c.get(0));
			VecInt v = new VecInt(s.size());
			for (IValue e : s) {
				int d = createGate((IConstructor) e);
				v.push(d);
			}
			gateTranslator.and(fv, v);
		} else if (c.getName().equals("or")) {
			ISet s = ((ISet) c.get(0));
			VecInt v = new VecInt(s.size());
			for (IValue e : s) {
				int d = createGate((IConstructor) e);
				v.push(d);
			}
			gateTranslator.or(fv, v);
		} else if (c.getName().equals("iff")) {
			IConstructor a1 = ((IConstructor) c.get(0));
			IConstructor a2 = ((IConstructor) c.get(1));
			VecInt v = new VecInt(2);
			int d1 = createGate(a1);
			v.push(d1);
			int d2 = createGate(a2);
			v.push(d2);
			gateTranslator.iff(fv, v);
		} else if (c.getName().equals("if")) {
			IConstructor a1 = ((IConstructor) c.get(0));
			IConstructor a2 = ((IConstructor) c.get(1));
			int d1 = createGate(a1);
			int d2 = createGate(a2);
			int fv1 = freeVar++;
			gateTranslator.gateTrue(fv1);
			gateTranslator.ite(fv, d1, d2, fv1);
		}
		return fv;
	}

	private void gateReset(IList vars, IConstructor c, IEvaluatorContext ctx)
			throws ContradictionException {
		gateTranslator.reset();
		gateTranslator.newVar(vars.length() + 100);
		freeVar = startVar;
		constants.clear();
		ISetWriter w = values.setWriter();
		for (String domainName : domainElm.keySet()) {
			Set<String> cs = domainElm.get(domainName).keySet();
			Set<String> vs = domainVar.get(domainName).keySet();
			for (String s : cs) {
				boolean[] code = domainElm.get(domainName).get(s);
				int[] r = new int[width];
				int i = 0;
				for (boolean g : code) {
					if (g)
						gateTranslator.gateTrue(freeVar);
					else
						gateTranslator.gateFalse(freeVar);
					r[i++] = freeVar;
					freeVar++;
				}
				constants.put(s, r);
			}
			w.insert(computeDomainConstraint(cs, vs, ctx));
		}
		str2int.clear();
		int2str.clear();
		for (IValue v : vars) {
			str2int.put(((IString) v).getValue(), freeVar);
			int2str.put(freeVar, ((IString) v).getValue());
			freeVar++;
		}
		c = getAndConstructor(ctx, c, w.done());
		gateTranslator.gateTrue(createGate(c));
	}

	private IConstructor computeDomainConstraint(Set<String> cnames,
			Set<String> vnames, IEvaluatorContext ctx) {
		ISetWriter h = values.setWriter();
		for (String v : vnames) {
			ISetWriter w = values.setWriter();
			for (String c : cnames) {
				w.insert(getEqConstructor(ctx, v, c));
			}
			h.insert(getOrConstructor(ctx, w.done()));
		}
		return getAndConstructor(ctx, h.done());
	}

	public IBool isSatisfiable(IList vars, IConstructor c, IEvaluatorContext ctx) {
		try {
			gateReset(vars, c, ctx);
			return values.bool(gateTranslator.isSatisfiable());
		} catch (ContradictionException e) {
			// TODO Auto-generated catch block
			System.err.println(e.getMessage());
			return values.bool(false);
		} catch (TimeoutException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
			return values.bool(false);
		}
	}

	public IList findModel(IList clauses, IInteger maxSolutions,
			IEvaluatorContext ctx) {
		int maxSol = maxSolutions.intValue();
		IListWriter x = values.listWriter();
		modelIterator.reset();
		solverReset(clauses);
		try {
			for (; maxSol > 0 && modelIterator.isSatisfiable(); maxSol--) {
				IListWriter w = values.listWriter();
				int[] m = modelIterator.model();
				for (int z : m) {
					w.append(values.integer(z));
				}
				x.append(w.done());
			}
		} catch (FactTypeUseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (TimeoutException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return x.done();
	}

	public IList findModel(IList vars, IConstructor c, IInteger maxSolutions,
			IEvaluatorContext ctx) {
		int maxSol = maxSolutions.intValue();
		IListWriter x = values.listWriter();
		try {
			modelIterator.reset();
			gateReset(vars, c, ctx);
			for (; maxSol > 0 && modelIterator.isSatisfiable(); maxSol--) {
				// System.err.println("findModel:"+maxSol);
				int[] m = modelIterator.model();
				IListWriter w = values.listWriter();
				for (String s : variables.keySet()) {
					int[] g = domainVar.get(variables.get(s)).get(s);
					boolean[] z = new boolean[width];
					for (int i = 0; i < width; i++) {
						System.err.println(s + ":" + g[i] + " "
								+ modelIterator.model(g[i]));
						z[i] = modelIterator.model(g[i]);
					}
					String v = lookupConstant(z);
					w.append(values.string(s));
					w.append(values.string(v));
				}

				// for (int z : m) {
				// int d = z < 0 ? -z : z;
				// if (int2str.get(d) != null)
				// w.append(values.string(int2str.get(d)));
				// else
				// w.append(values.string(String.valueOf(d)));
				// w.append(values.string(z<0?"F":"T"));
				// }
				x.append(w.done());
			}
		} catch (ContradictionException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (FactTypeUseException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (TimeoutException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return x.done();
	}

	private boolean[] boolCode(int k) {
		boolean[] r = new boolean[width];
		for (int i = 0; i < width; i++) {
			r[i] = k % 2 == 1;
			k = k / 2;
		}
		return r;
	}

	private int[] varCode() {
		int[] r = new int[width];
		for (int i = 0; i < width; i++) {
			int v = startVar + i;
			r[i] = v;
		}
		startVar += width;
		return r;
	}

	private HashMap<String, boolean[]> getConstructors(IList cnames) {
		final HashMap<String, boolean[]> hm = new HashMap<String, boolean[]>();
		int k = 0;
		for (IValue v : cnames) {
			hm.put(((IString) v).getValue(), boolCode(k));
			k++;
		}
		return hm;
	}

	public String lookupConstant(boolean[] varcode) {
		for (String domainName : domainElm.keySet()) {
			for (String s : domainElm.get(domainName).keySet()) {
				boolean[] q = domainElm.get(domainName).get(s);
				int j = 0;
				/*
				 * System.err.println(s); for (j = 0; j < width; j++) {
				 * System.err.print(varcode[j]); } System.err.println(); for (j
				 * = 0; j < width; j++) { System.err.print(q[j]); }
				 * System.err.println();
				 */
				for (j = 0; j < width; j++) {
					if (varcode[j] != q[j])
						break;
				}
				if (j == width)
					return s;
			}
		}
		return "?";
	}

	// and(
	// or(eq("q", "aap"), eq("q","noot")),
	// or(eq("r", "aap"), eq("r","noot"))
	// ))

	public void addSignature(IString name, IList vals, IEvaluatorContext ctx) {
		HashMap<String, boolean[]> constructors = getConstructors(vals);
		domainElm.put(name.getValue(), constructors);
	}

	public void addVariables(IString name, IList vnames, IEvaluatorContext ctx) {
		HashMap<String, int[]> var = domainVar.get(name);
		if (var == null)
			var = new HashMap<String, int[]>();
		for (IValue v : vnames) {
			var.put(((IString) v).getValue(), varCode());
			variables.put(((IString) v).getValue(), name.getValue());
		}
		domainVar.put(name.getValue(), var);
	}

}