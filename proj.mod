set OLT;
set CABINETS;
set APS;
set NODES := CABINETS union APS union OLT;

set LINKS within (OLT cross CABINETS) union (CABINETS cross APS);

set CABLES;
set SPLITTERS;

set CONNS within {OLT cross CABINETS cross APS};

param clients_in_ap {APS} >= 0;
param splitter_cost {SPLITTERS} >= 0;
param splitter_output {SPLITTERS} >= 0;
param fiber_cost_per_km {CABLES} >= 0;
param fibers {CABLES} >= 0;
param link_length {LINKS} >= 0;
param demand {LINKS} >= 0;
param children {NODES} >= 0;

param incoming {(i,j) in LINKS, n in NODES};
param outgoing {(i,j) in LINKS, n in NODES};

param N >= 0; # max splits of signal					# bl z zadania

var SplittersInNode {n in NODES, s in SPLITTERS} >= 0 integer;
var CablesInLink {(i,j) in LINKS, c in CABLES} >= 0 integer;
var Splits {(i,j,k) in CONNS} >= 0 binary;

minimize TotalCost:
	(sum {s in SPLITTERS} splitter_cost[s] * (sum {n in NODES} SplittersInNode[n, s]))
	+ (sum {c in CABLES, (i,j) in LINKS} fiber_cost_per_km[c] * link_length[i,j]
	* sum {(i,j) in LINKS} CablesInLink[i,j,c]);
	
#subject to HowManySplitters:
# 	sum {s in SPLITTERS} SplitterUsed[s] <=
# 	(sum {a in APS} children[a] + card(CABINETS) + card(APS));

subject to T{n in NODES}: #Liczba SPLITTÓW per node = liczby polaczen wychodzacych z node
	sum {s in SPLITTERS} SplittersInNode[n,s] * splitter_output[s] 
	>= children[n];

subject to K4{n in NODES}: #liczba spliterów
	(sum {s in SPLITTERS} SplittersInNode[n, s]) = 1;
	#suma spliter���w w nodzie potem na by��� liczba fiber���w

## Zal. 1 fiber = 1 signal

subject to A{(i,j) in LINKS}: #liczba sygnalow = demands zalozenie 1fiber = 1signal
	sum {c in CABLES} CablesInLink[i,j,c] * fibers[c] >= demand[i,j];

subject to AA{(i,j) in LINKS}: #max 1 kabel
	sum {c in CABLES} CablesInLink[i,j,c] = 1;
	
subject to BBB{(i,j,k) in CONNS}: 
	(sum {s in SPLITTERS} splitter_output[s] * SplittersInNode[i,s]) *
	#(sum {s in SPLITTERS} splitter_output[s] * SplittersInNode[j,s]) *
	(sum {s in SPLITTERS} splitter_output[s] * SplittersInNode[k,s])
	<= N;
