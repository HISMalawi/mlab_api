# README
SETUP MLAB API
* Ruby version  
```
3.2.0
```
* System dependencies
```
bundle install
```
* Configuration
```
cd config 
cp database.yml.example database.yml
```
```
Edit the default database in database.yml and iblis_db block 
Create the db specified in iblis_db block and load the old iblis dump
```

* Database creation
```
rails db:create && rails db:migrate
```
* Database initialization
```
bash load_iblis_data.sh 
```
