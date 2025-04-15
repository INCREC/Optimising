#!/bin/bash

EXEGPT="python gpt_translation.py"
IF="./inputs/2BR02B.en"

export OPENAIKEY="INSERT YOUR OPENAI KEY HERE"


1a() {
	MODE="sentences"
	for TL in ca es nl zh; do
		OF="2BR02B.$FUNCNAME.$TL"
		echo $TL $OF
		time $EXEGPT $IF $OF $TL $MODE > $OF.log 2>&1
	done
}


1b() {
	MODE="all"
#	for TL in ca es nl zh; do
#	for TL in nl; do # it initially refused to translate the text (It worked the 2nd time)
		OF="2BR02B.$FUNCNAME.$TL"
		echo $TL $OF
		time $EXEGPT $IF $OF $TL $MODE > $OF.log 2>&1
	done
}


2() {
	MODE="sentences"
	for TL in nl zh; do
		for TEMPERATURE in 0 1; do #0.5 1.1 1.2 1.5; do #1.1 1.2; do # 0.5 0.75 1 1.25 1.5; do
			OF="2BR02B.p$FUNCNAME.t$TEMPERATURE.$TL"
			echo $TL $OF
			time $EXEGPT $IF $OF $TL $MODE $TEMPERATURE > $OF.log 2>&1
		done
	done

	MODE="all"
	for TEMPERATURE in 0 1; do # 0.5 0.75 1 1.1 1.2 1.25 1.5; do
		for TL in ca es; do
			OF="2BR02B.p$FUNCNAME.t$TEMPERATURE.$TL"
			echo $TL $OF
			time $EXEGPT $IF $OF $TL $MODE $TEMPERATURE > $OF.log 2>&1
		done
	done
}


3() {
	MODE="sentences"
	TEMPERATURE=1
	for TL in nl zh; do
		for PROMPTN in 2 3; do
			OF="2BR02B.p$FUNCNAME.t$TEMPERATURE.p$PROMPTN.$TL"
			echo $TL $OF
			time $EXEGPT $IF $OF $TL $MODE $TEMPERATURE $PROMPTN > $OF.log 2>&1
		done
	done

	MODE="all"
	TEMPERATURE=0
	TL=ca
	for PROMPTN in 2 3; do
		OF="2BR02B.p$FUNCNAME.t$TEMPERATURE.p$PROMPTN.$TL"
		echo $TL $OF
		time $EXEGPT $IF $OF $TL $MODE $TEMPERATURE $PROMPTN > $OF.log 2>&1
	done

	TEMPERATURE=1
	TL=es
	for PROMPTN in 2 3; do
		OF="2BR02B.p$FUNCNAME.t$TEMPERATURE.p$PROMPTN.$TL"
		echo $TL $OF
		time $EXEGPT $IF $OF $TL $MODE $TEMPERATURE $PROMPTN > $OF.log 2>&1
	done

}


3_rename_files() {
	cd outputs_phase3/sent_to_annotators

	cp ../2BR02B.p3.t0.p2.ca 2BR02B.3a.ca
	cp ../2BR02B.p3.t0.p3.ca 2BR02B.3b.ca
	cp ../softcatala_enca_20250114.ca 2BR02B.3c.ca
	
	cp ../2BR02B.p3.t1.p2.es 2BR02B.3a.es
	cp ../2BR02B.p3.t1.p3.es 2BR02B.3b.es
	cp ../deepl_enes_20250114.es 2BR02B.3c.es
	
	cp ../2BR02B.p3.t1.p2.nl 2BR02B.3a.nl
	cp ../2BR02B.p3.t1.p3.nl 2BR02B.3b.nl
	cp ../deepl_ennl_20250114.nl 2BR02B.3c.nl
	
	cp ../2BR02B.p3.t1.p2.zh 2BR02B.3a.zh
	cp ../2BR02B.p3.t1.p3.zh 2BR02B.3b.zh
	cp ../deepl_enzh_20250114.zh 2BR02B.3c.zh

}


# prepare the files for automatic evaluation
# i.e. remove empty lines so that all have the same number of lines (125).
# Note: additional manual post-processing has been previously done to remove e.g. text not relevant added by the MT system, such as "Here is the Dutch translation of the text you provided:"

prep_for_auto_eval() {
	cd inputs
	sed '/^[[:space:]]*$/d' 2BR02B.en > 2BR02B.en.noemptylines
	
	cd ../outputs_phase1/for_AEMs/
	for i in *withemptylines; do echo $i; grep -v "^$" $i > $i.noemptylines; done
	
	cd ../outputs_phase2/for_AEMs/
	for i in *withemptylines; do echo $i; grep -v "^$" $i > $i.noemptylines; done
	
	cd ../outputs_phase3/for_AEMs/
	for i in *withemptylines; do echo $i; grep -v "^$" $i > $i.noemptylines; done
	
	# files $i.noemptylines subsequently renamed to $i
}



