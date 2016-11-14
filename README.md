![banner](https://raw.githubusercontent.com/microgenomics/tutorials/master/img/microgenomics.png)

#simulationsMethods
--------------------

##Usage
* Bash >= v4 (tested in Linux)
* [Metasim](http://ab.inf.uni-tuebingen.de/software/metasim/) with desired genomes

##Usage

	bash simulationsMethods.bash --cfile [config file]

##Configuration file
This file contain several parameters to steer the script:

	SEPAHOME=/Users/castrolab04/Desktop/SEPA
	BEGIN_FOLDER=Simulation
	GENOMESIZEBALANCE=B
	SPECIES=10	#this means that the program take 10 fastas randomly to make the simulation 
	DEEPSEQUENCE=100000
	DOMINANCE=10
	READSIZE=75,150,300,1000
	PERMAMENT=35
	GENOME_DB=/Users/castrolab04/DB/mydb.fasta
	METASIMFOLDER=/Users/castrolab04/programs/metasim
	THREADS=16
	
where:

* SEPAHOME is the folder where is SEPA.
* BEGIN_FOLDER is the initial folder to do the simulations, the folder must exist.
* GENOMESIZEBALANCE is to specify the type of your DB (B,V,F means bacteria, virus and fungi), you can combine the types tipying BV,VF or BVF.
* SPECIES is the number of species to take randomly
* DEEPSEQUENCE is the X deep to simulate like a sequencer
* DOMINANCE is the % on the number of genomes that takes the majority of reads:
	* 1 -> one genome take 50% of the reads.
	* 10 -> 10% of species takes the 25% of the reads.
	* 50 -> 50% of species takes the 80% of the reads.
	* 100 -> all species have equal reads abundance.
* READSIZE is the size of the simulated read (75,150,300 or 1000). Note: no error sustitution are considered.
* PERMAMENT is the fasta with X number that always be in the selections SPECIES, for example, in your db there are 10 genomes (that means you have 10 fastas concatenated), and you want the genome 7, so, you just put PERMAMENT=7.
* GENOME_DB is the path (and file), of your genomes DB, this DB will splited into individual fastas (that fastas will be in metasim).
* METASIMFOLDER is the folder of Metasim.sh is.
* THREADS is the number of threads for metasim
