#!/bin/bash
function isapply() {
  kubectl apply -f <(istioctl kube-inject -f $1) -n $2
}

function k() {
  if [ $# -eq 0 ]; then
    echo current: $NS
    for i in `seq 0 9`; do
      echo $i: `eval echo '$KUBE_NS'$i`
    done  
  elif [[ $1 =~ [0-9] ]]; then
    varname='$KUBE_NS'$1
    if [[ -n $2 ]]; then
      eval "export "'KUBE_NS'"$1=$2"
    fi
    export KUBE_NS=`eval echo $varname`
    echo namespace changed to:
    echo $1: $KUBE_NS
  else
    kubectl -n $KUBE_NS $@
  fi
}
