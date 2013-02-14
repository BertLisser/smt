module sudoku::Sudoku
import Prelude;
import SudokuEq;
import IO;
import Number;
import smt::IO;
import smt::SatProp;
import vis::Figure;
import vis::Render;
import vis::KeySym;

str lab = "";
// int siz = 3*198;
int siz = 3*100;
list[Figure] input, output;
list[int] val, sol;

public list[int] readSudoku(loc f) {
   list[str] s = [stringChar(x)|x<-readFileBytes(f)];
   list[int] w = [c=="."?0:-toInt(c)|c<-s];
   list[int] r = [w[(i/27)*27+((i%27)/9)*3+((i%9)/3)*9+i%3]|i<-[0..81]];
   return r;
}

public void updateVal(int i, int j, int v) {
   int k = 9*j+i;
   sol[(k/27)*27+((k%27)/9)*3+((k%9)/3)*9+k%3] = 
   (sol[(k/27)*27+((k%27)/9)*3+((k%9)/3)*9+k%3]>=0)?v:-v;
   }

public bool keyDown(bool isInput, int idName, KeySym key, map[KeyModifier,bool] modifiers) {
      if (!isInput) return true;
      if (val[idName]<0) return true;
      if (keyPrintable(c):=key) {
            if (c==" ") {
               sol[idName]= 0;
               val[idName]=0;
               lab="";
               return true;
            }
            try {
               int d = toInt(c);
               if (d<=0 || d > 9) throw IllegalArgument();
		       sol[idName]= d;
		       val[idName] = d;
		        if (!isSubgridInjective(idName) 
		            || !isRowInjective(idName)
		            || !isColumnInjective(idName)
		            ) {
		            sol[idName]=0;
		            val[idName]=0;
		            throw AssertionFailed();
		            }       
		        lab = c;
		        }	     
		      catch IllegalArgument(): 
		        lab = "Not a number between 1 and 9";
		      catch AssertionFailed():
		        lab = 
		        "Row, column, or subgrid does not statisfy conditions of sudoku"; 
		    }	    
		return true;
}

Figure entryCell(bool isInput, int idName) {
   return box(
   text(str () {
     int v= isInput?val[idName]:sol[idName];
     // println("v=<v> name=<idName>");
     // return (v==0)?"<getFree(idName)>":"<(v>0?v:-v)>";
     return (v==0)?"":"<(v>0?v:-v)>";
     })
   ,fillColor(Color() {
       return color((isInput?val[idName]:sol[idName])<0?"lightGrey":"white");
      }) 
   ,id("<idName>"), size(siz/9)
   ,std(fontSize(int(){return ((isInput?val[idName]:sol[idName])==0?7:12);}))
,onKeyDown( bool (KeySym key, map[KeyModifier,bool] modifiers) {
      return keyDown( isInput, idName, key, modifiers); 
	}
	));
}


// list[int] val=[0|int i<-[0..81]], sol=[0|int i<-[0..81]];

list[int] getFreeForRow(int p) {
    int k = p/27;
    int s = (p%9)/3;
    int low=27*k+3*s;
    return ([1..10]-[abs(val[i])|int i<-
    [low..low+3]+[low+9..low+12]+[low+18..low+21],
      val[i]!=0]);
    }
    
list[int] getFreeForColumn(int p) {
    int low=(p%3)+((p%27)/9)*9;
    return([1..10]-[abs(val[i])|int i<-
        [low,low+3,low+6]+[low+27,low+30,low+33]+
      [low+54,low+57,low+60], val[i]!=0]);
   }
   
list[int] getFreeForSubgrid(int p) {
   int low = (p/9)*9;
   return ([1..10]-[abs(val[i])|int i<-[low..low+9], val[i]!=0]);
   }
   
list[int] getFree(int p) {return 
  getFreeForColumn(p)&getFreeForRow(p)&getFreeForSubgrid(p);
  }

   
bool isSubgridInjective(int p) {
   int low = (p/9)*9;
   list[int] row =  [abs(val[i])|int i<-[low..low+9], val[i]!=0];
   if (size(toSet(row))==size(row)) return true;
   return false;
}

