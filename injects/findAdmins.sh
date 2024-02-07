#!/bin/sh
# @d_tranman/Nigel Gerald/Nigerald, modified by jtrigg

cat /etc/group | grep -E '(sudo|wheel)' | awk -F ':' '{print $4}'