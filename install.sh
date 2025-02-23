#!/bin/sh
stow . -t $HOME --ignore '^(README\.md|install\.sh)$'
