FROM ubuntu:22.04
# update apt
RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC  apt-get -y install openjdk-17-jdk
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC  apt-get -y install make
RUN DEBIAN_FRONTEND=noninteractive TZ=Etc/UTC  apt-get -y install git
RUN cd /opt/ && \
	git clone -b dev "https://github.com/lindenb/jvarkit.git" jvarkit.tmp && \
	cd jvarkit.tmp && git reset --hard HEAD && make && cd .. && \
	mv "jvarkit.tmp" "/opt/jvarkit"
ENV JVARKIT_DIST=/opt/jvarkit/dist
