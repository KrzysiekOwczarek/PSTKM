set OLT;
set CABINETS;
set APS;
set NODES := CABINETS union APS union OLT;

set LINKS within (OLT cross CABINETS) union (CABINETS cross APS);

set CABLES;
set SPLITTERS;

param splitter_cost {SPLITTERS} >= 0;
param splitter_output {SPLITTERS} >= 0;
param fiber_cost_per_km {CABLES} >= 0;
param fibers {CABLES} >= 0;
param signals_per_fiber {CABLES} >= 1;
param link_length {LINKS} >= 0;
param demand {LINKS} >= 0;
param children {NODES} >= 0;

param N >= 0; # max splits of signal					# bl z zadania

#check fiberow

var SplittersInNode {n in NODES, s in SPLITTERS} >= 0 integer;
var CablesInLink {(i,j) in LINKS, c in CABLES} >= 0 integer;

minimize TotalCost:
	(sum {s in SPLITTERS} splitter_cost[s] * (sum {n in NODES} SplittersInNode[n, s]))
	+ (sum {c in CABLES, (i,j) in LINKS} fiber_cost_per_km[c] * link_length[i,j] * CablesInLink[i,j,c]);

subject to A{n in NODES}: # splitter number per node == fibers incoming to node
	sum {s in SPLITTERS} SplittersInNode[n,s]
	== 
	if n in OLT then
		fibers['F2']
	else
		sum{c in CABLES, i in NODES: (i,n) in LINKS} CablesInLink[i,n,c] * fibers[c];

subject to B{n in NODES}: # outputs >= children
	sum {s in SPLITTERS} SplittersInNode[n,s] * splitter_output[s] >= children[n];
	
subject to C{(i,j) in LINKS}: # sum of signals in cable >= link demand
	sum {c in CABLES} CablesInLink[i,j,c] * fibers[c] * signals_per_fiber[c]
	>= demand[i,j];
	
subject to D{(i,j) in LINKS}: # max 1 CABLE PER NODE
	sum {c in CABLES} CablesInLink[i,j,c] = 1;