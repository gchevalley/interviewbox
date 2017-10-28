FROM gchevalley/cloud9

MAINTAINER gchevalley <gregory.chevalley@gmail.com>

RUN mkdir /setup
RUN chmod -R 777 /setup

RUN \
  apt-get update && \
  apt-get install -y \
    bzip2 \
    gdebi-core \
    git \
    libapparmor1 \
    libquantlib0v5 \
    vim \
    wget

RUN echo "mysql-server mysql-server/root_password password root" | debconf-set-selections
RUN echo "mysql-server mysql-server/root_password_again password root" | debconf-set-selections
RUN \
  apt-get update && \
  apt-get install -y \
    mysql-server && \
  mkdir -p /var/lib/mysql && \
  mkdir -p /var/run/mysqld && \
  mkdir -p /var/log/mysql && \
  chown -R mysql:mysql /var/lib/mysql && \
  chown -R mysql:mysql /var/run/mysqld && \
  chown -R mysql:mysql /var/log/mysql && \
  usermod -d /var/lib/mysql/ mysql

RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
RUN echo "deb [ arch=amd64,arm64 ] http://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list
RUN \
  apt-get update && \
  apt-get install -y mongodb-org
RUN \
  mkdir -p /data/db && \
  mkdir -p /var/lib/mongodb && \
  mkdir -p /var/log/mongodb && \
  chown -R mongodb:mongodb /data/db && \
  chown -R mongodb:mongodb /var/lib/mongodb && \
  chown -R mongodb:mongodb /var/log/mongodb && \
  usermod -d /data/db mongodb

RUN \
  apt-get update && \
  apt-get install -y \
    r-base \
    r-base-dev
RUN \
  wget https://download2.rstudio.org/rstudio-server-1.1.383-amd64.deb \
  && gdebi -n rstudio-server-1.1.383-amd64.deb \
  && rm rstudio-server-1.1.383-amd64.deb
RUN (adduser --disabled-password --gecos "" guest && echo "guest:guest"|chpasswd)

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

# https://github.com/keopx/docker-elasticsearch
RUN groupadd -r elasticsearch && useradd --no-log-init -r -g elasticsearch elasticsearch
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | apt-key add -
RUN echo "deb https://artifacts.elastic.co/packages/5.x/apt stable main" | tee -a /etc/apt/sources.list.d/elastic-5.x.list
RUN apt-get update && apt-get install elasticsearch

ENV PATH /usr/share/elasticsearch/bin:$PATH
WORKDIR /usr/share/elasticsearch
RUN set -ex \
  && for path in \
    ./data \
    ./logs \
    ./config \
    ./config/scripts \
    ; do \
      mkdir -p "$path"; \
      chown -R elasticsearch:elasticsearch "$path"; \
    done
COPY elasticsearch.yml ./config/elasticsearch.yml
COPY log4j2.properties ./config/log4j2.properties
VOLUME /usr/share/elasticsearch/data

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
ENV SPARK_HOME=/usr/local/spark
ENV PYTHON_DIR_PATH=$SPARK_HOME/python/
ENV PY4J_PATH=$SPARK_HOME/python/lib/py4j-0.10.4-src.zip
ENV PYTHONPATH=$PYTHON_DIR_PATH:$PY4J_PATH
ENV PATH /$SPARK_HOME/bin:$PATH

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

EXPOSE 80 3000 3306 5000 8000 8181 8182 8183 8184 8185 8787 9200 9300 27017
