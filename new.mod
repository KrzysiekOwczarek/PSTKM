set OLT;
set CABINETS;
set APS;
set CLIENTS;
set EDGES within {(OLT cross CABINETS) union (CABINETS cross APS) union (APS cross CLIENTS)};
set DEMANDS;
set SPLITTERS;

set NODES = {OLT union CABINETS union APS union CLIENTS};

param source {d in DEMANDS, n in NODES};
param destination {d in DEMANDS, n in NODES};
param incoming {(i,j) in EDGES, n in NODES};
param outgoing {(i,j) in EDGES, n in NODES}; 
param demand_val {DEMANDS} >= 0;
param splitter_cost {SPLITTERS} >= 0;
param splitter_output {SPLITTERS} >= 0;
param ap_clients {APS} >= 0;
param N >= 0;

param originates {n in NODES, (i,j) in EDGES} binary :=
      if (i = n) then 1 else 0;							# al z zadania
param terminates {n in NODES, (i,j) in EDGES} binary :=
      if (j = n) then 1 else 0;							# bl z zadania

var splitters {s in SPLITTERS} >= 0 integer;
var splittersInNodes {s in SPLITTERS, n in NODES} >= 0 integer;

minimize TotalCost: sum {s in SPLITTERS} splitter_cost[s] * splitters[s];

subject to GlobalSplits:
	(sum {a in APS} ap_clients[a] + card(CABINETS) + card(APS))
	<= sum {s in SPLITTERS} (splitters[s] * splitter_output[s]) <= N;
	
subject to O{n in NODES}: #Liczba splitterow per node >=(?=) liczbie polaczen wchodzacych do node
	sum {s in SPLITTERS} splittersInNodes[s,n] = sum {(i,j) in EDGES} incoming[i,j,n];
	
subject to D{s in SPLITTERS}:
	(sum {n in NODES} splittersInNodes[s, n]) = splitters[s];
	
subject to T{n in NODES}: #Liczba SPLITTÓW per node = liczby polaczen wychodzacych z node
	sum {s in SPLITTERS} splittersInNodes[s,n] * splitter_output[s] = sum {(i,j) in EDGES} outgoing[i,j,n];