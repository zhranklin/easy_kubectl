SCRIPT=$0
function get_fzf_url() {
  archi=$(uname -sm)
  target=$FZF_TARGET
  ext=
  binary_error=""
  if [[ $target == "" ]]; then
    case "$archi" in
      Darwin\ arm64)   target=darwin_arm64     ;;
      Darwin\ x86_64)  target=darwin_amd64     ;;
      Linux\ armv5*)   target=linux_armv5      ;;
      Linux\ armv6*)   target=linux_armv6      ;;
      Linux\ armv7*)   target=linux_armv7      ;;
      Linux\ armv8*)   target=linux_arm64      ;;
      Linux\ aarch64*) target=linux_arm64      ;;
      Linux\ *64)      target=linux_amd64      ;;
      FreeBSD\ *64)    target=freebsd_amd64    ;;
      OpenBSD\ *64)    target=openbsd_amd64    ;;
      CYGWIN*\ *64)    target=windows_amd64    ;;
      MINGW*\ *64)     target=windows_amd64    ;;
      MSYS*\ *64)      target=windows_amd64    ;;
      Windows*\ *64)   target=windows_amd64    ;;
    esac
  fi
  case "$target" in
    darwin_*)  ext=zip    ;;
    windows_*) ext=zip    ;;
    *)         ext=tar.gz ;;
  esac
  echo https://github.com/junegunn/fzf/releases/download/0.30.0/fzf-0.30.0-$target.$ext
}

function gen_offline_script() {
  echo "test -d ~/.easy_kubectl || mkdir ~/.easy_kubectl"
  echo "base64 -d <<\EEOOFF | gunzip > ~/.easy_kubectl/fzf"
  wget -qO - $(get_fzf_url) | tar xzO | gzip | base64 -w 128
  echo EEOOFF
  echo "chmod +x ~/.easy_kubectl/fzf"
  cat "$SCRIPT"
}

