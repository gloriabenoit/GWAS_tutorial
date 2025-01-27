# Explanation of the main script

This tutorial uses freely available HapMap data *hapmap3_r3_b36_fwd.consensus.qc*. We simulated a binary outcome measure (i.e., a binary phenotypic trait) and added this to the dataset. The outcome measure was only simulated for the founders in the HapMap data. This data set will be referred to as *HapMap_3_r3_1*. The HapMap data, without our simulated outcome measure, can also be obtained [here](http://hapmap.ncbi.nlm.nih.gov/downloads/genotypes/2010-05_phaseIII/plink_format/).

It is essential for the execution of the tutorial that that all scripts belonging to this tutorial are in the same directory on your UNIX workstation.
Many scripts include comments which explain how these scripts work. Note, in order to complete the tutorial it is essential to execute all commands in this tutorial.
This script can also be used for your own data analysis, to use it as such, replace the name of the HapMap file with the name of your own data file.
Furthermore, this script is based on a binary outcome measure, and is therefore not applicable for quantitative outcome measures (this would require some adaptations).

Note, most GWAS studies are performed on an ethnic homogenous population, in which population outliers are removed. The HapMap data, used for this tutorial, contains multiple distinct ethnic groups, which makes it problematic for analysis.
Therefore, we have selected only the EUR individuals of the complete HapMap sample for the tutorials 1-3. This selection is already performed in the *HapMap_3_r3_1* file from our GitHub page.

The Rscripts used in this tutorial are all executed from the Unix command line.
Therefore, this tutorial and the other tutorials from our GitHub page, can be completed simply by copy-and-pasting all commands from the "main scripts" into the Unix terminal.
For a thorough theoretical explanation of all QC steps we refer to the article accompanying this tutorial entitled "[A tutorial on conducting Genome-Wide-Association Studies: Quality control and statistical analysis](https://www.ncbi.nlm.nih.gov/pubmed/29484742)".

> My additions to the original tutorials are signaled by the use of the blockquote.
>
> Most commands were updated to work for PLINK 2.0 using multiple ressources such as file format references ([1.9](https://www.cog-genomics.org/plink/1.9/formats) vs [2.0](https://www.cog-genomics.org/plink/2.0/formats)) and [PLINK official doc](https://plink.readthedocs.io/en/latest/GWAS/). R scripts were also updated so that everything runs smoothly. In the tutorials, a command starting with `plink2` references PLINK 2.0, while one starting with `plink` references the original command used.
>
> When command architecture varies between PLINK 1.07 and PLINK 2.0, the `plink` command is commented and is before the `plink2` one.

---

# Start of analysis

## Missingness

> Missing data can introduce biases in our analysis, therefore we want to exclude SNPs that are missing in a large proportion of subjects, and individuals who have high rates of genotype missingness.

We will investigate missingness per individual and per SNP and make histograms.
```bash
plink2 --bfile HapMap_3_r3_1 --missing 
```
> output: *plink2.smiss* and *plink2.vmiss*, these files show respectively the proportion of missing SNPs per individual (sample-based) and the proportion of missing individuals per SNP (variant-based).

Now, we can generate plots to visualize the missingness results.
```bash
Rscript --no-save hist_miss.R
```
> output: *histsmiss.jpeg* and *histvmiss.jpeg*, these files show respectively individual and SNP missingness.

We need to delete SNPs and individuals with high levels of missingness, explanation of this and all following steps can be found in box 1 and table 1 of the article mentioned in the comments of this script.

The following two QC commands will not remove any SNPs or individuals. However, it is good practice to start the QC with these non-stringent thresholds.  

> SNP filtering should be performed before individual filtering.

We start by deleting **SNPs** with missingness over 0.2 (20%).
```bash
plink2 --bfile HapMap_3_r3_1 --geno 0.2 --make-bed --out HapMap_3_r3_2
```

Then we delete **individuals** with missingness over 0.2 (20%).
```bash
plink2 --bfile HapMap_3_r3_2 --mind 0.2 --make-bed --out HapMap_3_r3_3
```

Now we delete **SNPs** with missingness over 0.02 (2%).
```bash
plink2 --bfile HapMap_3_r3_3 --geno 0.02 --make-bed --out HapMap_3_r3_4
```

And finally we delete **individuals** with missingness over 0.02 (2%).
```bash
plink2 --bfile HapMap_3_r3_4 --mind 0.02 --make-bed --out HapMap_3_r3_5
```

## Sex discrepancy

Subjects who were *a priori* determined as females must have a F value under 0.2, and subjects who were *a priori* determined as males must have a F value over 0.8. This F value is based on the X chromosome inbreeding (homozygosity) estimate. Subjects who do not fulfill these requirements are flagged "PROBLEM" by PLINK.
> By default in PLINK 2.0, the maximal F value for females is 0 and the minimal value for males is 1. Therefore we need to specify our thresholds using 'max-female-xf' and 'min-male-xf'.
```bash
# plink --bfile HapMap_3_r3_5 --check-sex 
plink2 --bfile HapMap_3_r3_5 --check-sex 'max-female-xf=0.2' 'min-male-xf=0.8'
```
> output: *plink2.sexcheck*, which shows mainly F the inbreeding coefficient estimated off the X chromosome per individuals.

Generate plots to visualize the sex-check results.
```bash
Rscript --no-save gender_check.R
```
> output: *Gender_check.jpeg*, *Men_check.jpeg* and *Woman_check.jpeg*, these files show the distribution of F values based on gender in data.

These checks indicate that there is one woman with a sex discrepancy, F value of 0.99. (When using other datasets often a few discrepancies will be found).

The following two scripts can be used to deal with individuals with a sex discrepancy.Note, please use **one of the two** options below to generate the bfile *HapMap_3_r3_6*, which we will use in the next step of this tutorial.

1. Delete individuals with sex discrepancy.
We start by generating a list of individuals with the status "PROBLEM".
```bash
grep "PROBLEM" plink2.sexcheck| awk '{print$1,$2}' > sex_discrepancy.txt
```
> output: *sex_discrepancy.txt*, which shows IDs for each problematic individual.

We can then remove said individuals.
```bash
plink2 --bfile HapMap_3_r3_5 --remove sex_discrepancy.txt --make-bed --out HapMap_3_r3_6
```

2. impute-sex.
```bash
plink2 --bfile HapMap_3_r3_5 --impute-sex --make-bed --out HapMap_3_r3_6
```
This imputes the sex based on the genotype information into your data set.

## Minor allele frequency (MAF)

> SNPs with a low MAF are rare, therefore power is lacking for detecting SNP‐phenotype associations. These SNPs are also more prone to genotyping errors.

We want to generate a bfile with autosomal SNPs only and delete SNPs with a low minor allele frequency (MAF). 

We first want to select autosomal SNPs only (i.e., from chromosomes 1 to 22).
```bash
awk '{ if ($1 >= 1 && $1 <= 22) print $2 }' HapMap_3_r3_6.bim > snp_1_22.txt
```
> output: *snp_1_22.txt*, which corresponds to all autosomal SNPs.
```bash
plink2 --bfile HapMap_3_r3_6 --extract snp_1_22.txt --make-bed --out HapMap_3_r3_7
```

Now, we can generate the MAF distribution.
```bash
plink2 --bfile HapMap_3_r3_7 --freq --out MAF_check
```
> ouput: *MAF_check.afreq*, which shows the minor allele frequency and counts.
```bash
Rscript --no-save MAF_check.R
```
> output: *MAF_check.jpeg*, which shows MAF distribution.

Finally, we can remove SNPs with a low MAF frequency.
```bash
plink2 --bfile HapMap_3_r3_7 --maf 0.05 --make-bed --out HapMap_3_r3_8
```
After this step, 1073226 SNPs are left.

 A conventional MAF threshold for a regular GWAS is between 0.01 or 0.05, depending on sample size.
 > Respectively, for large (N = 100.000) vs. moderate samples (N = 10000), 0.01 and 0.05 are commonly used as MAF threshold.

## Hardy-Weinberg equilibrium (HWE)

> Markers which deviate from Hardy-Weinberg equilibrium are a common indicator of genotyping error, but they may also indicate evolutionary selection.

We first need to check the distribution of HWE p-values of all SNPs.
```bash
plink2 --bfile HapMap_3_r3_8 --hardy
```
> output: *plink2.hardy*, which shows Hardy-Weinberg equilibrium exact test report for each autosomal diploid variant.

In order to zoom in on strongly deviating SNPs, we need to select SNPs with HWE p-value below 0.00001.
> LC_NUMERIC="C" is to avoid not reading floats as such become of a different decimal separator (this assures '.' is used).
```bash
# awk '{ if ($9 <0.00001) print $0 }' plink.hwe>plinkzoomhwe.hwe
LC_NUMERIC="C" awk '{ if ($10 <0.00001) print $0 }' plink2.hardy > plink2zoomhwe.hardy
```
> output: *plink2zoomhwe.hardy*, which shows Hardy-Weinberg equilibrium exact test report for strongly deviating SNPs.

```bash
Rscript --no-save hwe.R
```
> ouput: *histhwe.jpeg* and *histhwe_below_threshold.jpeg*, these files show respectively HWE for all SNPs and only strongly deviating ones.

> By default the `--hwe` option in plink used to only filter for controls. However for PLINK 2.0, this is no longer the case. There is currently no special handling of case/control phenotypes. If needed, we can use `--keep-if "PHENO1==control"` or `--keep-if "PHENO1==case"`.
>
> The original tutorial had different threshold values for case and control, which we will not do here.
```bash
# plink --bfile HapMap_3_r3_8 --hwe 1e-6 --make-bed --out HapMap_hwe_filter_step1
# plink --bfile HapMap_hwe_filter_step1 --hwe 1e-10 --hwe-all --make-bed --out HapMap_3_r3_9
plink2 --bfile HapMap_3_r3_8 --hwe 1e-6 --make-bed --out HapMap_3_r3_9
```

Theoretical background for this step is given in [our accompanying article](https://www.ncbi.nlm.nih.gov/pubmed/29484742).

## Heterozygosity

> A big proportion of individuals with high or low heterozygosity rates can indicate sample contamination or inbreeding.

Checks for heterozygosity are performed on a set of SNPs which are not highly correlated. Therefore, to generate a list of non-(highly)correlated SNPs, we exclude high inversion regions (inversion.txt [High LD regions]) and prune the SNPs using the `--indep-pairwise` option.

The parameters "50 5 0.2" stand respectively for the window size, the number of SNPs to shift the window at each step, and the multiple correlation coefficient for a SNP being regressed on all other SNPs simultaneously.
```bash
# plink --bfile HapMap_3_r3_9 --exclude inversion.txt --range --indep-pairwise 50 5 0.2 --out indepSNP
plink2 --bfile HapMap_3_r3_9 --exclude bed1 inversion.txt --indep-pairwise 50 5 0.2 --out indepSNP
```
> output: *indepSNP.prune.in* and *indepSNP.prune.out*, these files show respectively the IDs of all conserved and excluded variants.

Note, don't delete the file indepSNP.prune.in, we will use this file in later steps of the tutorial.
```bash
plink2 --bfile HapMap_3_r3_9 --extract indepSNP.prune.in --het --out R_check
```
> output: *R_check.het*, which shows information about homozygous and heterozygous genotypes counts.

This file contains your pruned data set.

We can now plot the heterozygosity rate distribution
```bash
Rscript --no-save check_heterozygosity_rate.R
```
> output *heterozygosity.jpeg*, which shows heterozygosity rate distribution.

For data manipulation we recommend using UNIX. However, when performing statistical calculations R might be more convenient, hence the use of the Rscript for this step. The following code generates a list of individuals who deviate more than 3 standard deviations from the heterozygosity rate mean.

> This value of 3 is arbitrary, and is the recommended number from the original article.
```bash
Rscript --no-save heterozygosity_outliers_list.R
```
> output: *fail-het-qc.txt*, which shows all heterozygosity outliers found.

When using our example data/the HapMap data this list contains 2 individuals (i.e., two individuals have a heterozygosity rate deviating more than 3 SD's from the mean).

Using this list, we remove heterozygosity rate outliers.
```bash
plink2 --bfile HapMap_3_r3_9 --remove fail-het-qc.txt --make-bed --out HapMap_3_r3_10
```

## Cryptic relatedness

It is essential to check datasets you analyse for cryptic relatedness. Assuming a random population sample we are going to exclude all individuals above the pihat threshold of 0.2 in this tutorial.

> The original tutorial was checking the pihat values for each pair. However I was unsuccessful in converting the commands. Therefore, this part of the tutorial is adapted to obtain the same results, but is missing some viewing steps (Relatedness.R is no longer used and therefore not present here.)

We can check for relationships between individuals with a pihat over 0.2.
```bash
plink2 --bfile HapMap_3_r3_10 --king-cutoff 0.2 --out pihat_min0.2
```
> ouput: *pihat_min0.2.king.cutoff.in.id* and *pihat_min0.2.cutoff.out.id*, these files show respectively the IDs of all conserved and excluded variants.

The HapMap dataset is known to contain parent-offspring relations.
> Therefore, we found that a lot of individuals are filtered out (53 here).

Normally, family based data should be analyzed using specific family based methods. In this tutorial, for demonstrative purposes, we treat the relatedness as cryptic relatedness in a random population sample.
In this tutorial, we aim to remove all 'relatedness' from our dataset.
To demonstrate that the majority of the relatedness was due to parent-offspring we only include founders (individuals without parents in the dataset).
```bash
plink2 --bfile HapMap_3_r3_10 --filter-founders --make-bed --out HapMap_3_r3_11
```

Now we will look again for individuals with a pihat over 0.2.
```bash
plink2 --bfile HapMap_3_r3_11 --king-cutoff 0.2 --out pihat_min0.2_in_founders
```
> output: *pihat_min0.2_in_founders.king.cutoff.in.id* and *pihat_min0.2_in_founders.king.cutoff.out.id*, these files show respectively the IDs of all conserved and excluded variants in only founders.

> Only one individual now remains. How he was chosen by the algorithm is unclear. We can filter him out.
```bash
plink2 --bfile HapMap_3_r3_11 --king-cutoff 0.2 --make-bed --out HapMap_3_r3_12
```

# End of analysis

**Congratulations!** You have succesfully completed the first tutorial. You are now able to conduct a proper genetic QC. 

For the next tutorial, using the script *2_Main_script_MDS.md*, you need the following files:
- The bfile HapMap_3_r3_12 (i.e., HapMap_3_r3_12.fam,HapMap_3_r3_12.bed, and HapMap_3_r3_12.bim
- indepSNP.prune.in

You can use the following command in order to copy them directly into the next folder.
```bash
cp HapMap_3_r3_12.* indepSNP.prune.in ../2_Population_stratification
```
Now that the first tutorial is completed, you can begin the second one by moving into the corresponding folder.
```bash
cd ../2_Population_stratification
```
