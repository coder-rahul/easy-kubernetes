#!/bin/bash

#Setup kubernetes utilities
cat > /root/setup_kubernetes.sh << EOF2
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
EOF2

sudo apt install sshpass

chmod 777 /root/setup_kubernetes.sh

#Installing kubernetes
sudo /root/setup_kubernetes.sh

if [ "$HOSTNAME" == "master-1" ]; then
  
  #Initializing kubeadm
  sudo kubeadm init --pod-network-cidr=10.32.0.0/12 --apiserver-advertise-address=192.168.5.11

  # Configuring kubeconfig for kubectl to access the api-server.
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  
  #mkdir -p /home/vagrant/.kube
  #chmod -R 777 /home/vagrant/.kube
  #cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
  #chown `id -u vagrant`:`id -g vagrant` /home/vagrant/.kube/config
  
  sleep 5
  
  # Configure Networking.
  #kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
  kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
  
  kubectl taint nodes --all node-role.kubernetes.io/master-
  
else
  
  mkdir -p $HOME/.kube
  sshpass -p "root" scp root@master-1:/root/.kube/config $HOME/.kube/
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  #chown `id -u vagrant`:`id -g vagrant` /home/vagrant/.kube/config
  TOKEN=$(kubeadm token generate)
  kubeadm token create $TOKEN --print-join-command | tee /root/join_cluster.sh
  chmod +x /root/join_cluster.sh
  sudo /root/join_cluster.sh
  
fi
