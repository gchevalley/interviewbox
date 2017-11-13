# Coding interview with [cloud9](https://c9.io) interface
based on the work of `docker pull kdelfour/cloud9-docker`

## setup
- python 3.5 (conda) + jupyter notebook
- pyspark
- oracle-java-8
- R + RStudio

## databases
- MySQL (doesn't start automatically: service mysql start )
- MongoDB (doesn't start automatically: /usr/bin/mongod --config /etc/mongodb.conf )
- elasticsearch (doesn't start automatically: service elasticsearch start )

## start container
`docker run -it -d -p 8181:8181 -p 8182:8182 -p 8183:8183 -p 8184:8184 -p 8185:8185 -p 8197:8787 -v <absoluteHostPath>:/workspace/ gchevalley/interviewbox`

## jupyter notebook (port `8182`)
`jupyter notebook password`

`jupyter notebook --allow-root`

