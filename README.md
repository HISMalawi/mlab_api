# mlab_api Installation Guide

This guide provides step-by-step instructions for installing and setting up `mlab_api`.

## Requirements

Before installing `mlab_api`, ensure that the following requirements are met:

- Ruby 3.2.0
- MySQL 8
- Rails 7
- Redis version 6+

## Installing Redis

1. Add the Redis repository:

```shell
sudo apt install lsb-release curl gpg  
curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg  
echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list  
sudo apt-get update  
```

2. Install Redis:

```shell
sudo apt-get install redis
```

3. Enable and start the Redis server:

```shell
sudo systemctl enable --now redis-server
```

4. Verify the status of the Redis server:

```shell
sudo systemctl status redis-server
```
6. Verifiy redis version to be 6+
   ```
   redis-server --version
   ```
# Installing MYSQL 8
1. Install via docker
```
   docker run --name mysql8 -e MYSQL_ROOT_PASSWORD=root -d -p 3308:3306 --restart always mysql:8.0.35 --default-authentication-plugin=mysql_native_password
```
2. Check if correctly installed
```
   mysql -uroot -p -h127.0.0.1 -P3308
```
3. Should you want to backup your database, you can use the following command:
```
   mysqldump -u root -p -h127.0.0.1 -P3308 mlab_api > mlab_api.sql
```

## Clone the Application and Checkout the Branch

1. Clone the `mlab_api` repository:

```shell
git clone https://github.com/EGPAFMalawiHIS/mlab_api.git
```

2. Checkout the `main` branch:

```shell
git checkout main
```

## Configure Application Settings

1. Copy the `application.yml.example` file to `application.yml`:

```shell
cp application.yml.example application.yml
```

2. Edit the `application.yml` file to configure the DDE and NLIMS settings and default settings:

```shell
vim application.yml
```

## Installing ElasticSearch - If you set use_elasticsearch to true in the application.yml in the default block
#### A. Via docker: https://hub.docker.com/_/elasticsearch 
```bash
docker run -d --name elasticsearch -p 9200:9200 -e "discovery.type=single-node" --restart always elasticsearch:7.17.18
```
   Test elasticsearch Installation
```bash
curl -X GET 'http://localhost:9200'  #This should output something about name, cluster_name, tagline, version
```
OR 
#### B. Installing without Using Docker
1. Install Java
```shell
java -version # Check if java is already installed, if not install by running below commands
sudo apt install default-jre
sudo apt install default-jdk
javac -version # Check if the installation was a success
```
2. Add elasticsearch repository
```shel
curl -fsSL https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic.gpg
echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-7.x.list
```

3. Install Elasticsearch
```shell
sudo apt update
sudo apt install elasticsearch
sudo systemctl start elasticsearch
```

4. Test elasticsearch installation
```shell
curl -X GET 'http://localhost:9200'  #This should output something about name, cluster_name, tagline, version
```

5. Enable elasticsearch
```shell
sudo systemctl enable elasticsearch
```


## Configure Database Connection Details

1. For a new fresh setup without a previous iBLIS installation:

   - Only set the database connections for the `default` block in `database.yml` or the database name in either production or development block depending on the environment your application will be run in.

2. For sites that had iBLIS previously:

   - Set up the database connections for both the `default` block and the `iblis_db` block found at the bottom of the `database.yml` file.
   - The `iBLIS` block should be connected to MySQL 8 iBLIS database, which you will load from the iBLIS dump.

## Set Up Encryption Key

Copy the `master.key.example` file in the `config` folder to `master.key`:

```shell
cp master.key.example master.key
export SECRET_KEY_BASE=$(bundle exec rails secret)
```

## Install Dependencies and Set Up `mlab_api` Database

1. Install the required dependencies:

```shell
rvm use 3.2.0
bundle install --local
npm install
```

2. Create and migrate the `mlab_api` database:

```shell
RAILS_ENV=production rails db:create && RAILS_ENV=production rails db:migrate && RAILS_ENV=production rails db:seed #production can be replaced with development depending on your environment
```

## Data Migration for Sites with Previous iBLIS Installation

1. Create the iBLIS database as specified in the `iblis_db` block of `database.yml`.
2. Load the iBLIS dump into this database.
3. Run the migration scripts to migrate data from the iBLIS database to the `mlab_api` database:

```shell
bash load_iblis_data.sh
```
## Migration of data that remained or was done after first migration for Sites with Previous iBLIS Installation  
This is the migration of data that was entered or updated in iblis after you have already migrated the data you took earlier. This migration assumes that you have not done any new orders in the new iblis(mlab). This ensures that user continue to use the previous iBLIS system while migrating data.
```shell
   RAILS_ENV=production rails r iblis_migration/iblis/remaining_data/update.rb #production can be replaced with development depending on your environment
```

## Data Initialization for Sites without Previous iBLIS Installation

Run the following command to initialize the database:

```shell
./bin/initialize_db.sh development # development can be replace by production or test depending on the enviroment you have set you application
```

## Configuring mlab_api PUMA serivice

1. Edit the `mlab_api.service` file and replace the following placeholders:
   - `WorkingDirectory` with your app directory
   - `ExecStartPre` with your app directory (listed in the file)
   - `ExecStart` with your app directory (listed in the file)
   - `User` with your PC username
   - `Environment="RAILS_ENV=production"` by replacing production with development if you are running the api in development mode

```shell
vim mlab_api.service
```
2. Copy the `mlab_api.service` file to `/etc/systemd/system`:

```shell
cp mlab_api.service /etc/systemd/system
```

3. Start the mlab_api puma service:

```shell
sudo systemctl daemon-reload
sudo systemctl start mlab_api.service
```

4. Verify the status of the mlab_api puma service:

```shell
sudo systemctl status mlab_api.service
```

5. Enable the mlab_api puma service to start on system boot:

```shell
sudo systemctl enable mlab_api.service
```

## Configure Sidekiq Service

1. Edit the `sidekiq.service` file and replace the following placeholders:
   - `WorkingDirectory` with your app directory
   - `ExecStart` with your app directory (listed in the file)
   - `User` with your PC username
   - `Environment` by replacing production with development if you are running the api in development mode

```shell
vim sidekiq.service
```

2. Copy the `sidekiq.service` file to `/etc/systemd/system`:

```shell
cp sidekiq.service /etc/systemd/system
```

3. Start the Sidekiq service:

```shell
sudo systemctl daemon-reload
sudo systemctl start sidekiq.service
```

4. Verify the status of the Sidekiq service:

```shell
sudo systemctl status sidekiq.service
```

5. Enable the Sidekiq service to start on system boot:

```shell
sudo systemctl enable sidekiq.service
```
6. Check if sidekiq and redis are running properly, Navigate to: SERVER_IP_ADDRESS:API_PORT/sidekiq

## Elasticsearch Indexing available data
```shell
rails r iblis_migration/elasticsearch_index.rb
```
Congratulations! You have successfully installed and set up `mlab_api`.
