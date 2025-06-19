#!/bin/bash

USE_JSON_FORMAT=false
TAIL_LINES=20
GREP_STRING=""
HIGHLIGHT=false

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
         -g|--grep)
             # Validate that the argument to --grep is a string
             if ! [[ -n $2 ]]; then
                 echo "Error: --grep requires a value." >&2
                 exit 1
             fi
             GREP_STRING=$2
             shift 2 
             ;;
         -hl|--highlight)
             HIGHLIGHT=true
             shift
             ;;
         -h|--help)
             echo "Usage: $(basename "$0") [options]"
             echo ""
             echo "Options:"
             echo "  --json | -j              Enable JSON log formatting using 'jq'."
             echo "  --tail <int> | -t <int>  Retrieve last N lines from logs; Default is 20 (passed to kubectl logs --tail)."
             echo "  --grep <str> | -g <str>  Filter logs using grep; Default is no filtering (passed to kubectl logs)."
             echo "  --highlight | -hl        Highlight log lines using 'jq'. (** if use this --json will not disable **)"
             echo "  --help | -h              Display this help message."
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

kubectx | fzf --header="Choose a cluster" 

PODINFO=$(kubectl get pods -A | fzf --header="Choose a pod")

IFS=' ' read -r -a POD <<< "$PODINFO"

NAMESPACE=${POD[0]}
PODNAME=${POD[1]}

echo "Pod name: $PODNAME, namespace: $NAMESPACE"

LOG_CMD="kubectl logs --follow --tail $TAIL_LINES $PODNAME -n $NAMESPACE"
if [ -n "$GREP_STRING" ] && [ $HIGHLIGHT == true ]; then
  LOG_CMD="$LOG_CMD | grep --color=always -i $GREP_STRING"
elif [ -n "$GREP_STRING" ]; then
  LOG_CMD="$LOG_CMD | grep -i $GREP_STRING"
fi

eval "$LOG_CMD" | while IFS= read -r line; do
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

