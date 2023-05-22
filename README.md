# README
SETUP MLAB API
* System requirements  
```
ruby: 3.2.0
mysql: 8
```
* System dependencies
```
bundle install
```
* Configuration (Edit configuration file in config folder accordingly)
```
cd config  

# Edit the default block database in database.yml and iblis_db block database accordingly
1. cp database.yml.example database.yml  

# Edit dde_service and nlims_service block accordingly
# If you are on a site that need 8 character long sample id(accession number), setting accession_number_length to false in default block of this file  
   otherwise the default length is 10 characters
2. cp application.yml.example application.yml
```

* Database creation
```
# Create the db specified in iblis_db block and load the old iblis dump to this db
1. Use the manual process of creating and loading databases if you are setting up the app on a plantform not currently 
   running IBLIS otherwise configure db configs for IBLIS app database in iblis_db block of database.yml found below the file.  
   This will be used for migration of data 

# Create default database for MLAB app set in the default block of database.yml
2. rails db:create && rails db:migrate
```
* Database initialization
```
# Run this command to migrate data from iblis databae you have created to the database that mlab will be using
bash load_iblis_data.sh 
```
