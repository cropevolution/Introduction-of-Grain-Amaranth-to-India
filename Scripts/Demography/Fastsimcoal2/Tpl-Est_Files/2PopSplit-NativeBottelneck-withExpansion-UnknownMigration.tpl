//Parameters for the coalescence simulation program : fastsimcoal.exe
3 samples to simulate :
//Population effective sizes (number of genes)
10000000
NATIVE$
INDIA$
//Samples sizes and samples age 
0
26
22
//Growth rates	: negative growth implies population expansion
0
0
R1
//Number of migration matrices : 0 implies no migration between demes
2
//Migration matrix 0
0.000 0.000 MIG13
0.000 0.000 0.000 
0.000 0.000 0.000
//Migration matrix 1
0.000 0.000 0.000
0.000 0.000 0.000
0.000 0.000 0.000
//historical event: time, source, sink, migrants, new deme size, new growth rate, migration matrix index
3 historical event
TBOT$ 1 1 0 RES1 0 0
TENDBOT$ 1 1 0 RES2 0 0
TDIV$ 2 1 1 RESIZE 0 1
//Number of independent loci [chromosome] 
1 0
//Per chromosome: Number of contiguous linkage Block: a block is a set of contiguous loci
1
//per Block:data type, number of loci, per generation recombination and mutation rates and optional parameters
FREQ 1 0 7e-9 OUTEXP

