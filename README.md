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
$ kubectl create -f spark-worker-controller.yaml
replicationcontroller "spark-worker-controller" created
```

Done.

... Unless you want access to the UIs.  In that case:

```console
$ kubectl create -f spark-ui-proxy-controller.yaml
replicationcontroller "spark-ui-proxy-controller" created
```

```console
$ kubectl create -f zeppelin-controller.yaml
replicationcontroller "zeppelin-controller" created
```

Done.

... Unless you also want to actually use the UIs.  In that case:

* for the kubernetes ui

  ```console
  kubectl proxy --port=8001
  ```
  and follow link: [kube ui](http://localhost:8001/api/v1/proxy/namespaces/kube-system/services/kubernetes-dashboard/#/service?namespace=default)

* for the spark ui

  ```console
  kubectl port-forward spark-ui-proxy-controller-<POD-ID> 8080:80
  ```
  and follow link: [spark master ui](http://localhost:8080/proxy:spark-master:8080)

* for the zeppelin ui
  ```console
  kubectl port-forward zeppelin-controller-sq7z5 8081:8080
  ```
  and follow link: [zeppeline ui](http://localhost:8081)

## Submit a Job

example from an sbt project with an assembly task

```console
sbt assembly && kubectl exec -i spark-master-controller-<ID> -- /bin/bash -c 'cat > my.jar && /opt/spark/bin/spark-submit --deploy-mode client --master spark://spark-master:7077 --class my.Main ./my.jar' < target/scala-2.10/*.jar
```

## CHEAT

don't look or think, just do `kubectl create -f .`

-------

## Customize

Use the `gen_new_cluster.sh` script to create new standalone spark clusters
that can run safely within the same kubernetes subnet.  The script changes the
name of the master used by the rest of the containers - no kube namespace used.

```
PREFIX="my-fav-cluster" ./gen_new_cluster.sEFIX="my" ./gen_new_cluster.sh
```

Then, `cd build`, edit the files to adjust replica counts, ports, memory, etc..., and deploy `kubectl create -f .`.

