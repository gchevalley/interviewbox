FROM kdelfour/cloud9-docker

MAINTAINER gchevalley

RUN mkdir /setup
RUN chmod -R 777 /setup

ADD req_pip.txt /setup/req_pip.txt

RUN apt-get -y update && \
	apt-get install -y \
	bzip2 \
	git \
	r-base \
	vim \
	wget \
	&& apt-get clean

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

RUN /opt/conda/bin/conda install python=3.5
RUN /opt/conda/bin/pip install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.3.0-cp35-cp35m-linux_x86_64.whl
RUN /opt/conda/bin/pip install -r /setup/req_pip.txt

RUN chmod -R 777 /opt/conda

RUN /opt/conda/bin/jupyter contrib nbextension install --user

RUN /opt/conda/bin/python -m spacy download en

ENV PATH /opt/conda/bin:$PATH

RUN \
  apt-get update && \
  apt-get install -y software-properties-common && \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

ADD jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py

EXPOSE 80 8182 8183 8184 8185
