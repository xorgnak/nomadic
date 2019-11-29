#!/bin/bash
PS1=" =^.^= <( I'm ready! ) ";
HELP="usage: ./nomad.sh [env] -> sets or resets shell prompt.
env:
 - tools -> apply network analysis prompt.
 - git -> apply the git tree prompt.
feel free to add your own prompt extensions to ~/.nomad_prompt  
";

source $0

if [[ -d ~/.nomad_prompt ]]; then
    echo "* welcome back *";
else
    mkdir ~/.nomad_prompt;
fi

if [[ $1 != '' ]]; then
    if [[ $1 == '-h' ]] || [[ $1 == '--help' ]]; then
	echo $HELP
    else
	source ~/.nomad_prompt/$1;
    fi
fi
