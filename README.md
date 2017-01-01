# Spark on Kubernetes

A Kubernetes deployment of a stand-alone [Apache Spark](http://spark.apache.org/) cluster. 

With this setup, the spark UI is accessible via `kubectl` access - no new load balancers, no opening up any new external ports.

I created these files and howto doc to control the version of spark and to have control over the extra modules deployed on the workers.

Developed and tested on Azure ACS deployed via [acs-engine](https://github.com/Azure/acs-engine). (**WARNING**: I've broken the `gs://` support for now)

I presume you have your own working `kubectl` environment.

### Sources

* The k8s stuff is originally from [the k8s spark example](https://github.com/kubernetes/kubernetes/tree/master/examples/spark).
* The Docker images are at https://github.com/navicore/spark based on https://github.com/kubernetes/application-images/tree/master/spark.
* The Spark UI Proxy is https://github.com/aseigneurin/spark-ui-proxy.

## START HERE

```console
$ kubectl create -f spark-master-controller.yaml
replicationcontroller "spark-master-controller" created
```

```console
$ kubectl create -f spark-master-service.yaml
service "spark-master" created
```

```console
$ kubectl create -f spark-ui-proxy-controller.yaml
replicationcontroller "spark-ui-proxy-controller" created
```

```console
$ kubectl create -f spark-ui-proxy-service.yaml
service "spark-ui-proxy" created
```

for the kubernetes ui

```console
kubectl proxy --port=8001
```

for the spark ui

```console
kubectl port-forward spark-ui-proxy-controller-kg6an 8080:80
```

```console
$ kubectl create -f spark-worker-controller.yaml
replicationcontroller "spark-worker-controller" created
```

Done.

* follow link: [kube ui](http://localhost:8001/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard/#/service?namespace=default)
* follow link: [spark master ui](http://localhost:8080/proxy:spark-master:8080)

-------


