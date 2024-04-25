#!/bin/sh

find cluster -type d -name charts | xargs rm -rf
find . -name '*.terraform*' | xargs rm -rf
rm -rf ./tmp/*
