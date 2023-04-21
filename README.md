[![Contributors][contributors-shield]][contributors-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]

[contributors-shield]: https://img.shields.io/github/contributors/chtsai0105/smk-genomeasm_nanopore
[contributors-url]: https://github.com/chtsai0105/smk-genomeasm_nanopore/graphs/contributors
[issues-shield]: https://img.shields.io/github/issues/chtsai0105/smk-genomeasm_nanopore
[issues-url]: https://github.com/chtsai0105/smk-genomeasm_nanopore/issues
[license-shield]: https://img.shields.io/github/license/chtsai0105/smk-genomeasm_nanopore?label=license
[license-url]: https://github.com/chtsai0105/smk-genomeasm_nanopore/blob/master/LICENSE

# Snakemake workflow for NANOPORE sequence processing

The flow chart below give you an overview of how this workflow handling 2 NANOPORE long reads data.

A brief description of the steps:

1. The fastq will be assembled by `canu` and `flye` and generate draft fasta.

2. Since the draft fasta from `canu` and `flye` have different names. A symbolic link is created to generalize the name.

3. Next, `mini_align` in the package `medaka` is used to align the reads back to the draft fasta.

4. `medaka consensus` is used to generate a hdf file.

5. `medaka stitch` is used to generate the polish fasta.

![Alt text](resources/dag.png?raw=true "Workflow with dummy data")

**Note: the workflow is still under development!! Currently only support for dry-run test.**

<br>

## Install the workflow management system [**snakemake**](https://snakemake.readthedocs.io/en/stable/index.html)
Snakemake is a Python based language and execution environment for GNU Make-like workflows.
The workflow is defined by specifying *rules* in a `snakefile`.
Rules further specify how to create sets of output files from sets of input files as well as the parameters and the command.

Snakemake automatically determines the dependencies between the rules by matching file names.
Please refer to [snakemake tutorial page](https://snakemake.readthedocs.io/en/stable/tutorial/basics.html) to see how to define the rules.

We have to make sure whether snakemake is installed in your system before we start.

### UCR hpcc
UCR hpcc have snakemake installed in environment module. If you're on UCR hpcc you can simply load snakemake module by the following command.
```
module load snakemake
```

### If you're not on UCR hpcc
If you're NOT on UCR hpcc and you don't have snakemake in the enviornment module, please follow the below steps to create a snakemake conda environment.
1. First, create an environment named **snakemake**.

    ```
    conda create -n snakemake
    ```

    After create the environment, activate it by:
    
    ```
    conda activate snakemake
    ```

2. Install the package **mamba**, which is a faster version of **conda**. 

    ```
    conda install -c conda-forge mamba
    ```
    
    After **mamba** being installed, you can later switch from `conda install [package]` to `mamba install [package]` to speed up the package installation.

3. Next, install the package **snakemake** through **mamba**.
    
    ```
    mamba install snakemake
    ```
    
4. Then you can execute the `snakemake --help` to show the snakemake helping page.

<br>

## Clone the metagenome workflow

Clone the repo to your computer.

Clone by the following command if you're using public key for github connection.

```
git clone --recurse-submodules git@github.com:chtsai0105/smk-genomeasm_nanopore.git
```

Or clone by https link.

```
git clone --recurse-submodules https://github.com/chtsai0105/smk-genomeasm_nanopore.git
```

## Folder structure

Next, go to the directory by `cd smk-genomeasm_nanopore`. It should contains the following files:

File                    |Description
------------------------|---------------------------------
`snakefile`             |Define the rules for the workflow.
`config.yaml`           |Define the path for data and metadata.
`samples.csv`           |The metadata for samples. Define the names of the samples and the fastq files.
`data/`                 |The folder for the data and the workflow outputs.
`data/fastq`            |The folder for the raw fastq.

## Define the path

You can edit the `config.yaml` to setup the path for the metadata of the samples and the outputs of each step. By default, the metadata is defined in the file `samples.csv` and all the outputs will be saved in the folder `data`.

## Define the samples

You should properly defined your metadata, which is recorded in the `samples.csv`, before running the workflow. There are 9 columns in this csv table. The column **NAME** defined the sample name. You can change it to names which are more distinguishable instead of accession numbers. Please also confirm that the names on each row are unique. The column **NANOPORE** defined the fastq file names you placed in the folder `data/fastq`. Please make sure they are identical to the fastq files otherwise the workflow may have trouble to find the files.

Currently there are 2 empty dummy data, Rhodotorula_evergladiensis_Y48721.fq.gz and Rhodotorula_graminis_Y2474.fq.gz, for dry-run test.

## Run the workflow

After compiling the template and setup the paramters, the next step is to run the workflow.

Snakemake provide a dry-run feature to examine the workflow before truly running it. You should always test the workflow beforehand to make sure it execute as expected by the following command:

```
snakemake -np
```

**Reminder again: This workflow is not yet completed!! Only support for dry-run test.**