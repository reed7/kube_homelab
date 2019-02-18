kubeadm init --token-ttl=0

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

sysctl net.bridge.bridge-nf-call-iptables=1

curl -L git.io/weave -o /usr/local/bin/weave && chmod a+x /usr/local/bin/weave

kubectl taint nodes --all node-role.kubernetes.io/master-
