# Kubflog

Kubflog is a simple tool for logging Kubernetes cluster events. Just use kubectl and fzf to search for events and then pipe them to kubflog.

## Prerequisites

- kubectl
- kubectx
- fzf
- jq

## Installation
### Install prerequisites tools
```bash
brew install fzf jq kubectl kubectx
```

```bash
# clone this repository
git clone https://github.com/Thirawoot-Put/kubflog
cd kubflog
chmod +x kubflog.sh # make it executable

# optional for clean use: add kubflog to your bin directory and path
mkdir -p ~/bin
cp kubflog.sh ~/bin/kubflog
echo 'export PATH="$HOME/bin:$PATH"' >> ~/.zshrc # or ~/.bashrc
source ~/.zshrc # or ~/.bashrc
# then use by just typing kubflog
```

## Usage

```bash
kubectl get events --all-namespaces | fzf | kubflog
```
