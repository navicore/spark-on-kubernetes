# Spark example

Following this example, you will create a functional [Apache
Spark](http://spark.apache.org/) cluster using Kubernetes and
[Docker](http://docker.io).

You will setup a Spark master service and a set of Spark workers using Spark's [standalone mode](http://spark.apache.org/docs/latest/spark-standalone.html).

For the impatient expert, jump straight to the [tl;dr](#tldr)
section.

### Sources

The Docker images are heavily based on https://github.com/mattf/docker-spark.
And are curated in https://github.com/kubernetes/application-images/tree/master/spark

The Spark UI Proxy is taken from https://github.com/aseigneurin/spark-ui-proxy.

The PySpark examples are taken from http://stackoverflow.com/questions/4114167/checking-if-a-number-is-a-prime-number-in-python/27946768#27946768

## Start your Master service

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

```console
kubectl proxy --port=8001
```

At which point the UI will be available at
[spark master ui](http://localhost:8001/api/v1/proxy/namespaces/default/services/spark-master:8080/).

```console
$ kubectl create -f spark-worker-controller.yaml
replicationcontroller "spark-worker-controller" created
```

```console
$ kubectl get pods
NAME                            READY     STATUS    RESTARTS   AGE
spark-master-controller-5u0q5   1/1       Running   0          25m
spark-worker-controller-e8otp   1/1       Running   0          6m
spark-worker-controller-fiivl   1/1       Running   0          6m
spark-worker-controller-ytc7o   1/1       Running   0          6m

$ kubectl logs spark-master-controller-5u0q5
[...]
15/10/26 18:20:14 INFO Master: Registering worker 10.244.1.13:53567 with 2 cores, 6.3 GB RAM
15/10/26 18:20:14 INFO Master: Registering worker 10.244.2.7:46195 with 2 cores, 6.3 GB RAM
15/10/26 18:20:14 INFO Master: Registering worker 10.244.3.8:39926 with 2 cores, 6.3 GB RAM
```

-------

## Start the Zeppelin UI to launch jobs on your Spark cluster

The Zeppelin UI pod can be used to launch jobs into the Spark cluster either via
a web notebook frontend or the traditional Spark command line. See
[Zeppelin](https://zeppelin.incubator.apache.org/) and
[Spark architecture](https://spark.apache.org/docs/latest/cluster-overview.html)
for more details.

Deploy Zeppelin:

```console
$ kubectl create -f examples/spark/zeppelin-controller.yaml
replicationcontroller "zeppelin-controller" created
```

And the corresponding service:

```console
$ kubectl create -f examples/spark/zeppelin-service.yaml
service "zeppelin" created
```

Zeppelin needs the spark-master service to be running.

### Check to see if Zeppelin is running

```console
$ kubectl get pods -l component=zeppelin
NAME                        READY     STATUS    RESTARTS   AGE
zeppelin-controller-ja09s   1/1       Running   0          53s
```

## Step Five: Do something with the cluster

Now you have two choices, depending on your predilections. You can do something
graphical with the Spark cluster, or you can stay in the CLI.

For both choices, we will be working with this Python snippet:

```python
from math import sqrt; from itertools import count, islice

def isprime(n):
    return n > 1 and all(n%i for i in islice(count(2), int(sqrt(n)-1)))

nums = sc.parallelize(xrange(10000000))
print nums.filter(isprime).count()
```

### Do something fast with pyspark!

Simply copy and paste the python snippet into pyspark from within the zeppelin pod:

```console
$ kubectl exec zeppelin-controller-ja09s -it pyspark
Python 2.7.9 (default, Mar  1 2015, 12:57:24)
[GCC 4.9.2] on linux2
Type "help", "copyright", "credits" or "license" for more information.
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /__ / .__/\_,_/_/ /_/\_\   version 1.5.1
      /_/

Using Python version 2.7.9 (default, Mar  1 2015 12:57:24)
SparkContext available as sc, HiveContext available as sqlContext.
>>> from math import sqrt; from itertools import count, islice
>>>
>>> def isprime(n):
...     return n > 1 and all(n%i for i in islice(count(2), int(sqrt(n)-1)))
...
>>> nums = sc.parallelize(xrange(10000000))

>>> print nums.filter(isprime).count()
664579
```

Congratulations, you now know how many prime numbers there are within the first 10 million numbers!

### Do something graphical and shiny!

Creating the Zeppelin service should have yielded you a Loadbalancer endpoint:

```console
$ kubectl get svc zeppelin -o wide
 NAME       CLUSTER-IP   EXTERNAL-IP                                                              PORT(S)   AGE       SELECTOR
zeppelin   10.0.154.1   a596f143884da11e6839506c114532b5-121893930.us-east-1.elb.amazonaws.com   80/TCP    3m        component=zeppelin
```

If your Kubernetes cluster does not have a Loadbalancer integration, then we will have to use port forwarding.

Take the Zeppelin pod from before and port-forward the WebUI port:

```console
$ kubectl port-forward zeppelin-controller-ja09s 8080:8080
```

This forwards `localhost` 8080 to container port 8080. You can then find
Zeppelin at [http://localhost:8080/](http://localhost:8080/).

Once you've loaded up the Zeppelin UI, create a "New Notebook". In there we will paste our python snippet, but we need to add a `%pyspark` hint for Zeppelin to understand it:

```
%pyspark
from math import sqrt; from itertools import count, islice

def isprime(n):
    return n > 1 and all(n%i for i in islice(count(2), int(sqrt(n)-1)))

nums = sc.parallelize(xrange(10000000))
print nums.filter(isprime).count()
```

After pasting in our code, press shift+enter or click the play icon to the right of our snippet. The Spark job will run and once again we'll have our result!

## Result

You now have services and replication controllers for the Spark master, Spark
workers and Spark driver.  You can take this example to the next step and start
using the Apache Spark cluster you just created, see
[Spark documentation](https://spark.apache.org/documentation.html) for more
information.

## tl;dr

```console
kubectl create -f examples/spark
```

After it's setup:

```console
kubectl get pods # Make sure everything is running
kubectl get svc -o wide # Get the Loadbalancer endpoints for spark-ui-proxy and zeppelin
```

At which point the Master UI and Zeppelin will be available at the URLs under the `EXTERNAL-IP` field.

You can also interact with the Spark cluster using the traditional `spark-shell` /
`spark-subsubmit` / `pyspark` commands by using `kubectl exec` against the
`zeppelin-controller` pod.

If your Kubernetes cluster does not have a Loadbalancer integration, use `kubectl proxy` and `kubectl port-forward` to access the Spark UI and Zeppelin.

For Spark UI:

```console
kubectl proxy --port=8001
```

Then visit [http://localhost:8001/api/v1/proxy/namespaces/spark-cluster/services/spark-ui-proxy/](http://localhost:8001/api/v1/proxy/namespaces/spark-cluster/services/spark-ui-proxy/).

For Zeppelin:

```console
kubectl port-forward zeppelin-controller-abc123 8080:8080 &
```

Then visit [http://localhost:8080/](http://localhost:8080/).

