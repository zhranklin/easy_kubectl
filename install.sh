function easy_kube_install_main() {
  cd $HOME
  for fn in .zshrc .bashrc; do
    if [ -f $fn ];then
      if [ `grep -c "easy_kubectl" $fn` -eq '0' ]; then
        echo 'source $HOME/.easy_kubectl/init.sh' >> $fn
      fi
    fi
  done
  mkdir -p .easy_kubectl
  cd $HOME/.easy_kubectl
  curl -fsSL https://raw.githubusercontent.com/zhranklin/easy_kubectl/master/init.sh > init.sh
  curl -fsSL https://raw.githubusercontent.com/zhranklin/easy_kubectl/master/load_kube_complete.sh > load_kube_complete.sh
}
(easy_kube_install_main) && source ~/.easy_kubectl/init.sh
k 0 default
echo successfully installed easy_kubectl!
