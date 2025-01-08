#!/bin/bash

export PATH="$HOME/.rbenv/bin:$PATH"

if command -v rbenv &> /dev/null; then
    eval "$(rbenv init -)"
fi
rails r iblis_migration/elasticsearch_update.rb