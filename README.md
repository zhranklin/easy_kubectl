# [中文README](./README_ZH.md)

# easy_kubectl
Easy to switch namespace of kubectl. And avoid the trouble of typing namespace every time.

## Install
```bash
tag=1.0.15
source <(curl -fsSL https://github.com/zhranklin/easy_kubectl/archive/$tag.tar.gz | tar xzO easy_kubectl-$tag/install.sh)
```

To enable the [kubectl auto-completion(official)](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-autocomplete), you may install bash-completion, such like:

```bash
yum install -y bash-completion
```

Installation of bash-completion needs relogin.

## Update
Just run `update_k`

## Usage
### Select namespace
![](https://github.com/zhranklin/easy_kubectl/blob/media/media/ek1.gif)

There are two ways:

1. `k+Enter`, then search namespace, it supports fuzzy search(Powered by [fzf](https://github.com/junegunn/fzf)).
2. `k <keyword>`, if only one result matched, the result will be selected.

### Execute command
Replace kubectl with k and execute kubectl command without specifying namespace.

![](https://github.com/zhranklin/easy_kubectl/blob/media/media/ek2.gif)

### Autocompletion
![](https://github.com/zhranklin/easy_kubectl/blob/media/media/ek4.gif)

### Select context
If `--context` flag should be set, run `k c <context>`

![](https://github.com/zhranklin/easy_kubectl/blob/media/media/ek3.gif)

### Command hint

Interpolated command hint is printed through stderr, not stdout:

```bash
k get pod -l istio=pilot -o jsonpath='{.items[0].metadata.name}'

---
kubectl -n istio-system get pod -l istio=pilot -o jsonpath={.items[0].metadata.name}
istio-pilot-5fb44ddbc-2wkkx
```

It's printed to stderr, so the grammar like $(xxx) `xxx` will be still fine:

```bash
$ k get po  $(k get pod -l istio=pilot -o jsonpath='{.items[0].metadata.name}')

---
kubectl -n istio-system get pod -l istio=pilot -o jsonpath={.items[0].metadata.name}
kubectl -n istio-system get po istio-pilot-7c949bbc49-2qd4n
NAME                           READY     STATUS    RESTARTS   AGE
istio-pilot-7c949bbc49-2qd4n   2/2       Running   0          3h
```

First 2 lines are the hints and the last 2 lines are the output of kubectl.
