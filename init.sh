#!/bin/bash
VARIABLES_FN=~/.easy_kubectl/variables.sh
function isapply() {
  kubectl apply -f <(istioctl kube-inject -f $1)
}

function k() {
  if [ $# -eq 0 ]; then
    echo current: $KUBE_NS
    for i in `seq 0 9`; do
      echo $i: `eval echo '$KUBE_NS'$i`
    done  
  elif [[ $1 =~ [0-9] ]]; then
    varname='$KUBE_NS'$1
    if [[ -n $2 ]]; then
      eval "export "'KUBE_NS'"$1=$2"
    fi
    export KUBE_NS=`eval echo $varname`
    echo namespace is now set to:
    echo $1: $KUBE_NS
    easy_kubectl_export_variables $VARIABLES_FN
  else
    echo kubectl -n $KUBE_NS $@ >&2
    kubectl -n $KUBE_NS $@
  fi
}

function easy_kubectl_export_variables() {
  fn=$1
  echo export KUBE_NS=$KUBE_NS > $fn
  for i in `seq 0 9`; do
    echo export KUBE_NS$i=`eval echo '$KUBE_NS'$i` >> $fn
  done  
}
source $VARIABLES_FN
