#!/usr/bin/env bash

#
# tool for generating customized clusters, ie name, replicas, memory, etc...
#

mkdir -p build

# echo "generating build/spark-ui-proxy-controller.yaml"
# FN=spark-ui-proxy-controller.yaml
# sed "s/spark-master/ed-spark-master/" ./${FN} \
# | sed "s/: spark-ui-proxy/: ed-spark-ui-proxy/" \
# > build/$FN


echo "generating build/spark-master-service.yaml"
FN=spark-master-service.yaml
sed "s/spark-master/ed-spark-master/" ./${FN} \
> build/$FN


echo "generating build/spark-master-controller.yaml"
FN=spark-master-controller.yaml
sed "s/spark-master/ed-spark-master/" ./${FN} \
> build/$FN


echo "generating build/spark-worker-controller.yaml"
FN=spark-worker-controller.yaml
sed "s/spark-master/ed-spark-master/" ./${FN} \
| sed "s/spark-worker/ed-spark-worker/" \
> build/$FN


echo "generating build/zeppelin-controller.yaml"
FN=zeppelin-controller.yaml
sed "s/spark-master/ed-spark-master/" ./${FN} \
| sed "s/: zeppelin/: ed-zeppelin/" \
> build/$FN


