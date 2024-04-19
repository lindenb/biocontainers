SHELL=$(dir $(lastword $(MAKEFILE_LIST)))docker.run
.SHELLFLAGS=
.PHONY:all
.SILENT:
BEDTOOLS_VERSION?=2.31.1
HTS_VERSION?=1.20
GATK_VERSION?=4.5.0.0
BWA_VERSION?=139f68fc4c37478137
R_DEFAULT_REPO?=https://cloud.r-project.org
JVARKIT_VERSION?=HEAD
MOSDEPTH_VERSION?=0.3.8
PICARD_VERSION?=3.1.1

define R_INSTALL_PACKAGE
Rscript -e 'install.packages("$(1)", repos="$(R_DEFAULT_REPO)")'
endef

all:
	# this is the top target. Doing nothing.

gatk: gatk4
	

bedtools.src: wget common.c.compile python3
	cd /opt && \
		wget -O bedtools-${BEDTOOLS_VERSION}.tar.gz "https://github.com/arq5x/bedtools2/releases/download/v${BEDTOOLS_VERSION}/bedtools-${BEDTOOLS_VERSION}.tar.gz" && \
		tar xvfz bedtools-${BEDTOOLS_VERSION}.tar.gz && \
		cd bedtools2 && sed -i 's/python scripts/python3 scripts/' Makefile && \
		make && \
		rm ../bedtools-${BEDTOOLS_VERSION}.tar.gz
	ENV PATH=/opt/bedtools2/bin:$${PATH}

htslib.src: wget common.c.compile bzip2
	cd /opt/ && \
		wget -O htslib-${HTS_VERSION}.tar.bz2 "https://github.com/samtools/htslib/releases/download/${HTS_VERSION}/htslib-${HTS_VERSION}.tar.bz2" && \
		tar xvfj htslib-${HTS_VERSION}.tar.bz2 && \
		cd htslib-${HTS_VERSION} && \
		make && \
		rm ../htslib-${HTS_VERSION}.tar.bz2
	ENV PATH=/opt/htslib-${HTS_VERSION}:$${PATH}

bcftools.src: htslib.src python3-matplotlib
	cd /opt/ && \
		wget -O bcftools-${HTS_VERSION}.tar.bz2 "https://github.com/samtools/bcftools/releases/download/${HTS_VERSION}/bcftools-${HTS_VERSION}.tar.bz2" && \
		tar xvfj bcftools-${HTS_VERSION}.tar.bz2 && \
		cd bcftools-${HTS_VERSION} && \
		make HTSDIR=/opt/htslib-${HTS_VERSION} && \
		rm ../bcftools-${HTS_VERSION}.tar.bz2
	ENV PATH=/opt/bcftools-${HTS_VERSION}:$${PATH}
	ENV BCFTOOLS_PLUGINS=/opt/bcftools-${HTS_VERSION}/plugins

samtools.src: htslib.src
	cd /opt/ && \
		wget -O samtools-${HTS_VERSION}.tar.bz2 "https://github.com/samtools/samtools/releases/download/${HTS_VERSION}/samtools-${HTS_VERSION}.tar.bz2" && \
		tar xvfj samtools-${HTS_VERSION}.tar.bz2 && \
		cd samtools-${HTS_VERSION} && \
		make HTSDIR=/opt/htslib-${HTS_VERSION} && \
		rm ../samtools-${HTS_VERSION}.tar.bz2
	ENV PATH=/opt/samtools-${HTS_VERSION}:$${PATH}

bwa.src: git common.c.compile
	cd /opt && \
		git clone "https://github.com/lh3/bwa" && \
		cd bwa && \
		git reset --hard "${BWA_VERSION}" && \
		make
	ENV PATH=/opt/bwa:$${PATH}

gatk4.github: openjdk-17-jdk wget r-base
	cd /opt/ && \
		wget -O "gatk-$(GATK_VERSION).zip" "https://github.com/broadinstitute/gatk/releases/download/$(GATK_VERSION)/gatk-$(GATK_VERSION).zip" && \
		unzip gatk-$(GATK_VERSION).zip && \
		rm -rf gatk-$(GATK_VERSION).zip "gatk-$(GATK_VERSION)/gatkdoc"
	ENV GATK4_JAR=/opt/gatk-$(GATK_VERSION)/gatk-package-$(GATK_VERSION)-local.jar
	ENV PATH=/opt/gatk-$(GATK_VERSION):$${PATH}

jvarkit.github: openjdk-17-jdk make git
	cd /opt/ && \
		git clone -b dev "https://github.com/lindenb/jvarkit.git" jvarkit.tmp && \
		cd jvarkit.tmp && git reset --hard ${JVARKIT_VERSION} && make && cd .. && \
		mv "jvarkit.tmp" "/opt/jvarkit"
	ENV JVARKIT_DIST=/opt/jvarkit/dist


plink: wget
	cd /opt/ && \
		mkdir plink && \
		cd plink && \
		wget -O tmp.zip "https://s3.amazonaws.com/plink1-assets/dev/plink_linux_x86_64.zip" && \
		unzip tmp.zip && \
		rm tmp.zip
	ENV PATH=/opt/plink:$${PATH}

r.skat r.qqman r.ggplot2: r-base
	$(call R_INSTALL_PACKAGE,$(word 2,$(subst ., ,$@)))



mosdepth: wget
	mkdir /opt/mosdepth && \
		wget -O "/opt/mosdepth/mosdepth" "https://github.com/brentp/mosdepth/releases/download/v$(MOSDEPTH_VERSION)/mosdepth" && \
		chmod +x /opt/mosdepth/mosdepth
	ENV PATH=/opt/mosdepth:$${PATH}

picard: wget openjdk-17-jdk
	mkdir /opt/picard && \
		wget -O "/opt/picard/picard.jar" "https://github.com/broadinstitute/picard/releases/download/$(PICARD_VERSION)/picard.jar"
	ENV PICARD_JAR=/opt/picard/picard.jar



htslib bcftools samtools gatk4  bedtools: conda
	conda install --override-channels -c conda-forge -c bioconda -c default $@


conda: wget python3
	ENV CONDA_DIR /opt/conda
	wget --quiet "https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh" -O ~/miniconda.sh
	/bin/bash ~/miniconda.sh -b -p /opt/conda
	ENV PATH=/opt/conda/bin:$${PATH}
	conda update -y conda

common.c.compile: make libz-dev libbz2-dev g++ liblzma-dev libcurl4-openssl-dev libncurses5-dev

xmllint:  libxml2-utils

# https://askubuntu.com/questions/1447996
git wget openjdk-17-jdk make r-base bzip2 libcurl4-openssl-dev libncurses5-dev python3 libz-dev libbz2-dev liblzma-dev datamash g++ python3-matplotlib fop xsltproc  libxml2-utils sqlite3 : apt.get.update
	DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC  apt-get -y install $@

apt.get.update: dockerfile.header
	# update apt
	apt-get -y update

dockerfile.header:
	FROM ubuntu:22.04
