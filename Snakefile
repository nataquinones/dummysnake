# ╭───────────────────────────────────────────────────────────────────────────╮
#   DUMMY SNAKE
#
#   author: Natalia Quinones-Olvera
#   email: nquinones@g.harvard.edu
# ╰───────────────────────────────────────────────────────────────────────────╯


# SETUP
# -----------------------------------------------------------------------------


samples = ['PRD1', 'PRDcerulean']


    
# RULE ALL
# -----------------------------------------------------------------------------

rule all:
    input:
        fastqc = expand('data/reads/fastqc/{sample}/{sample}_R1.trim_fastqc.html', sample=samples),
        assembly = expand('data/assemblies/{sample}/assembly.fasta', sample=samples)


# RULE: Trim adapters with trimmomatic
# -----------------------------------------------------------------------------

rule trimmomatic:
    input:
        # reads
        R1 = 'data/reads/{sample}_R1.fastq.gz',
        R2 = 'data/reads/{sample}_R2.fastq.gz'
    output:
        R1_trimmed = 'data/reads/trimmed_reads/{sample}_R1.trim.fastq.gz',
        R2_trimmed = 'data/reads/trimmed_reads/{sample}_R2.trim.fastq.gz',
        R1_u_trimmed = 'data/reads/trimmed_reads/unpaired/{sample}_R1.trim.U.fastq.gz',
        R2_u_trimmed = 'data/reads/trimmed_reads/unpaired/{sample}_R2.trim.U.fastq.gz'
    conda:
        'envs/dummysnake.yml'
    params:
        adapters_path = 'envs/NexteraPE-PE.fa'
    shell:
        'trimmomatic '\
            'PE '\
            '{input.R1} '\
            '{input.R2} '\
            '{output.R1_trimmed} '\
            '{output.R1_u_trimmed} '\
            '{output.R2_trimmed} '\
            '{output.R2_u_trimmed} '\
            'ILLUMINACLIP:{params.adapters_path}:2:30:10:2:True '\
            'LEADING:3 '\
            'TRAILING:3 '\
            'MINLEN:36'

        
# RULE: Check read quality with fastqc
# -----------------------------------------------------------------------------

rule fastqc:
    input:
        R1_trimmed = 'data/reads/trimmed_reads/{sample}_R1.trim.fastq.gz',
        R2_trimmed = 'data/reads/trimmed_reads/{sample}_R2.trim.fastq.gz'
    output:
        html_report_R1 = 'data/reads/fastqc/{sample}/{sample}_R1.trim_fastqc.html',
        html_report_R2 = 'data/reads/fastqc/{sample}/{sample}_R2.trim_fastqc.html'
    conda:
        'envs/dummysnake.yml'
    params:
        outdir = 'data/reads/fastqc/{sample}'
    shell:
        'fastqc '\
            '{input.R1_trimmed} '\
            '{input.R2_trimmed} '\
            '-f fastq '\
            '-o {params.outdir}'

        


# RULE: Assemble genomes with unicycler
# -----------------------------------------------------------------------------
            
rule unicycler_assembly:
    input:
        # trimmed reads
        R1_trimmed = 'data/reads/trimmed_reads/{sample}_R1.trim.fastq.gz',
        R2_trimmed = 'data/reads/trimmed_reads/{sample}_R2.trim.fastq.gz'
    output:
        # main assembly
         'data/assemblies/{sample}/assembly.fasta'
    conda:
        'envs/dummysnake.yml'
    params:
        # variable to pass outdir output
        outdir = 'data/assemblies/{sample}/'
    shell:
        'unicycler ' \
            '-1 {input.R1_trimmed} ' \
            '-2 {input.R2_trimmed} ' \
            '-o {params.outdir}'
