#!/bin/bash
function handle_delete() {
    echo "Args received: $@"
    echo "Arg count: $#"
    echo "Arg 1: ${1:-}"
    echo "Arg 2: ${2:-}"
    echo "Arg 3: ${3:-}"
    
    shift  # Skip "delete"
    echo "After first shift:"
    echo "Arg 1: ${1:-}"
    echo "Arg 2: ${2:-}"
    echo "Arg 3: ${3:-}"
    
    local first_arg="${1:-}"
    echo "first_arg: $first_arg"
}

# Simulate the main dispatch
handle_delete "allow" "from" "173.245.48.0/20" "to" "any" "port" "443"
