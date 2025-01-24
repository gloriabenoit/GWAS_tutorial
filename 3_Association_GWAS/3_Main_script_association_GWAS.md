# Explanation of the main script
Just as with the previous tutorials, this tutorial can be completed simply by copy-and-pasting all commands from this "main script" into the Unix terminal.

For a theoretical background on these method we refer to the accompanying article entitled "A tutorial on conducting Genome-Wide-Association Studies: Quality control and statistical analysis" (https://www.ncbi.nlm.nih.gov/pubmed/29484742).
In order to run this script you need the following files from the previous tutorial: covar_pca.txt and HapMap_3_r3_13 (bfile, i.e., HapMap_3_r3_13.bed, HapMap_3_r3_13.bim, HapMap_3_r3_13.fam).

> My additions to the original tutorials are signaled by the use of the blockquote.
>
> Most commands were updated to work for PLINK 2.0 using multiple ressources such as file format references ([1.9](https://www.cog-genomics.org/plink/1.9/formats) vs [2.0](https://www.cog-genomics.org/plink/2.0/formats)) and [PLINK official doc](https://plink.readthedocs.io/en/latest/GWAS/). R scripts were also updated so that everything runs smoothly. In the tutorials, a command starting with `plink2` references PLINK 2.0, while one starting with `plink` references the original command used.
>
> When command architecture varies between PLINK 1.07 and PLINK 2.0, the `plink` command is commented and is before the `plink2` one.

---

# Association analyses

For the association analyses we use the files generated in the previous tutorial (population stratification), named *HapMap_3_r3_13* (with .bed, .bim, and .fam. extensions) and *covar_pca.txt*.

## For binary traits

### assoc
> assoc is no longer supported in PLINK 2.0, therefore we won't be performing it.
```bash
# plink --bfile HapMap_3_r3_13 --assoc --out assoc_results
```
Note, the `--assoc` option does not allow to correct covariates such as principal components PC's/ (MDS components), which makes it less suited for association analyses.

### logistic 
We will be using 10 principal components as covariates in this logistic analysis. We use the PCA components calculated from the previous tutorial *covar_pca.txt*.
```bash
# plink --bfile HapMap_3_r3_13 --covar covar_mds.txt --logistic --hide-covar --out logistic_results
plink2 --bfile HapMap_3_r3_13 --glm hide-covar --covar covar_pca.txt --out logistic_results
```
> output: *logistic_results_2.PHENO1.glm.logistic.hybrid*, which shows computed regression association statistics.

Note, we use the option `-hide-covar` to only show the additive results of the SNPs in the output file.

We remove NA values, since those might give problems when generating plots in later steps.
```bash
# awk '!/'NA'/' logistic_results.assoc.logistic > logistic_results.assoc_2.logistic
awk '{ if ($17 == "ERRCODE" || $17 == ".") print $0 }' logistic_results.PHENO1.glm.logistic.hybrid > logistic_results_2.PHENO1.glm.logistic.hybrid
```

The results obtained from these GWAS analyses will be visualized in the last step. This will also show if the data set contains any genome-wide significant SNPs.

Note, in case of a quantitative outcome measure the option `--logistic` should be replaced by `--linear`. The use of the `--assoc` option is also possible for quantitative outcome measures (as metioned previously, this option does not allow the use of covariates).

> In PLINK 2.0, the `--glm` option works both for quantitative and binary traits.

# Multiple testing
There are various way to deal with multiple testing outside of the conventional genome-wide significance threshold of 5.0E-8, below we present a couple.

## adjust
```bash
# plink --bfile HapMap_3_r3_13 -assoc --adjust --out adjusted_assoc_results
```
This file gives a Bonferroni corrected p-value, along with FDR and others.

## Permutation

> `--glm` permutation tests are still under development in PLINK 2.0, therefore we cannot perform them.

This is a computational intensive step. Further pros and cons of this method, which can be used for association and dealing with multiple testing, are described in [our article corresponding to this tutorial](https://www.ncbi.nlm.nih.gov/pubmed/29484742).

To reduce computational time we only perform this test on a subset of the SNPs from chromosome 22.
The EMP2 collumn provides the for multiple testing corrected p-value.

Generate subset of SNPs.
```bash
# awk '{ if ($4 >= 21595000 && $4 <= 21605000) print $2 }' HapMap_3_r3_13.bim > subset_snp_chr_22.txt
```

Filter your bfile based on the subset of SNPs generated in the step above.
```bash
# plink --bfile HapMap_3_r3_13 --extract subset_snp_chr_22.txt --make-bed --out HapMap_subset_for_perm
```

Perform 1000000 permutations
```bash
# plink --bfile HapMap_subset_for_perm --assoc --mperm 1000000 --out subset_1M_perm_result
```

Order your data, from lowest to highest p-value.
```bash
# sort -gk 4 subset_1M_perm_result.assoc.mperm > sorted_subset.txt
```
Check ordered permutation results
```bash
# head sorted_subset.txt
```

# Generate Manhattan and QQ plots

These scripts assume R >= 3.0.0.
If you changed the name of the .assoc file or to the assoc.logistic file, please assign those names also to the Rscripts for the Manhattan and QQ plot, otherwise the scripts will not run.

The following Rscripts require the R package *qqman*, the scripts provided will automatically download this R package and install it in /home/{user}/ . Additionally, the scripts load the qqman library and can therefore, similar to all other Rscript on this GitHub page, be executed from the command line. This location can be changed to your desired directory.

```bash
Rscript --no-save Manhattan_plot.R
Rscript --no-save QQ_plot.R
```

## Please read below if you encountered an error
Note, the mirror used to download the package qqman can no longer by active, which will result in an error:
```text
Error in library("qqman", lib.loc = "-") :
there is no package called 'qqman'
Execution halted
```

This error can simply be resolved by changing the addresses (http://cran...) in the scripts *Manhattan_plot.R* and *QQ_plot.R*.

> All available CRAN mirrors can be found on the [official page](https://cran.r-project.org/), section "Mirrors".

In both R scripts, you need to change the `repos` parameter from the `install.packages` command and use another CRAN mirror. It is best to use a location close to you.

# End of analysis
**Congratulations!** You have succesfully conducted a GWAS analyses.

If you are also interested in learning how to conduct a polygenic risk score (PRS) analysis please see our fourth tutorial.
The tutorial explaining PRS is independent from the previous tutorials.