bool isRowInjective(int p) {
    int k = p/27;
    int s = (p%9)/3;
    int low=27*k+3*s;
    list[int] row =  [abs(val[i])|int i<-
    [low..low+3]+[low+9..low+12]+[low+18..low+21],
      val[i]!=0];
    if (size(toSet(row))==size(row)) return true;
    return false;
    }
    
bool isColumnInjective(int p) {
    int low=(p%3)+((p%27)/9)*9;
    list[int] row =  [abs(val[i])|int i<-
    [low,low+3,low+6]+[low+27,low+30,low+33]+
      [low+54,low+57,low+60], val[i]!=0];
    if (size(toSet(row))==size(row)) return true;
    return false;
    }
    


Figure newInput() {Figure r = head(input); input = tail(input);return r;}
Figure newOutput() {Figure r = head(output); output = tail(output);return r;}

list[Figure] newRow(bool isInput) {return 
isInput?[newInput(), newInput(), newInput()]:
         [newOutput(), newOutput(), newOutput()];
         }

Figure newSubgrid(bool isInput) {return (box(grid([newRow(isInput), newRow(isInput), newRow(isInput)]), gap(1)));}

list[Figure] newSubgridRow(isInput) {
  return([newSubgrid(isInput), newSubgrid(isInput), newSubgrid(isInput)]);}

public bool solv(int p) {
   list[int] free = getFree(p);
   if (isEmpty(free)) return false;
   for (int d <- free) {
      // println("p = <p> d=<d>");
      val[p] = d;
      if (solv()) return true;
      }
    val[p] = 0;
    return false;
}

public bool solv() {
   int p = 0;
   while (p<81 && val[p]!=0) p = p+1;
   if (p==81) return true;
   return solv(p);
}

/* ------------------- Sat solving -------- */

public int getCellValue(int r, int c) {
    int low = (c%3)*3+ (c/3)*27;
    list[int] row =  [abs(sol[i])|int i<-
    [low..low+3]+[low+9..low+12]+[low+18..low+21]];
    return row[r];
    }
    
list[list[int]] cnfs = readDimacsCnf(|project://smt/src/sudoku/SudokuEq.cnf|);
    
public void satSolve() {
   list[list[int]] constraints = [];
   for (int x<-[0..9], int y <-[0..9]) {
       int d = getCellValue(x, y)-1;
       if (d>=0) {
         constraints+= [[(i==d?s(x, y, i):-s(x, y, i))]|int i<-[0..9]];
       } 
   }  
   list[list[int]] clauses = cnfs;
   clauses+=constraints;
   list[list[int]] b = findModel(clauses, 5);
   if (size(b)==0) {println("No solution");return;}
   if (size(b)>1) {println("Too many solutions");return;}
   println(fieldValues(b[0]));
   for (<int i, int j, int v><-fieldValues(b[0]))
        updateVal( i, j, v);
  }
    

/* ----------------------------------------- */

public void main() { 
   // list[int] sdku=readSudoku(|project://aap/src/sudoku3328.txt|);
   list[int] sdku=readSudoku(|project://smt/src/sudoku/example1.txt|);
   val = sdku;
   sol = sdku;
   input = [entryCell(true, i)|int i<-[0..81]];
   output = [entryCell(false, i)|int i<-[0..81]];
   Figure newInputGrid = grid([newSubgridRow(true), newSubgridRow(true), newSubgridRow(true)]); 
   Figure newOutputGrid = grid([newSubgridRow(false), newSubgridRow(false), newSubgridRow(false)]);  
   Figure fig = 
       
       vcat(
          [hcat(
           [
             vcat([text("standard"),newInputGrid
             ,button("Solve",void(){solv();})
              ])
            ,vcat([text("sat"),newOutputGrid
            , button("Solve",void(){satSolve();}) 
            ])]
           , gap(5))
           , text(str() {return lab;})
          ],   
        std(aspectRatio(1.0)),std(resizable(false))); 
   render(fig);
}