auto_eval_sacrebleu() {
	# phase1
	DIR=outputs_phase1
	echo $DIR
	
	for SYS in 1a 1b; do
		echo $SYS
		sacrebleu refs/2BR02B_CA_HT_final.forAEMs -i $DIR/for_AEMs/2BR02B.$SYS.ca -m bleu chrf ter > AEMs/$SYS.ca.sb
		sacrebleu refs/2BR02B_ES_HT_final.forAEMs -i $DIR/for_AEMs/2BR02B.$SYS.es -m bleu chrf ter > AEMs/$SYS.es.sb
		sacrebleu refs/2BR02B_NL_HT_final.forAEMs -i $DIR/for_AEMs/2BR02B.$SYS.nl -m bleu chrf ter > AEMs/$SYS.nl.sb
	done	


	# phase2
	DIR=outputs_phase2
	echo $DIR
	
	for SYS in 2a 2b; do
		echo $SYS
		sacrebleu refs/2BR02B_CA_HT_final.forAEMs -i $DIR/for_AEMs/2BR02B.$SYS.ca -m bleu chrf ter > AEMs/$SYS.ca.sb
		sacrebleu refs/2BR02B_ES_HT_final.forAEMs -i $DIR/for_AEMs/2BR02B.$SYS.es -m bleu chrf ter > AEMs/$SYS.es.sb
		sacrebleu refs/2BR02B_NL_HT_final.forAEMs -i $DIR/for_AEMs/2BR02B.$SYS.nl -m bleu chrf ter > AEMs/$SYS.nl.sb
	done
	

	# phase3
	DIR=outputs_phase3
	echo $DIR
	
	for SYS in 3a 3b 3c; do
		echo $SYS
		sacrebleu refs/2BR02B_CA_HT_final.forAEMs -i $DIR/for_AEMs/2BR02B.$SYS.ca -m bleu chrf ter > AEMs/$SYS.ca.sb
		sacrebleu refs/2BR02B_ES_HT_final.forAEMs -i $DIR/for_AEMs/2BR02B.$SYS.es -m bleu chrf ter > AEMs/$SYS.es.sb
		sacrebleu refs/2BR02B_NL_HT_final.forAEMs -i $DIR/for_AEMs/2BR02B.$SYS.nl -m bleu chrf ter > AEMs/$SYS.nl.sb
	done
	
	sacrebleu refs/2BR02B_CA_HT_final.forAEMs -i $DIR/for_AEMs/2BR02B.3d.ca -m bleu chrf ter > AEMs/3d.ca.sb
}


auto_eval_comet() {
	M=$1
	MODEL=Unbabel/$M
	SRC=inputs/2BR02B.noemptylines.en.forAEMs
	REFCA=refs/2BR02B_CA_HT_final.forAEMs
	REFES=refs/2BR02B_ES_HT_final.forAEMs
	REFNL=refs/2BR02B_NL_HT_final.forAEMs
	
	echo $MODEL

	
	DIR=outputs_phase1
	echo $DIR
	for SYS in 1a 1b; do
		echo $SYS
		time comet-score -s $SRC -r $REFCA -t $DIR/for_AEMs/2BR02B.$SYS.ca --model $MODEL > AEMs/$M.$SYS.ca.sb
		time comet-score -s $SRC -r $REFES -t $DIR/for_AEMs/2BR02B.$SYS.es --model $MODEL > AEMs/$M.$SYS.es.sb
		time comet-score -s $SRC -r $REFNL -t $DIR/for_AEMs/2BR02B.$SYS.nl --model $MODEL > AEMs/$M.$SYS.nl.sb		
	done
	
	DIR=outputs_phase2
	echo $DIR
	for SYS in 2a 2b; do
		echo $SYS
		time comet-score -s $SRC -r $REFCA -t $DIR/for_AEMs/2BR02B.$SYS.ca --model $MODEL > AEMs/$M.$SYS.ca.sb
		time comet-score -s $SRC -r $REFES -t $DIR/for_AEMs/2BR02B.$SYS.es --model $MODEL > AEMs/$M.$SYS.es.sb
		time comet-score -s $SRC -r $REFNL -t $DIR/for_AEMs/2BR02B.$SYS.nl --model $MODEL > AEMs/$M.$SYS.nl.sb		
	done
	
	DIR=outputs_phase3
	echo $DIR
	for SYS in 3a 3b 3c; do
		echo $SYS
		time comet-score -s $SRC -r $REFCA -t $DIR/for_AEMs/2BR02B.$SYS.ca --model $MODEL > AEMs/$M.$SYS.ca.sb
		time comet-score -s $SRC -r $REFES -t $DIR/for_AEMs/2BR02B.$SYS.es --model $MODEL > AEMs/$M.$SYS.es.sb
		time comet-score -s $SRC -r $REFNL -t $DIR/for_AEMs/2BR02B.$SYS.nl --model $MODEL > AEMs/$M.$SYS.nl.sb		
	done
	
	time comet-score -s $SRC -r $REFCA -t $DIR/for_AEMs/2BR02B.3d.ca --model $MODEL > AEMs/$M.3d.ca.sb

}


