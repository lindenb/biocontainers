FROM ubuntu:22.04
# update apt
RUN apt-get -y update
RUN apt-get -y install wget
RUN apt-get -y install make
RUN apt-get -y install libz-dev
RUN apt-get -y install libbz2-dev
RUN apt-get -y install g++
RUN apt-get -y install liblzma-dev
RUN apt-get -y install libcurl4-openssl-dev
RUN apt-get -y install libncurses5-dev
RUN apt-get -y install python3
RUN cd /opt && \
	wget -O bedtools-2.31.1.tar.gz "https://github.com/arq5x/bedtools2/releases/download/v2.31.1/bedtools-2.31.1.tar.gz" && \
	tar xvfz bedtools-2.31.1.tar.gz && \
	cd bedtools2 && sed -i 's/python scripts/python3 scripts/' Makefile && \
	make
ENV PATH=/opt/bedtools2/bin:${PATH}
RUN apt-get -y install bzip2
RUN cd /opt/ && \
	wget -O htslib-1.20.tar.bz2 "https://github.com/samtools/htslib/releases/download/1.20/htslib-1.20.tar.bz2" && \
	tar xvfj htslib-1.20.tar.bz2 && \
	cd htslib-1.20 && \
	make
ENV PATH=/opt/htslib-1.20:${PATH}
