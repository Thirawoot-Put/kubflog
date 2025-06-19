#!/bin/bash

USE_JSON_FORMAT=false
TAIL_LINES=20

 while [[ $# -gt 0 ]]; do
     case "$1" in
         -j|--json)
             USE_JSON_FORMAT=true
             shift 
             ;;
         -t|--tail)
             # Validate that the argument to --tail is a number
             if ! [[ -n $2 ]]; then
                 echo "Error: --tail requires a value." >&2
                 exit 1
             fi
             if ! [[ "$2" =~ ^[0-9]+$ ]]; then
                 echo "Error: --tail requires must be a number." >&2
                 exit 1
             fi

             TAIL_LINES=$2
             shift 2 
             ;;
         -h|--help)
             echo "Usage: $(basename "$0") [options]"
             echo ""
             echo "Options:"
             echo "  --json | -j          Enable JSON log formatting using 'jq'."
             echo "  --tail <int> | -t    Retrieve last N lines from logs; Default is $TAIL_LINES (passed to kubectl logs --tail)."
             echo "  --help | -h          Display this help message."
             echo ""
             echo "Examples:"
             echo "  $(basename "$0") --json"
             echo "  $(basename "$0") --tail 100"
             echo "  $(basename "$0") --json --tail 50"
             exit 0
             ;;
         *) 
             echo "Unknown option $1"
             break 
             ;;
     esac
 done

# choose kubernetes cluster from kubectx
kubectx | fzf --header="Choose a cluster" 

# use kubectl list pods and choose by fzf then save pod name and namespace to variable
PODINFO=$(kubectl get pods -A | fzf --header="Choose a pod")

# split the pod info into pod name and namespace
IFS=' ' read -r -a POD <<< "$PODINFO"

NAMESPACE=${POD[0]}
PODNAME=${POD[1]}

echo "Pod name: $PODNAME, namespace: $NAMESPACE"

# log by kubectl logs -n $NAMESPACE $PODNAME
kubectl logs --follow --tail $TAIL_LINES $PODNAME -n $NAMESPACE | while IFS= read -r line; do
  if [ $USE_JSON_FORMAT == true ]; then
    echo "$line" | jq '.' &>/dev/null
    if [ $? -eq 0 ]; then
      echo "$line" | jq
    else
      echo "$line"
    fi
    sleep 0.03
  else
    echo "$line"
    sleep 0.03
  fi
done

