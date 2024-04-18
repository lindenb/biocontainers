SHELL=$(dir $(lastword $(MAKEFILE_LIST)))docker.run
.SHELLFLAGS=
.PHONY:all
.SILENT:
BEDTOOLS_VERSION?=2.31.1
HTS_VERSION?=1.20

all:

gatk: gatk4
	

bedtools.src: wget common.c.compile python3
	cd /opt && \
		wget -O bedtools-${BEDTOOLS_VERSION}.tar.gz "https://github.com/arq5x/bedtools2/releases/download/v${BEDTOOLS_VERSION}/bedtools-${BEDTOOLS_VERSION}.tar.gz" && \
		tar xvfz bedtools-${BEDTOOLS_VERSION}.tar.gz && \
		cd bedtools2 && sed -i 's/python scripts/python3 scripts/' Makefile && \
		make
	ENV PATH=/opt/bedtools2/bin:$${PATH}

htslib.src: wget common.c.compile bzip2
	cd /opt/ && \
		wget -O htslib-${HTS_VERSION}.tar.bz2 "https://github.com/samtools/htslib/releases/download/${HTS_VERSION}/htslib-${HTS_VERSION}.tar.bz2" && \
		tar xvfj htslib-${HTS_VERSION}.tar.bz2 && \
		cd htslib-${HTS_VERSION} && \
		make
	ENV PATH=/opt/htslib-${HTS_VERSION}:$${PATH}

htslib bcftools samtools gatk4  bedtools: conda
	conda install --override-channels -c conda-forge -c bioconda -c default $@



conda: wget python3
	ENV CONDA_DIR /opt/conda
	wget --quiet "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" -O ~/miniconda.sh
	/bin/bash ~/miniconda.sh -b -p /opt/conda
	ENV PATH=/opt/conda/bin:$${PATH}
	conda update -y conda

common.c.compile: make libz-dev libbz2-dev g++ liblzma-dev libcurl4-openssl-dev libncurses5-dev

git wget openjdk-17-jdk make r-base bzip2 libcurl4-openssl-dev libncurses5-dev python3 libz-dev libbz2-dev liblzma-dev datamash g++ : apt.get.update
	apt-get -y install $@

apt.get.update: dockerfile.header
	# update apt
	apt-get -y update

dockerfile.header:
	FROM ubuntu:22.04
