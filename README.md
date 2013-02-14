smt
===

A demonstration for adding new project leaning on rascal. All you need to do
is:
* create a Rascal project
* edit the MANIFEST to add a dependency on the rascal-eclipse plugin
* create a plugin.xml file which mentions the rascalLibrary plugin (no
attributes or parameters)
* make sure the new project is active in your run-time configuration for
the second level
* start a second level
* the project and also its Java classes will be available to Rascal
console and rascal parsers. For now Rascal modules should be located
always in the "src" folder


In the case of the smt project this already done.
The only thing what you have to do is: import the project from repository smt.


You can solve an example sudoku by running the main van sudoku/Sudoku.rsc. 
