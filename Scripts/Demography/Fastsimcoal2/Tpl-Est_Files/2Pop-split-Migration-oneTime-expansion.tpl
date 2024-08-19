//Parameters for the coalescence simulation program : fastsimcoal.exe
2 samples to simulate :
//Population effective sizes (number of genes)
NATIVE$
INDIA$
//Samples sizes and samples age 
26
22
//Growth rates	: negative growth implies population expansion
0
R1
//Number of migration matrices : 0 implies no migration between demes
2
//Migration matrix 0
0.000 0.000
0.000 0.000
//Migration matrix 1
0.000 MIG12
MIG21 0.000
//historical event: time, source, sink, migrants, new deme size, new growth rate, migration matrix index
3 historical event
TEND$ 1 1 1 1 0 1
TSTART$ 1 1 1 1 0 0
TDIV$ 1 0 1 RESIZE 0 0
//Number of independent loci [chromosome] 
1 0
//Per chromosome: Number of contiguous linkage Block: a block is a set of contiguous loci
1
//per Block:data type, number of loci, per generation recombination and mutation rates and optional parameters
FREQ 1 0 7e-9 OUTEXP

