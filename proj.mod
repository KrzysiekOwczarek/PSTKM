set OLT;
set CABINETS;
set APS;
set NODES := CABINETS union APS union OLT;
set OLT_CAB_LINKS within (OLT cross CABINETS);
set CAB_AP_LINKS within (CABINETS cross APS);

set ALL_LINKS := OLT_CAB_LINKS union CAB_AP_LINKS;

set CABLES;
set SPLITTERS;

param clients_in_ap {APS} >= 0;
param splitter_cost {SPLITTERS} >= 0;
param splitter_output {SPLITTERS} >= 0;
param fiber_cost_per_km {CABLES} >= 0;
param fibers {CABLES} >= 0;
param link_length {ALL_LINKS} >= 0;
param demand {ALL_LINKS} >= 0;
param children {NODES} >= 0;

param M >= 0; # min clients to serve
param N >= 0; # max splits of signal

param originates {n in NODES, (i,j) in ALL_LINKS} binary :=
      if (i = n) then 1 else 0;							# al z zadania
param terminates {n in NODES, (i,j) in ALL_LINKS} binary :=
      if (j = n) then 1 else 0;							# bl z zadania

var SplitterUsed {s in SPLITTERS} >= 0 integer;
var SplittersInNode {n in NODES, s in SPLITTERS} >= 0 integer;
#var FiberUsed {c in CABLES} >= card(ALL_LINKS) integer;
#var SignalUsed {c in CABLES} >= 1 integer;
var Traffic {(i,j) in ALL_LINKS} >= 0, <= demand[i,j];

minimize TotalCost:
	(sum {s in SPLITTERS} splitter_cost[s] * SplitterUsed[s]);
	
subject to GlobalSplits:
	(sum {a in APS} children[a] + card(CABINETS) + card(APS))
	<= sum {s in SPLITTERS} (SplitterUsed[s] * splitter_output[s]) <= N;

subject to SplitterNumber:
 	sum {s in SPLITTERS} SplitterUsed[s] <=
 	(sum {a in APS} children[a] + card(CABINETS) + card(APS));
  
subject to K3{n in NODES}:
	(sum {s in SPLITTERS} SplittersInNode[n, s] * splitter_output[s]) >= children[n];

subject to K4{n in NODES}:
	(sum {s in SPLITTERS} SplittersInNode[n, s]) = 1;
	#suma spliterów w nodzie potem na byæ liczba fiberów
	
subject to K5{s in SPLITTERS}:
	(sum {n in NODES} SplittersInNode[n, s]) = SplitterUsed[s];
	#suma spliterów danego typu
	
#subject to K5{n in NODES, s in SPLITTERS}:
#	SplitterUsed[s] * splitter_output[s];
#subject to K2{s in SPLITTERS, n in NODES}:
#	8 >= splitter_output[s] >= children[n];
#subject to FiberNumber:
#	sum {c in CABLES} (FiberUsed[c] * fibers[c]) <= N;
	
#subject to SignalNumber:
#	card(ALL_LINKS) <= sum {c in CABLES} SignalUsed[c] <= N
	
#subject to SignalTransmit:
#	sum {c in CABLES} SignalUsed[c] >= sum {(i,j) in ALL_LINKS} demand[i,j];