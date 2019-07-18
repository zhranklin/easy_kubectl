[中文README](./README_ZH.md)
# easy_kubectl
Easy to switch namespace of kubectl. And avoid the trouble of typing namespace every time.

## Install
```bash
source <(curl -fsSL https://raw.githubusercontent.com/zhranklin/easy_kubectl/master/install.sh)
```

To enable the [kubectl auto-completion(official)](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-autocomplete), you may install bash-completion, such like:

```bash
yum install -y bash-completion
```

Installation of bash-completion needs relogin.

## Usage
### Run kubectl command
```bash
$ k get po

---
kubectl -n default get po
No resources found.
```


### List namespaces

```bash
$ k

---
current: default
0: default
1: istio-system
2:
3:
4:
5:
6:
7:
8:
9:
```

### Switch namespace

```bash
$ k 1

---
namespace changed to:
1: istio-system
```

then run kubectl:

```bash
$ k get po

---
kubectl -n istio-system get po
NAME                                      READY     STATUS      RESTARTS   AGE
consul-debug-b94cd9d6c-hwbnv              1/1       Running     0          4d
consul-yx-798948c488-kkl7c                1/1       Running     0          5d
grafana-7dc68dd886-rrppp                  1/1       Running     0          6d
istio-citadel-84884f986d-jl6b2            1/1       Running     0          6d
istio-cleanup-secrets-1.1.3-qfs7w         0/1       Completed   0          6d
istio-egressgateway-68f59db69f-54gr6      1/1       Running     0          1h
istio-egressgateway-68f59db69f-f8rzb      1/1       Running     0          3h
istio-egressgateway-68f59db69f-xtq5n      1/1       Running     0          6d
istio-galley-58b44466c4-cp998             1/1       Running     0          6d
```

### Set and switch namespace
```bash
$ k

---
current:
0: default
1: istio-system
2:
3:
4:
5:
6:
7:
8:
9:
```

```bash
$ k 2 ns1

---
namespace changed to:
2: ns1
```

```bash
k

---
current: ns1
0: default
1: istio-system
2: ns1
3:
4:
5:
6:
7:
8:
9:
```

### Command hint

Interpolated command hint is output through stderr, not stdout:

```bash
k get pod -l istio=pilot -o jsonpath='{.items[0].metadata.name}'

---
kubectl -n istio-system get pod -l istio=pilot -o jsonpath={.items[0].metadata.name}
istio-pilot-5fb44ddbc-2wkkx
```

```bash
$ echo the pod name is $(k get pod -l istio=pilot -o jsonpath='{.items[0].metadata.name}').

---
kubectl -n istio-system get pod -l istio=pilot -o jsonpath={.items[0].metadata.name}
the pod name is istio-pilot-5fb44ddbc-2wkkx.
```

### Auto Completion
Auto completion is automatically enabled by `kubectl completion`, and the namespace will be set correctly.

```bash
$ k 1
---
namespace is now set to:
1: istio-system

$ k get po ist<TAB>
$ k get po istio-<TAB><TAB>
---
istio-citadel-7ff754d967-rx8f8           istio-ingressgateway-854bbb5c6c-jk7b5    istio-sidecar-injector-599cb6d6d4-86b6r
istio-egressgateway-847c9bd958-nxzqv     istio-pilot-6f94656b46-9bf9g             istio-telemetry-5c4867756d-2v4gf
istio-galley-6569cdd499-hdwp5            istio-policy-5cb5c594b6-92z5v            istio-tracing-f7cd46785-k8z6d

$ k get rs istio-<TAB><TAB>
---
istio-ingressgateway-854bbb5c6c    istio-policy-5cb5c594b6      istio-citadel-7ff754d967           
istio-sidecar-injector-599cb6d6d4  istio-tracing-f7cd46785      istio-egressgateway-847c9bd958
istio-pilot-6f94656b46             istio-galley-6569cdd499      istio-telemetry-5c4867756d
```

## MISC
### isapply
```bash
isapply <yaml file name>
```

equals to:

```bash
kubectl apply -f <(istioctl kube-inject -f <yaml file name>)
```
