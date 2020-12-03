# easy_kubectl
easy_kubectl旨在执行kubectl命令的时候解放我们的双手, 避免每次输入namespace的烦恼, 支持原生命令行补全, 再也不用手动复制pod name了!

## 安装
```bash
source <(curl -fsSL https://github.com/zhranklin/easy_kubectl/archive/master.tar.gz | tar xzO easy_kubectl-master/install.sh)
```

如果要开启[补全(来自官方)](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-autocomplete), 需要执行类似下面的命令来安装bash-completion:

```bash
yum install -y bash-completion
```

bash-completion的安装需要重新登录才能生效。

## 使用方法
### 执行kubectl命令

用`k`来代替`kubectl`命令, 并去掉平时声明的`-n xxx`参数即可

```bash
$ k get po

---
kubectl -n default get po
No resources found.
```

### namespace管理: 列出已有的namespace
直接执行`k`即可列出已有的namespace, 如果没有使用过easy_kubectl, 得到的结果如下

```bash
$ k

---
current: default
0: default
1:
2:
3:
4:
5:
6:
7:
8:
9:
```

### 新增并设置当前namespace
先看一下原来保存的namespace

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

执行`k <数字> <namespace>`, 将当前的ns切换到输入的ns, 并与指定的数字绑定, 数字的用途见下一章

```bash
$ k 2 ns1

---
namespace changed to:
2: ns1
```

至此, 每次通过`k`执行kubectl命令, 都会被自动加上`-n ns1`参数:

```bash
$ k get po

---
kubectl -n ns1 get po
No resources found.
```

### 切换当前namespace

执行`k`, 可以发现由于之前执行过`k 2 ns1`, 输出中显示`2: ns1`

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

此时直接执行`k 2`即可切换到ns1:

```bash
$ k 2

---
namespace changed to:
2: ns1
```

如果要切换到istio-system, 则执行`k 1`:

```bash
$ k 1

---
namespace changed to:
1: istio-system
```

这时候执行`k get po`就相当于执行`kubectl -n istio-system get po`:

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

### 命令提示

每次执行`k`命令会输出实际执行命令的提示:

```bash
k get pod -l istio=pilot -o jsonpath='{.items[0].metadata.name}'

---
kubectl -n istio-system get pod -l istio=pilot -o jsonpath={.items[0].metadata.name}
istio-pilot-5fb44ddbc-2wkkx
```

由于通过stderr而不是stdout输出命令提示, 不会影响到类似于$(xxx) `xxx`之类的用法:

```bash
$ k get po  $(k get pod -l istio=pilot -o jsonpath='{.items[0].metadata.name}')

---
kubectl -n istio-system get pod -l istio=pilot -o jsonpath={.items[0].metadata.name}
kubectl -n istio-system get po istio-pilot-7c949bbc49-2qd4n
NAME                           READY     STATUS    RESTARTS   AGE
istio-pilot-7c949bbc49-2qd4n   2/2       Running   0          3h
```

输出中前两行为easy_kubectl给的提示, 后两行为实际命令输出

### 自动补全
easy_kubectl支持自动补全, 自动补全是通过对`kubectl completion`命令输出的脚本进行小幅修改而生效的, easy_kubectl会根据当前设置的namespace进行自动补全:

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
附加了一个isapply命令, 用于istio手动注入sidecar:

```bash
isapply <yaml file name>
```

相当于:

```bash
kubectl apply -f <(istioctl kube-inject -f <yaml file name>)
```
