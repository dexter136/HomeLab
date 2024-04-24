#!/bin/sh

find -type d -name generated_configs | xargs rm -rf
find -type d -name charts | xargs rm -rf
find . -name '*.terraform*' | xargs rm -rf
find . -name tmp | xargs rm -rf
