GWAS tutorial (updated for PLINK 2.0)
---

This GitHub repository is forked from the original one created by Andries Marees in order to update PLINK commands from 1.07 to 2.0. It provides several tutorials about techniques used to analyze genetic data.

Underneath this README is a step-by-step guide to help researchers without experience in Unix to complete these tutorials succesfully. For reseachers familiar with Unix this README will probably be sufficient.

#### Scripts available (in order) :
1. All essential GWAS QC steps along with scripts for data visualization.
2. Dealing with population stratification, using 1000 genomes as a reference.
3. Association analyses of GWAS data.
4. Polygenic risk score (PRS) analyses.

The scripts downloadable from this GitHub page can be seen purely as tutorials and used for educational purposes, but can also be used as a template for analyzing your own data.
All scripts/tutorials from this GitHub page use freely downloadable data, commands to download the necessary data can be found in the scripts. 

#### Content:
* ./1_QC_GWAS
* ./2_Population_stratification
* ./3_Association_GWAS
* ./4_ PRS
  
The tutorials are designed to run on an UNIX/Linux computer/server. The first 3 tutorials contain both *.md* as well as *.R* scripts. The main scripts for performing these tutorials are the *.md* scripts (respectively for the first 3 tutorials: *1_Main_script_QC_GWAS.md*, *2_Main_script_PCA.md*, and *3_Main_script_association_GWAS.md*). These script will execute the *.R* scripts, when those are placed in the same directory. 

Note, without placing all files belonging to a specific tutorial in the same directory, the tutorials cannot be completed. 

Furthermore, the first 3 tutorials are not independent; they should be followed in the order given above, according to their number. For example, the files generated at the end of tutorial 1 are essential in performing tutorial 2. Therefore, those files should be moved/copied to the directory in which tutorial 2 is executed. In addition, the files from tutorial 2 are essential for tutorial 3.
The fourth tutorial (*4_ PRS.doc*) is a MS Word document, and runs independently of the previous 3 tutorials.

All scripts are developed for UNIX/Linux computer resources, and all commands should be typed/pasted at the shell prompt.

#### Setup

In order to successfully complete the tutorials it is essential to download all files and upload them to your working directory. To pull all tutorials to your computer simply use the following command:
```bash
git clone https://github.com/gloriabenoit/GWAS_tutorial.git
```
You can now move into the first folder to begin the tutorials.
```bash
cd GWAS_tutorial/1_QC_GWAS
```
Start by opening *1_Main_script_QC_GWAS.md* on your prefered text editor.

#### Updates:

Most commands were updated to work for PLINK 2.0 using multiple ressources such as file format references ([1.9](https://www.cog-genomics.org/plink/1.9/formats) vs [2.0](https://www.cog-genomics.org/plink/2.0/formats)) and [PLINK official doc](https://plink.readthedocs.io/en/latest/GWAS/). R scripts were also updated so that everything runs smoothly. 

Some commands have yet to be updated for [PLINK 2.0](https://www.cog-genomics.org/plink/2.0/), therefore some steps still need to use a previous version. Here, we use [PLINK 1.9](https://www.cog-genomics.org/plink/1.9/). In the tutorials, a command starting with `plink2` references PLINK 2.0, while one starting with `plink` references the original command used.

When command architecture varies between PLINK 1.07 and PLINK 2.0, the `plink` command is commented and is before the `plink2` one.


> My additions to the original tutorials are signaled by the use of the blockquote.

---

# Step-by-step-guide for this tutorial 

Step-by-step-guide for researches new to Unix and/or genetic analyses.


## Introduction

The tutorial consist of four separate parts. The first three are dependent of each other and can only be performed in consecutive order, starting from the first (*1_QC_GWAS*), then the second (*2_Population_stratification*, followed by the third (*3_Association_GWAS*). The fourth part (*4_ PRS.doc*) can be performed independently. 

The Unix commands provided in this guide should be typed/copy-and-pasted after the prompt ($ or >) on your Unix machine.

We assume that you have read the accompanying article "[A tutorial on conducting Genome-Wide-Association Studies: Quality control and statistical analysis](https://www.ncbi.nlm.nih.gov/pubmed/29484742)", which should provide you with a basic theoretical understanding of the type of analyses covered in this tutorial. 

This step-by-step guide serves researchers who have none or very little experience with Unix, by helping them through the Unix commands in preparation of the tutorial.

## Preparation

### Step 1 : Create a directory

 The current set of tutorials on this GitHub page are based on a GNU/Linux-based computer, therefore: 
- Make sure you have access to a GNU/Linux-based computer resource.
- Create a directory where you plan to conduct the analysis.

Execute the command below (copy-and-paste without the {} ).
```bash
mkdir {name_for_your_directory}
```

### Step 2 : Download the files
- Change the directory of your Unix machine to the created directory from step 1.

Execute the command below
```bash
cd HOME/{user}/{path/name_for_your_directory}  
git clone https://github.com/gloriabenoit/GWAS_tutorial.git
```

- Move into the newly created directory.

Execute the commands below
```bash
cd 1_QC_GWAS
```

### Step 3 : Download R and PLINK

 This tutorial requires the open-source programming language R and the open-source whole genome association analysis toolset PLINK version 2.0. If these programs are not already installed on your computer they can be downloaded [here](https://www.r-project.org/) and [here](https://www.cog-genomics.org/plink/2.0/) respectively.

- We recommend using the newest versions. These websites will guide you through the installation process.

- Congratulations everything is set up to start the tutorial!


## Execution of tutorial 1

Once you've created a directory in which you have downloaded the folder *1_QC_GWAS*, you are ready to start the first part of the actual tutorial.

All steps of this tutorial will be executed using the commands from the main script: 1_Main_script_QC_GWAS.md, the only thing necessary in completing the tutorial is to copy-and-paste the commands from the main script in the prompt of your Unix device. 

Note, make sure you are in the directory containing all files, which is the directory after the last command of step 2. There is no need to open the other files manually. 

Note, if R or PLINK are installed in a directory other than your working directory please specify the path to the executables in the given script. Alternatively, you can copy the executables of the programs to your working directory. For example, by using `cp {path/program name} {path/directory}`. However, when using a cluster computer, commands such a "module load plink", and "module load R" will suffice, regardless of directory.

For more information of using R and PLINK in a Unix/Linux environment, click [here](http://zzz.bwh.harvard.edu/plink/download.shtml#nixs).


## Execution of tutorials 2 and 3

Tutorials 2 and 3 need to be completed in order, and both use file created in the previous tutorial. You need to use the output file from the last tutorial as input for the tutorial you want to start.

## Execution of tutorial 4

*4_PRS.doc* works independently from the other tutorials. After downloading *4_PRS.doc*, you can run the script, without the need for unzipping, in a directory of choice.

