set OLT;
set CABINETS;
set APS;
set NODES := CABINETS union APS union OLT;
set NOLT := CABINETS union APS;
set OLT_CAB_LINKS within (OLT cross CABINETS);
set CAB_AP_LINKS within (CABINETS cross APS);

set ALL_LINKS := OLT_CAB_LINKS union CAB_AP_LINKS;

set CABLES;
set SPLITTERS;

param clients_in_ap {APS} >= 0;
param splitter_cost {SPLITTERS} >= 0;
param splitter_output {SPLITTERS} >= 0;
param fiber_cost_per_km {CABLES} >= 0;
param link_length {NODES} >= 0;
param children {NODES} >= 0;
param fibers {CABLES} >= 0;
param uchild {n in NODES, m in NODES} >= 0;
param uparent {n in NODES, m in NODES} >= 0;
param L >= 0;

#param M >= 0; # min clients to serve
#param N >= 0; # max splits of signal



var SplittersInNode {n in NODES, s in SPLITTERS} >= 0 integer;
var CableToNode {n in NODES, c in CABLES} >= 0 integer;
var Fiberin {n in NODES} >=0 integer;
var Fiberout {n in NODES} >=0 integer;

minimize TotalCost:
	(sum {s in SPLITTERS} splitter_cost[s] * (sum {n in NODES} SplittersInNode[n, s]))
	+ (sum {c in CABLES, n in NODES} fiber_cost_per_km[c] * CableToNode[n, c] * link_length[n] );
	#dodaæ koszt kabli
	
subject to K1 {n in NODES}:
	Fiberout[n] = (sum {m in NODES} uchild[n, m] * Fiberin[m]);
	#liczba fiberów na wyjœciu to suma wejœæ do dzieci
	
subject to K2 {n in APS}:
	L * Fiberin[n] >= children[n];
#subject to GlobalSplits:
#	(sum {a in APS} children[a] + card(CABINETS) + card(APS))
#	<= sum {s in SPLITTERS} (SplitterUsed[s] * splitter_output[s]) <= N;
  
subject to K3{n in NODES}:
	(sum {s in SPLITTERS} SplittersInNode[n, s] * splitter_output[s]) >= Fiberout[n];
	#suma wyjœæ splitterów ma byæ wiêksza/równa fiberom wychodz¹cym

subject to K4{n in NODES}:
	(sum {s in SPLITTERS} SplittersInNode[n, s]) = Fiberin[n];
	#suma spliterów w nodzie ma byæ równa fiberom wchodz¹cym
	
subject to K5 {n in NODES}:
	(sum {c in CABLES} CableToNode[n, c]) = 1;
	#1 wybrany kabel na ³¹czu
	
subject to K6 {n in NODES}:
	(sum {c in CABLES} CableToNode[n, c] * fibers[c]) >= Fiberin[n];
	#fibery w kablu maj¹ pomieœciæ fibery wymagane