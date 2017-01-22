#!/usr/bin/env bash

#http://unix.stackexchange.com/a/61146
 sed -n '/^```/,/^```/p' < biz/mktg/print/article.md | sed '/^```/ d'