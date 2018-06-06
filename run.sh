#!/bin/bash

## debugging
#sleep 99999
#bundle exec ruby main.rb -p 80

service ssh start
bundle exec puma -p 80
