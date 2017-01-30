#!/usr/bin/env bash

#
# tool for generating customized clusters, ie name, replicas, memory, etc...
#
# 1- edit the PREFIX to create a unique spark cluster name
# 2- ./gen_new_cluster.sh
# 3- cd build && kubectl create -f .
#

PREFIX=${PREFIX:-zytest}
IMAGE_REPO=${IMAGE_REPO:-zzyin}
IMAGE_NAME=${IMAGE_NAME:-spark}
IMAGE_VERSION=${IMAGE_VERSION:-latest}

mkdir -p build

FN=spark-ui-proxy-controller.yaml
sed "s/spark-master/${PREFIX}-spark-master/" ./${FN} \
| sed "s/: spark-ui-proxy/: ${PREFIX}-spark-ui-proxy/" \
> build/$FN

FN=spark-master-service.yaml
sed "s/spark-master/${PREFIX}-spark-master/" ./${FN} \
> build/$FN

FN=spark-master-controller.yaml
sed "s/spark-master/${PREFIX}-spark-master/" ./${FN} \
| sed "s/navicore\/spark/${IMAGE_REPO}\/${IMAGE_NAME}/" \
| sed "s/1.6.2a/${IMAGE_VERSION}/" \
> build/$FN

FN=spark-worker-controller.yaml
sed "s/spark-master/${PREFIX}-spark-master/" ./${FN} \
| sed "s/spark-worker/${PREFIX}-spark-worker/" \
| sed "s/navicore\/spark/${IMAGE_REPO}\/${IMAGE_NAME}/" \
| sed "s/1.6.2a/${IMAGE_VERSION}/" \
> build/$FN

FN=zeppelin-controller.yaml
sed "s/spark-master/${PREFIX}-spark-master/" ./${FN} \
| sed "s/: zeppelin/: ${PREFIX}-zeppelin/" \
> build/$FN

