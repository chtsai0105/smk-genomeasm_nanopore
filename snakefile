import pandas as pd


## Load config.yaml
configfile: 'config.yaml'
## Simply the path
path = config['Path']
## Load samples.csv as a pandas Dataframe
sample_df = pd.read_csv(config['Metadata'], keep_default_na=False, na_values=['_'], comment='#')


## Create empty list object and use extend to add targets
target_list = list()

## The following define the targets of each step.
## By default will only leave the leaf nodes of the workflow uncommented.
## You can comment/uncomment to adjust at the step you want to stop.

# if 'canu' in config['assembler']:
#     target_list.extend(["{dir}/{sample}/{sample}.contigs.fasta".format(dir=path['canu'], sample=sample) for sample in sample_df['NAME']])
# elif 'flye' in config['assembler']:
#     target_list.extend(["{dir}/{sample}/assembly.fasta".format(dir=path['flye'], sample=sample) for sample in sample_df['NAME']])

for assembler in config['assembler']:
    # target_list.extend(["{dir}/{sample}/{assembler}.fasta".format(dir=path['medaka'], sample=sample, assembler=assembler) for sample in sample_df['NAME']])
    # target_list.extend(["{dir}/{sample}/{assembler}.calls_to_draft.bam".format(dir=path['medaka'], sample=sample, assembler=assembler) for sample in sample_df['NAME']])
    # target_list.extend(["{dir}/{sample}/{assembler}.hdf".format(dir=path['medaka'], sample=sample, assembler=assembler) for sample in sample_df['NAME']])
    target_list.extend(["{dir}/{sample}/{assembler}.polished.fasta".format(dir=path['medaka'], sample=sample, assembler=assembler) for sample in sample_df['NAME']])


## Functions to handle complex input
def get_sample_fastq(wildcards):
    return "{dir}/{fastq}".format(dir=path['fastq'], fastq=sample_df.loc[sample_df['NAME'] == wildcards.sample, 'NANOPORE'].item())

def get_asm_fasta(wildcards):
    input_list = list()
    if 'canu' in config['assembler']:
        input_list.append("{dir}/{sample}/{sample}.contigs.fasta".format(dir=path['canu'], sample=wildcards.sample))
    if 'flye' in config['assembler']:
        input_list.append("{dir}/{sample}/assembly.fasta".format(dir=path['flye'], sample=wildcards.sample))
    return input_list


## Rules
wildcard_constraints:
    sample = '[^/]+'                # Regex for all characters except /

localrules:
    link_draft_fasta                # Define the rules that don't have to be submitted to computing nodes


rule all:
    input:
        target_list                 # Please refer to line 13


rule canu:
    input:
        get_sample_fastq
    output:
        "{dir}/{{sample}}/{{sample}}.contigs.fasta".format(dir=path['canu'])
    params:
        output_dir = "{dir}/{{sample}}".format(dir=path['canu']),
        genomesize = "20m"
    shell:
        """
        canu -p {wildcards.sample} -d {params.output_dir} genomeSize={params.genomesize} -raw -nanopore {input}
        """


rule flye:
    input:
        get_sample_fastq
    output:
        "{dir}/{{sample}}/assembly.fasta".format(dir=path['flye'])
    threads: 4
    shell:
        """
        flye --nano-hq {input} --out-dir {wildcards.sample} --threads {threads} --scaffold
        """


rule link_draft_fasta:
    input:
        get_asm_fasta
    output:
        "{dir}/{{sample}}/{{assembler}}.draft.fasta".format(dir=path['medaka'])
    shell:
        """
        ln -sr {input} {output}
        """


rule medaka_mini_align:
    input:
        fastq = get_sample_fastq,
        draft = rules.link_draft_fasta.output
    output:
        "{dir}/{{sample}}/{{assembler}}.calls_to_draft.bam".format(dir=path['medaka'])
    threads: 4
    shell:
        """
        mini_align -i {input.fastq} -r {input.draft} -m -p {output} -t {threads}
        """


rule medaka_consensus:
    input:
        rules.medaka_mini_align.output
    output:
        "{dir}/{{sample}}/{{assembler}}.hdf".format(dir=path['medaka'])
    params:
        model = "r941_min_high_g360"
    shell:
        """
        medaka consensus {input} {output} --model {params.model} --threads {threads}
        """


rule medaka_stitch:
    input:
        hdf = rules.medaka_consensus.output,
        draft = rules.medaka_mini_align.output
    output:
        "{dir}/{{sample}}/{{assembler}}.polished.fasta".format(dir=path['medaka'])
    shell:
        """
        medaka stitch --threads {threads} {input.hdf} {input.draft} {output}
        """
