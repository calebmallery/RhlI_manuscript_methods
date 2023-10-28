These are the commands issued and some rationale behind the RhlI orthologue tree.

Firstly, I downloaded all orthologous sequences identified by [OrthoDB](https://www.orthodb.org/?query=208964_0:0003c9)
from all bacterial groups. This search yielded 709 genes across 607 species. To exclude potential false-positive hits/not well charactarized proteins, only sequences annotated as having the following InterPro domains were chosen:
  - IPR001690: Autoinducer synthase
  - IPR016181: Acyl-CoA N-acyltransferase
  - IPR018311: Autoinducer synthesis, conserved site

The raw fasta file downloaded from OrthoDB `rhli_orthologues.faa` has a lot of junk in the headers that are bad for downstream programs.
To get rid of these strange characters and conserve only the ">" and the species name, I used a variety of regular expressions with some examples listed below where the top-line is the search input and bottom-line is the replacement:

Step 1: search for the info before the species name.

	^>[^\s]+\s{"pub_og_id":"(.*?)","(.*)","(.*?)":2,"(.*?)":"(.*?)","(.*?)":"
	>
> Note: at this point, all 709 genes should have the ">" character, a species name, and other info we are still not intereested in.

Step 2: search for the "]" "[" characters at the begining of some species names

	[[][]]
 
Step 3: get rid of the rest of the junk behind the species name

	","(.*?)":"(.*?)","(.*?)":"(.*?)"[}]
> Note: For all of the above, I am sure this could be streamlined into one line. This was just the quickest/simplest solution I could come to at the time.

There are still some weird characters that are not tolerated by downstream programs. These can be removed with some succesive sed commands:

	sed 's/_=_/_/g' rhlI_orthologues.faa > rhlI_orthologues_filtered.faa | grep "=" rhlI_orthologues_filtered.faa 
	sed -i 's/[/]/-/g' rhlI_orthologues_filtered.faa 
	sed -i 's/-/_/g' rhlI_orthologues_filtered.faa 
> Note: '**-i**' in the second and specifies to make the following changes in place. It is best to use this option only if you are sure the changes you are making are exactly what you want. An alternative to check this is given as the first example
 
Additionally we wanted to exclude seqeunces that were considerably larger/smaller than our querry sequences (PA14 RhlI is 201 AA) and remove duplicates.

	seqkit seq -m 195 -M 215 -g rhlI_orthologues_filtered.faa > rhlI_filtered_orthologues.faa
	seqkit rmdup -n rhlI_filtered_orthologues.faa -o rhlI_filtered_uniq_orthologues.faa
> Note: '**-m**' specifies the minimum AA threshold, '**-M**' specifies the maximum AA threshold, '**-g**' specifies something else.

Now that we have our filtered sequences, we can align [MUSCLE](https://www.drive5.com/muscle/) and trim [trimAl](http://trimal.cgenomics.org/trimal) them.

	muscle -in rhlI_filtered_uniq_orthologues.faa -out rhlI_filtered_uniq_aln.faa -maxiters 3
> Note: The '**-maxiters**' is set to 3 to specify how many iterations of [MUSCLE](https://www.drive5.com/muscle/) to run.

	trimal -in rhlI_filtered_uniq_aln.faa -out rhlI_filt_uniq_aln_trm.faa -keepheader -gt 0.8 -st 0.001 -cons 60
> Note: The '**-keepheader**' option sepcifies to keep headers, I've had unfortunate times with trimal stealing my headers without
> this flag. '**-gt 0.8**' specifies, '**-st 0.001**' specfies , and '**-cons 60**' specifiees.

To generate the tree used in figure SX:
	
 	iqtree -s rhlI_filt_uniq_aln_trm.faa -bb 1000 -m AUTO