function easy_kube_install_main() {
  cd $HOME
  for fn in .bashrc; do  # add .zshrc after resolving all relevant issues
    if [ -f $fn ]; then
      if [ $(grep -c "easy_kubectl" $fn) -eq '0' ]; then
        echo 'source $HOME/.easy_kubectl/init.sh' >> $fn
      fi
    fi
  done
  mkdir -p .easy_kubectl
  cd $HOME/.easy_kubectl
  touch $HOME/.easy_kubectl/.history
  touch $HOME/.easy_kubectl/fzf.1
  touch $HOME/.easy_kubectl/variables.sh
  if [ ! -f $HOME/.easy_kubectl/fzf ];then
    wget -qO - $(get_fzf_url) | tar xzO > $HOME/.easy_kubectl/fzf.1
    chmod +x $HOME/.easy_kubectl/fzf.1
    mv $HOME/.easy_kubectl/fzf.1 $HOME/.easy_kubectl/fzf
  fi
  cat <<\EOF > init.sh
#!/bin/bash
sh_name=
if [[ -n "${BASH_VERSION}" ]]; then
  sh_name="bash"
elif [[ -n "${ZSH_VERSION}" ]]; then
  sh_name="zsh"
else
  # SHELL is only set by login, so when we switch from bash to zsh
  # we still get the "bash" value of this var
  sh_name=$(echo "$SHELL" | awk -F/ '{print $NF}')
fi
BASE_PATH=~/.easy_kubectl
VARIABLES_FN=$BASE_PATH/variables.sh
function isapply() {
  kubectl apply -f <(istioctl kube-inject -f $1)
}

function __k_add_history() {
  HISTORY=$HOME/.easy_kubectl/.history
  sed -i '/^'$1'$/d' $HISTORY
  echo $1 >> $HISTORY
}

function __easy_kubectl_export_variables() {
  fn=$1
  echo export KUBE_NS=$KUBE_NS > $fn
  echo export KUBE_CONTEXT=$KUBE_CONTEXT >> $fn
  for i in `seq 0 100`; do
    echo export KUBE_NS$i=`eval echo '$KUBE_NS'$i` >> $fn
  done
}

function k() {
  if [[ $1 = c ]]; then
    C_QUERY=""
    CXTS="<NONE> $(kubectl config view -o jsonpath='{.contexts[*].name}')"
    if [[ -n "$2" ]]; then
      C_QUERY="--query=$2 -1 -0"
    fi
    NEW_CXT=$(echo "$CXTS" | sed "s/ /\n/g; s/<NONE>/ /g" |bash -c "$HOME/.easy_kubectl/fzf --no-mouse --prompt=\"search for context: \" --tiebreak=end,index -i $C_QUERY")
    UNCHANGED="(unchanged)"
    if [[ $NEW_CXT != "" ]]; then
      export KUBE_CONTEXT=$NEW_CXT
      UNCHANGED=""
      __easy_kubectl_export_variables $VARIABLES_FN
    fi
    if [[ $KUBE_CONTEXT = " " ]]; then
      export KUBE_CONTEXT=
      echo -e "Current Context$UNCHANGED:\n''"
    else
      echo -e "Current Context$UNCHANGED:\n$KUBE_CONTEXT"
    fi
    __easy_kubectl_export_variables $VARIABLES_FN
  elif [[ $# -lt 2 ]]; then
    NSS="$(kubectl get ns --context=$KUBE_CONTEXT -ojsonpath='{.items[*].metadata.name}'|tr ' ' '\n')"
    for ns in $(cat $HOME/.easy_kubectl/.history); do
      if echo "$NSS"|grep -qE "^$ns\$"; then
        NSS="$ns
$(echo "$NSS"|sed '/^'$ns'$/d' )" 
      fi
    done
    QUERY=""
    word=$(echo $1|sed -r 's/([A-Z])$/\l\1./g; s/^([A-Z])/.\l\1/g; s/([a-zA-Z0-9])[\[\.:,]$/\l\1./g; s/^[\[\.:,]([a-zA-Z0-9])/.\l\1/g;')
    GREP_PREFIX="grep -iE ^$(echo $word|sed -nr 's/^\.([a-zA-Z0-9]).*/\l\1/p')"
    GREP_POSTFIX="grep -iE $(echo $word|sed -nr 's/.*([a-zA-Z0-9])\.$/\l\1/p')\$"
    word=$(echo $word|sed 's/\.$//g; s/^\.//g')
    if [[ -n $1 ]]; then
      QUERY="--query=$word -1 -0"
    fi
    NEW_NS=$(echo "$NSS"|bash -c "$GREP_PREFIX|$GREP_POSTFIX|$HOME/.easy_kubectl/fzf --no-mouse --prompt=\"search for namespace: \" --tiebreak=end,index -i $QUERY")
    UNCHANGED="(unchanged)"
    if [[ $NEW_NS != "" ]]; then
      export KUBE_NS=$NEW_NS
      __k_add_history $NEW_NS
      UNCHANGED=""
      __easy_kubectl_export_variables $VARIABLES_FN
    fi
    CONTEXT_STR=""
    if [[ $KUBE_CONTEXT != "" ]]; then
      CONTEXT_STR=$KUBE_CONTEXT/
    fi
    echo -e "Current Namespace$UNCHANGED:\n$CONTEXT_STR$KUBE_NS"
  else
    if [[ $KUBE_CONTEXT = "" ]]; then
      echo kubectl -n $KUBE_NS $@ >&2
      kubectl -n $KUBE_NS $@
    else
      echo kubectl -n $KUBE_NS --context=$KUBE_CONTEXT $@ >&2
      kubectl -n $KUBE_NS --context=$KUBE_CONTEXT $@
    fi
  fi
}

function p() {
  ip=$(kubectl -n $KUBE_NS --context=$KUBE_CONTEXT get svc powerful-cases -ojsonpath='{.spec.clusterIP}')
  
  if [[ $# = "0" ]]; then
    c=$(cat)
    curl $ip/y -d "$c"
  elif [[ $# = "1" && $1 != /* ]]; then
    curl $ip/y -d "$1"
  else
    path=$1
    shift 1

    array=()
    for ((i=1;i<=$#;i++)); do
      array[${i}]="${!i}"
    done
    curl $ip$path "${array[@]}"
  fi

  echo
}

function update_k() {
  tag=$(curl https://api.github.com/repos/zhranklin/easy_kubectl/releases/latest -s|grep tag_name|sed 's/.*tag_name": "//g; s/",.*//g')
  echo updating to version: v$tag
  source <(curl -fsSL https://github.com/zhranklin/easy_kubectl/archive/$tag.tar.gz | tar xzO easy_kubectl-$tag/install.sh)
}

test -f "$VARIABLES_FN" && source $VARIABLES_FN

COMPLETE_FN=$BASE_PATH/load_kube_complete.sh
source $COMPLETE_FN
source <(kubectl completion ${sh_name:-bash})

EOF
cat <<\EOF > load_kube_complete.sh
#!/bin/bash
# sh_name=$(echo "$SHELL" | awk -F/ '{print $NF}')  # set by caller
FILE=~/.easy_kubectl/compl_${sh_name}
kubectl completion ${sh_name:-bash} > $FILE

if [[ ${sh_name} == "bash" ]]; then
  if ! type __start_kubectl 1>/dev/null 2>&1; then
    source <(kubectl completion bash)
  fi
  if grep "bash completion V2 for kubectl" $FILE 1>/dev/null 2>&1; then
    sed -i '/\s\b__start_kubectl\b\s/s/\bkubectl\b/k/g' $FILE
    sed -i 's/_kubectl/_k_kubectl/g' $FILE
    LINE=$(sed -n -e '/requestComp="${words\[0\]} /=' $FILE)
    sed -i $LINE'iif [ -n "$KUBE_NS" ]; then prefix_flags="${prefix_flags} --namespace=${KUBE_NS}"; fi' $FILE
    sed -i $LINE'iif [ -n "$KUBE_CONTEXT" ]; then prefix_flags="${prefix_flags} --context=${KUBE_CONTEXT}"; fi' $FILE
    sed -i $LINE'iprefix_flags=' $FILE
    sed -i '/requestComp=/s/${words\[0\]}/kubectl/g' $FILE
    sed -i 's/__completeNoDesc/__completeNoDesc ${prefix_flags\[*\]} /g' $FILE
  else
    LINE=$(sed -n -e '/__kubectl_override_flag_list=/=' $FILE)
    sed -i ${LINE}'s/ \(--namespace\|-n\)//g' $FILE

    for i in $(sed -n -e '/complete.*__start_kubectl.*kubectl/=' $FILE); do
      sed -i $i's/\bkubectl\b/k/g' $FILE
    done

    #查找__kubectl_override_flags()的行号
    LINE=$(sed -n -e '/__kubectl_override_flags()/=' $FILE)
    #查找__kubectl_override_flags()函数结尾
    LINE=$(sed -n -e '1,'$LINE'd;/^\s*\}\s*$/=' $FILE | head -1)
    #加入代码
    sed -i $LINE'iif [ -n "$KUBE_NS" ]; then echo -n "-n=$KUBE_NS "; fi' $FILE
    sed -i $LINE'iif [ -n "$KUBE_CONTEXT" ]; then echo -n "--context=$KUBE_CONTEXT "; fi' $FILE

    sed -i 's/__custom_func/__k_custom_func/g' $FILE
    sed -i 's/_kubectl/_k_kubectl/g' $FILE
  fi
elif [[ ${sh_name} == "zsh" ]]; then
  if ! type _kubectl 1>/dev/null 2>&1; then
    source <(kubectl completion zsh)
  fi
  sed -i '/\s\b_kubectl\b\s/s/\bkubectl\b/k/g' $FILE
  sed -i 's/_kubectl/_k_kubectl/g' $FILE
  sed -i '/requestComp=/s/${words\[1\]}/kubectl/g' $FILE
fi

source $FILE

EOF
}
if [[ $GEN_OFFLINE == "1" ]]; then
  gen_offline_script
else
  (easy_kube_install_main) && source ~/.easy_kubectl/init.sh
  k '^default$'
  echo successfully installed easy_kubectl!
fi
