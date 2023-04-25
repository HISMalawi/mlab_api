# README
SETUP MLAB API
* Ruby version  
```
3.2.0
```
* System dependencies

* Configuration
```
cd config 
cp database.yml.example database.yml
```
```
Edit the default database in database.yml and iblis_db block 
```

* Database creation
```
rails db:create && rails db:migrate
```
* Database initialization
```
bash load_iblis_data.sh 
```
