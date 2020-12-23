# easy_kubectl
easy_kubectl旨在执行kubectl命令的时候解放我们的双手, 避免每次输入namespace的烦恼, 支持原生命令行补全, 再也不用手动复制pod name了!

## 安装
```bash
tag=1.0.13
source <(curl -fsSL https://github.com/zhranklin/easy_kubectl/archive/$tag.tar.gz | tar xzO easy_kubectl-$tag/install.sh)
```

如果要开启[补全(来自官方)](https://kubernetes.io/docs/reference/kubectl/cheatsheet/#kubectl-autocomplete), 需要执行类似下面的命令来安装bash-completion:

```bash
yum install -y bash-completion
```

bash-completion的安装需要重新登录才能生效。

## 更新
安装完easy_kubectl后, 命令行执行update_k即可更新easy_kubectl

## 使用方法
### 选择namespace
![](https://github.com/zhranklin/easy_kubectl/blob/media/media/ek1.gif)

有两种选择方法:

1. `k+回车`, 然后搜索namespace, 支持fuzzy search(基于[fzf](https://github.com/junegunn/fzf))
2. `k <关键字>`, 如果匹配到唯一结果, 则会直接选中

### 执行命令
用k代替kubectl, 执行kubectl命令, 不需要输入namespace

![](https://github.com/zhranklin/easy_kubectl/blob/media/media/ek2.gif)

### 自动补全
![](https://github.com/zhranklin/easy_kubectl/blob/media/media/ek4.gif)

### 设置context
如需设置kubectl命令的`--context`, 则执行`k c <context>`

![](https://github.com/zhranklin/easy_kubectl/blob/media/media/ek3.gif)

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