auto_eval_comet_noref() {
	M=$1
	MODEL=Unbabel/$M
	SRC=inputs/2BR02B.noemptylines.en.forAEMs
	
	echo $MODEL

	
	DIR=outputs_phase1
	echo $DIR
	for SYS in 1a 1b; do
		for L in zh ca es nl zh; do
			echo $SYS
			time comet-score -s $SRC -t $DIR/for_AEMs/2BR02B.$SYS.$L --model $MODEL > AEMs/$M.$SYS.$L
		done
	done
	
	DIR=outputs_phase2
	echo $DIR
	for SYS in 2a 2b; do
		for L in zh ca es nl zh; do
			echo $SYS
			time comet-score -s $SRC -t $DIR/for_AEMs/2BR02B.$SYS.$L --model $MODEL > AEMs/$M.$SYS.$L
		done
	done
	
	DIR=outputs_phase3
	echo $DIR
	for SYS in 3a 3b 3c; do
		for L in zh ca es nl zh; do
			echo $SYS
			time comet-score -s $SRC -t $DIR/for_AEMs/2BR02B.$SYS.$L --model $MODEL > AEMs/$M.$SYS.$L
		done
	done
	
	time comet-score -s $SRC -t $DIR/for_AEMs/2BR02B.3d.ca --model $MODEL > AEMs/$M.3d.ca

}


auto_eval_ter() {
	TERCOM="java -jar $HOME/software/tercom-0.7.25/tercom.7.25.jar"
	
	# prep for TER
	for F in refs/*.forAEMs outputs_phase?/for_AEMs/*.??; do
		echo $F
		awk '{print $0 " (" NR ")"}' < $F > $F.forTER
	done
	
	
	cd AEMs/
		
	DIR=outputs_phase1
	echo $DIR
	for SYS in 1a 1b; do
		echo $SYS
		$TERCOM -h ../$REFCA -r ../$DIR/for_AEMs/2BR02B.$SYS.ca.forTER -n TER.2BR02B.$SYS.ca > TER.2BR02B.$SYS.ca
		$TERCOM -h ../$REFES -r ../$DIR/for_AEMs/2BR02B.$SYS.es.forTER -n TER.2BR02B.$SYS.es > TER.2BR02B.$SYS.es
		$TERCOM -h ../$REFNL -r ../$DIR/for_AEMs/2BR02B.$SYS.nl.forTER -n TER.2BR02B.$SYS.nl > TER.2BR02B.$SYS.nl
	done

	DIR=outputs_phase2
	echo $DIR
	for SYS in 2a 2b; do
		echo $SYS
		$TERCOM -h ../$REFCA -r ../$DIR/for_AEMs/2BR02B.$SYS.ca.forTER -n TER.2BR02B.$SYS.ca > TER.2BR02B.$SYS.ca
		$TERCOM -h ../$REFES -r ../$DIR/for_AEMs/2BR02B.$SYS.es.forTER -n TER.2BR02B.$SYS.es > TER.2BR02B.$SYS.es
		$TERCOM -h ../$REFNL -r ../$DIR/for_AEMs/2BR02B.$SYS.nl.forTER -n TER.2BR02B.$SYS.nl > TER.2BR02B.$SYS.nl
	done

	DIR=outputs_phase3
	echo $DIR
	for SYS in 3a 3b 3c; do
		echo $SYS
		$TERCOM -h ../$REFCA -r ../$DIR/for_AEMs/2BR02B.$SYS.ca.forTER -n TER.2BR02B.$SYS.ca > TER.2BR02B.$SYS.ca
		$TERCOM -h ../$REFES -r ../$DIR/for_AEMs/2BR02B.$SYS.es.forTER -n TER.2BR02B.$SYS.es > TER.2BR02B.$SYS.es
		$TERCOM -h ../$REFNL -r ../$DIR/for_AEMs/2BR02B.$SYS.nl.forTER -n TER.2BR02B.$SYS.nl > TER.2BR02B.$SYS.nl
	done

	SYS=3d
	echo $SYS
	$TERCOM -h ../$REFCA -r ../$DIR/for_AEMs/2BR02B.$SYS.ca.forTER -n TER.2BR02B.$SYS.ca > TER.2BR02B.$SYS.ca


	cd ..
	

	
	# remove the temporary files created to compute TER
	rm refs/*.forAEMs.forTER outputs_phase?/for_AEMs/*.??.forTER
}


# get translations with OpenAI's API
1a
1b
2
3
3_rename_files

# automatic evaluation
prep_for_auto_eval
auto_eval_sacrebleu
auto_eval_comet wmt22-comet-da
auto_eval_comet_noref wmt22-cometkiwi-da
auto_eval_ter

