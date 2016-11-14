if [[ "$@" =~ "--debug" ]]; then
	set -ex
else
	set -e
fi

for i in "$@"
do
	case $i in
	"--cfile")
		cfileband=1
		invalidband=0
		selection=0

	;;
	"--help")
	invalidband=0
		echo "#########################################################################################"
		echo -e "\nUsage: bash simulationMethods --cfile [config file]"
		echo -e "\nOptions aviable for config file:"
		echo "GENOMESIZEBALANCE is the type of genome, for example 'B' for bacteria, 'V' for virus, etc."

		echo -e "\n#########################################################################################"
		exit
	;;
	*)
		
		if [ $((cfileband)) -eq 1 ];then

			if ! [ -f $i ];then
				echo "$i file no exist"
				exit
			fi

			for parameter in `awk '{print}' $i`
			do
				Pname=`echo "$parameter" |awk 'BEGIN{FS="="}{print $1}'`		
				case $Pname in
					"SEPAHOME")
						SEPAHOME=$(echo "$parameter" | awk 'BEGIN{FS="="}{print $2}' | sed "s/,/ /g")
					;;
					"GENOMESIZEBALANCE")
						GENOMESIZEBALANCE=$(echo "$parameter" | awk 'BEGIN{FS="="}{print $2}' | sed "s/,/ /g")
					;;
					"BEGIN_FOLDER")
						BEGIN_FOLDER=$(echo "$parameter" | awk 'BEGIN{FS="="}{print $2}' | sed "s/,/ /g")				
					;;
					"SPECIES")
						SPECIES=$(echo "$parameter" | awk 'BEGIN{FS="="}{print $2}' | sed "s/,/ /g")				
					;;
					"DEEPSEQUENCE")
						ABUNDANCE=$(echo "$parameter" | awk 'BEGIN{FS="="}{print $2}' | sed "s/,/ /g")					
					;;
					"DOMINANCE")
						DOMINANCE=$(echo "$parameter" | awk 'BEGIN{FS="="}{print $2}' | sed "s/,/ /g")					
					;;
					"READSIZE")
						READSIZE=$(echo "$parameter" | awk 'BEGIN{FS="="}{print $2}' | sed "s/,/ /g")					
					;;
					"METHOD")
						METHOD=$(echo "$parameter" | awk 'BEGIN{FS="="}{print $2}' | sed "s/,/ /g")				
					;;
					"THREADS")
						THREADS=$(echo "$parameter" | awk 'BEGIN{FS="="}{print $2}' | sed "s/,/ /g")			
					;;
					"GENOME_DB")
						GENOME_DB=$(echo "$parameter" | awk 'BEGIN{FS="="}{print $2}' | sed "s/,/ /g")	
					;;
					"METASIMFOLDER")
						METASIMFOLDER=$(echo "$parameter" | awk 'BEGIN{FS="="}{print $2}' | sed "s/,/ /g")
					;;
					"PERMANENT")
						PERMANENT=$(echo "$parameter" | awk 'BEGIN{FS="="}{print $2}' | sed "s/,/ /g")
					;;
				esac
			done
			
			statusband=$((statusband+1))
			cfileband=0

			if [ "$GENOME_DB" == "" ];then
				echo "no GENOME_DB was spcified"
				exit
			else
				GDB=`echo "$GENOME_DB" |rev |cut -d "/" -f 1 |rev`
				GDBDIR=`echo "$GENOME_DB" |rev |cut -d "/" -f 2- |rev`
				cd $GDBDIR
				dbpath=`pwd`
				GENOME_DB=`echo "$dbpath/$GDB"`
				cd $OLDPWD
			fi

			if [ ! -d "$METASIMFOLDER" ];then
				echo "METASIMFOLDER no exist, impossible to continue"
				exit
			fi
		fi

	;;
	esac
done


################################################################
################################################################
if [ -d $BEGIN_FOLDER ]; then
	cd $BEGIN_FOLDER
else
	echo "$BEGIN_FOLDER no exist, impossible to continue"
	exit
fi


for a in $GENOMESIZEBALANCE
do

	if [ -d $a ]; then
		cd $a
		echo "----Organism: $a"
		if [ -f fasta_0.fasta ]; then
			echo "Fastas here, continue"
			selection=1
		else
			echo "Spliting $GENOME_DB"
			awk -f ${SEPAHOME}/Modules/scripts/splitmultifasta.awk $GENOME_DB  #one fasta per entry wil be generate.
		fi
	else
		mkdir $a
		cd $a
		echo "Spliting $GENOME_DB" 
	
		awk -f ${SEPAHOME}/Modules/scripts/splitmultifasta.awk $GENOME_DB  #a lot of fastas wil be generate.

	fi
	
	echo "GBalance $a" 
	echo "DB: $GENOME_DB"

		for c in $SPECIES
		do
			echo "------Species: $c" 
			total=`ls -1 *.fasta |wc -l |awk '{if($1<0){print "no fastas"}else{print $1}}'` #-1= less species folder
			if [ $((total)) -le 0  ];then
				echo "no fastas for selection"
				exit
			fi

			if [ -d species_$c ]; then
				cd species_$c
				if [ $((selection)) -eq 1 ];then
					mv ../*.fasta .
				fi
			else
				mkdir species_$c
				cd species_$c
				echo "------Calling subpipe SpecieSelection"
				
				if [ $((total)) -le $((c))  ]; then
					bash ${SEPAHOME}/Modules/scripts/SpecieSelection.bash "${SEPAHOME}" "$GENOME_DB" "$PERMANENT" "$total"
				else
					#bash ${SEPAHOME}/Modules/scripts/SpecieSelection.bash "${SEPAHOME}" "$GENOME_DB" "$PERMANENT" "$c"
					mv ../*.fasta .
				fi
				
			fi

			for d in $ABUNDANCE
			do
				echo "---------Abundance: $d" 
				if [ -d abundance_$d ]; then
					cd abundance_$d
				else
					mkdir abundance_$d
					cd abundance_$d
					mv ../*.fasta .
				fi

				for e in $DOMINANCE
				do
					echo "------------Dominance: $e" 
					if [ -d dominance_$e ]; then
						cd dominance_$e
					else
						mkdir dominance_$e
						cd dominance_$e
						mv ../*.fasta .
						gipermanent=`head -n1 fasta_$PERMANENT.fasta | awk -F"gi[|]" '{print $2}' |awk -F"[|]" '{print $1}'`
						bash ${SEPAHOME}/Modules/scripts/DomainDistribution.bash "$SEPAHOME" "$c" "$d" "$e" "$gipermanent"
						for rsize in $READSIZE
						do
							echo "dataset_A$d""_R$rsize	$d	$rsize	popu$c""Abun$d""Dom$e.mprf" >> metasim_simulation_table
						done

						echo "------------execute metasim scripts" 

						bash ${SEPAHOME}/Modules/scripts/Metasim.sh "$THREADS" "$METASIMFOLDER" metasim_simulation_table
						bash ${SEPAHOME}/Modules/scripts/SplitMetasimPairs.sh "${SEPAHOME}"
						for rsize in $READSIZE
						do
							rm dataset_A$d""_R$rsize/*.fa.gz #to save disk space
						done


					fi

				mv *.fasta ../.				
				cd ..
				done #done e

			mv *.fasta ../.
			cd ..
			done #done d

		mv *.fasta ../.
		cd ..		
		done #done c

cd ..
done #done a

cd ..
