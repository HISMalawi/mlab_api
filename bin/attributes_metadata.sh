#!/bin/bash

usage() {
  echo "Usage: $0 ENVIRONMENT"
  echo
  echo "ENVIRONMENT should be: development|test|production"
}

ENV=$1

if [ -z "$ENV" ]; then
  usage
  exit 255
fi

set -x # turns on stacktrace mode which gives useful debug information

export RAILS_ENV=$ENV
rails db:environment:set RAILS_ENV=$ENV

USERNAME=`ruby -ryaml -e "puts YAML::load_file('config/database.yml',aliases: true)['${ENV}']['username']"`
PASSWORD=`ruby -ryaml -e "puts YAML::load_file('config/database.yml',aliases: true)['${ENV}']['password']"`
DATABASE=`ruby -ryaml -e "puts YAML::load_file('config/database.yml',aliases: true)['${ENV}']['database']"`
HOST=`ruby -ryaml -e "puts YAML::load_file('config/database.yml',aliases: true)['${ENV}']['host']"`
PORT=`ruby -ryaml -e "puts YAML::load_file('config/database.yml',aliases: true)['${ENV}']['port']"`

# Folder containing the SQL files
SQL_FOLDER="db/sql/metadata"

echo "Updating attributes metadata from SQL file..."
mysql --host="$HOST" --port="$PORT" --user="$USERNAME" --password="$PASSWORD" "$DATABASE" < "$SQL_FOLDER/test_type_attributes.sql"
