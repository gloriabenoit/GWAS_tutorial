
# Explanation of the main script 

This is the main script for second tutorial from our comprehensive tutorial on GWAS and PRS. To run this script the following (b)files from the first tutorial are required: *HapMap_3_r3_12* (this bfile contains *HapMap_3_r3_12.fam*, *HapMap_3_r3_12.bim* and *HapMap_3_r3_12.bed*; you need all three), and *indepSNP.prune.in*.

In this tutorial we are going to check for population stratification.
We will do this as follows, the bfile (*HapMap_3_r3_12*) generated at the end of the previous tutorial (*1_QC_GWAS*) is going to be checked for population stratification using data from the 1000 Genomes Project. Individuals with a non-European ethnic background will be removed.

Furthermore, this tutorial will generate a covariate file which helps to adust for remaining population stratification within the European subjects.
In order to complete this tutorial it is necessary to have generated the bfile *HapMap_3_r3_12* and the file *indepSNP.prune.in* from the previous tutorial.

> My additions to the original tutorials are signaled by the use of the blockquote.
>
> Most commands were updated to work for PLINK 2.0 using multiple ressources such as file format references ([1.9](https://www.cog-genomics.org/plink/1.9/formats) vs [2.0](https://www.cog-genomics.org/plink/2.0/formats)) and [PLINK official doc](https://plink.readthedocs.io/en/latest/GWAS/). R scripts were also updated so that everything runs smoothly. In the tutorials, a command starting with `plink2` references PLINK 2.0, while one starting with `plink` references the original command used.
>
> When command architecture varies between PLINK 1.07 and PLINK 2.0, the `plink` command is commented and is before the `plink2` one.

---

# Start of analysis

> While the original tutorial used to perform an MDS, we choose to perform a PCA seeing as MDS are not implemented in PLINK 2.0.

# Download 1000 Genomes data
This file from the 1000 Genomes contains genetic data of 629 individuals from different ethnic backgrounds.

Note, this file is quite large (>60 gigabyte). 
```bash 
wget ftp://ftp-trace.ncbi.nih.gov/1000genomes/ftp/release/20100804/ALL.2of4intersection.20100804.genotypes.vcf.gz
```

In order to use this file, we first need to convert it to Plink format.
> The file contains multiallelic variants, which cannot be stored in a *.bim*.We need to add the `--max-alleles 2` option in order to avoid an error.
```bash
# plink --vcf ALL.2of4intersection.20100804.genotypes.vcf.gz --make-bed --out ALL.2of4intersection.20100804.genotypes
plink2 --vcf ALL.2of4intersection.20100804.genotypes.vcf.gz --real-ref-alleles --max-alleles 2 --make-bed --out ALL.2of4intersection.20100804.genotypes
```
Noteworthy, the file *ALL.2of4intersection.20100804.genotypes.bim* contains SNPs without an rs-identifier, these SNPs are indicated with '.'. This can also be observed in the file *ALL.2of4intersection.20100804.genotypes.vcf.gz*. To check this file use the command `zmore ALL.2of4intersection.20100804.genotypes.vcf.gz`.

The missing rs-identifiers in the 1000 Genomes data are not a problem for this tutorial. However, for good practice, we will assign unique indentifiers to the SNPs with a missing rs-identifier (i.e., the SNPs with '.').
```text
plink2 --bfile ALL.2of4intersection.20100804.genotypes --set-missing-var-ids @:#[b37]\$r,\$a --make-bed --out ALL.2of4intersection.20100804.genotypes_no_missing_IDs
```

# QC on 1000 Genomes data
Like in the previous tutorial, we need to apply quality control procedures.

## Missingness

Remove variants and individuals based on missing genotype data.
```bash
plink2 --bfile ALL.2of4intersection.20100804.genotypes_no_missing_IDs --geno 0.2 --make-bed --out 1kG_PCA
plink2 --bfile 1kG_PCA --mind 0.2 --make-bed --out 1kG_PCA2
plink2 --bfile 1kG_PCA2 --geno 0.02 --make-bed --out 1kG_PCA3
plink2 --bfile 1kG_PCA3 --mind 0.02 --make-bed --out 1kG_PCA4
```
## MAF

Remove variants based on MAF.
```bash
plink2 --bfile 1kG_PCA4 --maf 0.05 --make-bed --out 1kG_PCA5
```

# Update 1000 Genomes data
## Same variants

We first want to extract the variants present in HapMap dataset from the 1000 genomes dataset.
```bash
awk '{print$2}' HapMap_3_r3_12.bim > HapMap_SNPs.txt
```
> output: *HapMap_SNPs.txt", which shows all variants found in HapMap data.
```bash
plink2 --bfile 1kG_PCA5 --extract HapMap_SNPs.txt --make-bed --out 1kG_PCA6
```

Then we can extract the variants present in 1000 Genomes dataset from the HapMap dataset.
```bash
awk '{print$2}' 1kG_PCA6.bim > 1kG_PCA6_SNPs.txt
```
> output: *1kG_PCA6_SNPs.txt*, which shows all variants found in 1000 Genomes data.
```bash
# plink --bfile HapMap_3_r3_12 --extract 1kG_MDS6_SNPs.txt --recode --make-bed --out HapMap_MDS
plink2 --bfile HapMap_3_r3_12 --extract 1kG_PCA6_SNPs.txt --recode vcf --make-bed --out HapMap_PCA
```
> The `--recode` option was used to create a .map file, but is now deprecated. We choose to build a .vcf file instead.

The datasets now contain the exact same variants, but they need to have the same build.

## Same build

We want to make sure that the 1000 Genomes dataset and the HapMap dataset have the same build, in order to later merge them.
> We used to keep variant identifier and base-pair coordinate ($2 and $4 in the .map file), in order to save the same values in our .vcf file, we need to keep $3 and $2 in this order.
```bash
# awk '{print$2,$4}' HapMap_MDS.map > buildhapmap.txt
awk '!/#/ {print$3,$2}' HapMap_PCA.vcf > buildhapmap.txt
```
> output: *buildhapmap.txt*, which shows one SNP-id and physical position per line.

```bash
plink2 --bfile 1kG_PCA6 --update-map buildhapmap.txt --make-bed --out 1kG_PCA7
```
1kG_PCA7 and HapMap_PCA now have the same build.

# Prepare for merge

Prior to merging 1000 Genomes data with the HapMap data we want to make sure that the files are mergeable, for this we conduct 3 steps:
1. Make sure the reference genome is similar in the HapMap and the 1000 Genomes Project datasets.
2. Resolve strand issues.
3. Remove the SNPs which after the previous two steps still differ between datasets.

The following steps are maybe quite technical in terms of commands, but we just compare the two data sets and make sure they correspond.

## Set reference genome 
```bash
# awk '{print$2,$5}' 1kG_MDS7.bim > 1kg_ref-list.txt
awk '{print$2,$6}' 1kG_PCA7.bim > 1kg_ref-list.txt
```
> output: *1kg_ref-list.txt*, which shows all reference alleles in 1000 Genomes data.
```bash
# plink --bfile HapMap_MDS --reference-allele 1kg_ref-list.txt --make-bed --out HapMap-adj
plink2 --bfile HapMap_PCA --ref-allele 1kg_ref-list.txt --make-bed --out HapMap-adj
```
The 1kG_PCA7 and the HapMap-adj have the same reference genome for all SNPs.

## Resolve strand issues
We check for potential strand issues.
```bash
awk '{print$2,$5,$6}' 1kG_PCA7.bim > 1kGPCA7_tmp
awk '{print$2,$5,$6}' HapMap-adj.bim > HapMap-adj_tmp
sort 1kGPCA7_tmp HapMap-adj_tmp |uniq -u > all_differences.txt
```
> output: *1kGPCA7_tmp*, *HapMap-adj_tmp* and *all_differences.txt*, these files show respectively variants found in 1000 Genomes data, variants found in HapMap data and variants which are different between the two datasets.

There are 1624 differences between the files, some of these might be due to strand issues.

To identify SNPs, we need to remove duplicates.
```bash
awk '{print$1}' all_differences.txt | sort -u > flip_list.txt
```
> output: *flip_list.txt*, which shows all unique variants which are different between the two datasets.

This command generates a file of 812 SNPs. These are the non-corresponding SNPs between the two files.

Now we can flip the 812 non-corresponding SNPs.
> Sadly flip is no longer supported in PLINK 2.0, so in order to do this you need to use PLINK 1.9.
```bash
plink --bfile HapMap-adj --flip flip_list.txt --keep-allele-order --make-bed --out corrected_hapmap_step1
```
> We now need to reassign the correct reference alleles.
```bash
plink2 --bfile corrected_hapmap_step1 --ref-allele 1kg_ref-list.txt --make-bed --out corrected_hapmap
```

We can check for SNPs which are still problematic after they have been flipped.
```bash
awk '{print$2,$5,$6}' corrected_hapmap.bim > corrected_hapmap_tmp
sort 1kGPCA7_tmp corrected_hapmap_tmp |uniq -u  > uncorresponding_SNPs.txt
```
> output: *corrected_hapmap_tmp* and *uncorresponding_SNPs.txt*, these files show respectively variants found in corrected HapMap data and variant which still differ between the two datasets.

This file demonstrates that there are 84 differences between the files.

## Remove problematic SNPs
```bash
awk '{print$1}' uncorresponding_SNPs.txt | sort -u > SNPs_for_exclusion.txt
```
> output: *SNPs_for_exclusion.txt*, which shows all unique variants which are still different between the two datasets.

The command above generates a list of the 42 SNPs which caused the 84 differences between the HapMap and the 1000 Genomes data sets after flipping and setting of the reference genome.

These 42 problematic SNPs need to be removed from both datasets.
```bash
plink2 --bfile corrected_hapmap --exclude SNPs_for_exclusion.txt --make-bed --out HapMap_PCA2
```
> When excluding SNP from 1000 Genomes dataset, variants are no longer sorted by position. Therefore we must first sort it using a .pgen file.
```bash
plink2 --bfile 1kG_PCA7 --exclude SNPs_for_exclusion.txt --sort-vars --make-pgen --out 1kG_PCA8
```
> output: *1kG_PCA8.pgen*, *1kG_PCA8.pvar* and *1kG_PCA8.psam*, these files correspond respectively to *.bed*, *.bim* and *.fam* files.
```bash
plink2 --pfile 1kG_PCA8 --make-bed --out 1kG_PCA8
```

# Merge HapMap with 1000 Genomes Data
> The merge function is under development in PLINK 2.0 therefore we use PLINK 1.9.
```bash
plink --bfile HapMap_PCA2 --bmerge 1kG_PCA8.bed 1kG_PCA8.bim 1kG_PCA8.fam --allow-no-sex --make-bed --out PCA_merge
```
Note, we are fully aware of the sample overlap between the HapMap and 1000 Genomes datasets. However, for the purpose of this tutorial this is not important.

# Perform PCA on HapMap-CEU data anchored by 1000 Genomes data
> The MDS commands can be found on the original tutorial.

We are using a set of pruned SNPs, obtained from the previous tutorial.
```bash
plink2 --bfile PCA_merge --extract indepSNP.prune.in --pca 10 --out PCA_merge2
```
> output: *PCA_merge2.eigenval* and *PCA_merge2.eigenvec*, these files show respectively one eigen value per line and all components computed.

## PCA-plot

In order to correctly annotate our graph, we need to download the file with population information of the 1000 genomes dataset.
```bash
wget ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/release/20100804/20100804.ALL.panel
```
The file *20100804.ALL.panel* contains population codes of the individuals of 1000 genomes. 

These codes need to be converted into superpopulation codes (i.e., AFR,AMR,ASN, and EUR):
```bash
awk '{print$1,$1,$2}' 20100804.ALL.panel > race_1kG.txt
sed 's/JPT/ASN/g' race_1kG.txt>race_1kG2.txt
sed 's/ASW/AFR/g' race_1kG2.txt>race_1kG3.txt
sed 's/CEU/EUR/g' race_1kG3.txt>race_1kG4.txt
sed 's/CHB/ASN/g' race_1kG4.txt>race_1kG5.txt
sed 's/CHD/ASN/g' race_1kG5.txt>race_1kG6.txt
sed 's/YRI/AFR/g' race_1kG6.txt>race_1kG7.txt
sed 's/LWK/AFR/g' race_1kG7.txt>race_1kG8.txt
sed 's/TSI/EUR/g' race_1kG8.txt>race_1kG9.txt
sed 's/MXL/AMR/g' race_1kG9.txt>race_1kG10.txt
sed 's/GBR/EUR/g' race_1kG10.txt>race_1kG11.txt
sed 's/FIN/EUR/g' race_1kG11.txt>race_1kG12.txt
sed 's/CHS/ASN/g' race_1kG12.txt>race_1kG13.txt
sed 's/PUR/AMR/g' race_1kG13.txt>race_1kG14.txt
```
> output: *race_1kG14.txt*, among others, which contains updated population codes for the 1000 Genomes data.

Now we can create a racefile of your own data.
```bash
awk '{print$1,$2,"OWN"}' HapMap_PCA.fam > racefile_own.txt
```
> output: *racefile_own.txt*, which shows population code for the HapMap data.

To then concatenate racefiles.
```bash
cat race_1kG14.txt racefile_own.txt | sed -e '1i\FID IID race' > racefile.txt
```
> output: *racefile.txt*, which shows population code for all data.

With this information, we can generate population stratification plot.

> With this plot, we can determine to which superpopulation our data is closest to.

```bash
Rscript PCA_merged.R 
```
> output: *PCA.jpeg*, which shows population repartition in both components.

The output file PCA.jpeg demonstrates that our "own" data falls within the European group of the 1000 genomes data. Therefore, we do not have to remove subjects.

For educational purposes however, we give scripts below to filter out population stratification outliers. Please execute the script below in order to generate the appropriate files for the next tutorial.

## Exclude ethnic outliers

Select individuals in HapMap data below cut-off thresholds. The cut-off levels are not fixed thresholds but have to be determined based on the visualization of the first two dimensions. To exclude ethnic outliers, the thresholds need to be set around the cluster of population of interest.
```bash
LC_NUMERIC="C" awk '{ if ($3 <-0.015 && $4 <-0.018) print $1,$2 }' PCA_merge2.eigenvec > EUR_PCA_merge2.txt
```
> output: *EUR_PCA_merge2.txt*, which shows kept individuals.

Once the ethnic outliers have been identified, we can extract them from the HapMap data.
```bash
plink2 --bfile HapMap_3_r3_12 --keep EUR_PCA_merge2.txt --make-bed --out HapMap_3_r3_13
```

Note, since our HapMap data did include any ethnic outliers, no individuls were removed at this step. However, if our data would have included individuals outside of the thresholds we set, then these individuals would have been removed.

# Create covariates based on PCA

We can now perform a PCA on our HapMap data **without** ethnic outliers. The values of the 10 PCA dimensions are subsequently used as covariates in the association analysis in the third tutorial.
```bash
plink2 --bfile HapMap_3_r3_12 --extract indepSNP.prune.in --pca 10 --out HapMap_3_r3_13_pca
```

With these results, we can save a plink covariate file.
```bash
cat HapMap_3_r3_13_pca.eigenvec > covar_pca.txt
```
> output: *covar_pca.txt*, which shows all components computed.

The values in *covar_pca.txt* will be used as covariates, to adjust for remaining population stratification, in the third tutorial where we will perform a genome-wide association analysis.

# End of analysis
**Congratulations!** You have succesfully controlled your data for population stratification.

For the next tutorial you need the following files:
- HapMap_3_r3_13 (the bfile, i.e., HapMap_3_r3_13.bed,HapMap_3_r3_13.bim,and HapMap_3_r3_13.fam
- covar_pca.txt

You can use the following command in order to copy them directly into the next folder.
```bash
cp HapMap_3_r3_13.* covar_pca.txt ../3_Association_GWAS
```
Now that the second tutorial is completed, you can begin the third one by moving into the corresponding folder.
```bash
cd ../3_Association_GWAS
```