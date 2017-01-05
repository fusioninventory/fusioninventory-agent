#! /bin/sh

set -e

git status

perl Makefile.PL

make test

