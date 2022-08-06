#!/bin/bash

curl -L -o ~/kube-ps1.sh https://github.com/jonmosco/kube-ps1/raw/master/kube-ps1.sh

cat << EOF >> ~/.bashrc
alias ll='ls -alh --color=auto'
alias kon='touch ~/.kubeon; source ~/.bashrc; kubeon'
alias koff='rm -f ~/.kubeon; source ~/.bashrc; kubeoff'
alias k='kubectl'
alias kctl='kubectl'
alias kc='kubectx'
alias kn='kubens'
alias kt='kubetail'
alias ks='kubectl node-shell'
alias python='python3'
alias pip='pip3'
if [ -f ~/.kubeon ]; then
        source ~/kube-ps1.sh
        PS1='[\u@\h \W \$(kube_ps1)]\$ '
fi
EOF
