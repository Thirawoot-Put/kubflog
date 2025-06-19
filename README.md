# Kubflog
Kubflog is a simple tool for tailing Kubernetes cluster events. Use kubectl and fzf to search for events, then pipe the results to Kubflog.

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
kubflog # tails with out json format and line numbers
kubflog -j || kubflog --json # tails with json format
kubflog -t <int> || kube --tail <int> # tails with tail line numbers
kubflog -j -t <int> # both json and tail line numbers
```
When using the command, Fzf will interactively search through Kubernetes contexts from kubectx and Kubernetes pods, allowing you to select from them.
