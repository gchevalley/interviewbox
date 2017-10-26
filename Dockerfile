FROM kdelfour/cloud9-docker

MAINTAINER gchevalley

RUN mkdir /setup
RUN chmod -R 777 /setup

RUN \
  apt-get -y update && \
  apt-get install -y \
  bzip2 \
  gdebi-core \
  git \
  libapparmor1 \
  libquantlib0 \
  r-base \
  r-base-dev \
  vim \
  wget \
  && apt-get clean

RUN \
  wget https://download2.rstudio.org/rstudio-server-1.1.383-amd64.deb \
  && gdebi -n rstudio-server-1.1.383-amd64.deb \
  && rm rstudio-server-1.1.383-amd64.deb

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

RUN \
  echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
  wget --quiet https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
  /bin/bash ~/miniconda.sh -b -p /opt/conda && \
  rm ~/miniconda.sh

RUN /opt/conda/bin/conda install python=3.5
RUN /opt/conda/bin/pip install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-1.3.0-cp35-cp35m-linux_x86_64.whl
ADD req_pip.txt /setup/req_pip.txt
RUN /opt/conda/bin/pip install -r /setup/req_pip.txt

RUN chmod -R 777 /opt/conda

RUN /opt/conda/bin/jupyter contrib nbextension install --user

RUN /opt/conda/bin/python -m spacy download en
RUN /opt/conda/bin/python -m nltk.downloader all

ENV PATH /opt/conda/bin:$PATH

ADD jupyter_notebook_config.py /root/.jupyter/jupyter_notebook_config.py

ENV SPARK_VERSION 2.2.0-bin-hadoop2.7
RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-${SPARK_VERSION}.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-${SPARK_VERSION} spark
# RUN wget --directory-prefix /tmp http://mirror.switch.ch/mirror/apache/dist/spark/spark-2.2.0/spark-2.2.0-bin-hadoop2.7.tgz
# RUN rm /tmp/spark-2.2.0-bin-hadoop2.7.tgz
ENV SPARK_HOME=/usr/local/spark
ENV PYTHON_DIR_PATH=$SPARK_HOME/python/
ENV PY4J_PATH=$SPARK_HOME/python/lib/py4j-0.10.4-src.zip
ENV PYTHONPATH=$PYTHON_DIR_PATH:$PY4J_PATH

ENV PATH /$SPARK_HOME/bin:$PATH

RUN (adduser --disabled-password --gecos "" guest && echo "guest:guest"|chpasswd)

EXPOSE 80 8182 8183 8184 8185 8787
