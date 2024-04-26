
limactl start k3s-dev.yaml &

 export KUBECONFIG="$HOME/.lima/k3s-dev/copied-from-guest/kubeconfig.yaml"

sleep 60

kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml

echo "Waiting for MetalLB"

kubectl -n metallb-system wait deploy --all --for condition=Available --timeout 2m

kubectl apply -f metallb-ip.yaml

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
kubectl patch deployment \
  argocd-server \
  --namespace argocd \
  --type='json' \
  -p='[{"op": "replace", "path": "/spec/template/spec/containers/0/args", "value": [
  "/usr/local/bin/argocd-server",
  "--disable-auth"
]}]'

kubectl -n argocd wait deploy --all --for condition=Available --timeout 2m

kubectl apply -f argo-init.yaml



