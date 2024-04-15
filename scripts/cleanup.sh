#!/bin/sh

find . -name '*generated_configs/*'
find . -name '*generated_configs/*' | xargs rm -rf

find . -name '*.terraform*'
find . -name '*.terraform*' | xargs rm -rf
