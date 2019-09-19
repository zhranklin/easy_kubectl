#!/bin/bash
FILE=~/.easy_kubectl/compl
kubectl completion bash > $FILE

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
sed -i $LINE'iecho "-n=$KUBE_NS"' $FILE

source $FILE
