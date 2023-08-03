# mlab_api Installation Guide

This guide provides step-by-step instructions for installing and setting up `mlab_api`.

## Requirements

Before installing `mlab_api`, ensure that the following requirements are met:

- Ruby 3.2.0
- MySQL 8
- Rails 7
- Redis

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

   - Only set the database connections for the `default` block in `database.yml`.

2. For sites that had iBLIS previously:

   - Set up the database connections for both the `default` block and the `iblis_db` block found at the bottom of the `database.yml` file.
   - The `iBLIS` block should be connected to MySQL 8 iBLIS database, which you will load from the iBLIS dump.

## Set Up Encryption Key

Copy the `master.key.example` file in the `config` folder to `master.key`:

```shell
cp master.key.example master.key
```

## Install Dependencies and Set Up `mlab_api` Database

1. Install the required dependencies:

```shell
rvm use 3.2.0
bundle install
```

2. Create and migrate the `mlab_api` database:

```shell
rails db:create db:migrate
```

## Data Migration for Sites with Previous iBLIS Installation

1. Create the iBLIS database as specified in the `iblis_db` block of `database.yml`.
2. Load the iBLIS dump into this database.
3. Run the migration scripts to migrate data from the iBLIS database to the `mlab_api` database:

```shell
bash load_iblis_data.sh
rails r bin/moh_report_init.rb  # Run this in tmux as it may take time to complete
```

## Data Initialization for Sites without Previous iBLIS Installation

Run the following command to initialize the database:

```shell
./bin/initialize_db.sh development # development can be replace by production or test depending on the enviroment you have set you application
```

## Configure Sidekiq Service

1. Edit the `sidekiq.service` file and replace the following placeholders:
   - `WorkingDirectory` with your app directory
   - `ExecStart` with your app directory (listed in the file)
   - `User` with your PC username

```shell
vim sidekiq.service
```

2. Copy the `sidekiq.service` file to `/etc/systemd/system`:

```shell
cp sidekiq.service /etc/systemd/system
```

3. Start the Sidekiq service:

```shell
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

6. Set cron job for pregenerating moh reports:
```shell
0 0 * * * /bin/bash -lc "cd /var/www/mlab_api && rvm use 3.2.0 && rails r bin/generate_moh_report.rb &"
```
6. Set cron job for syncing with NLIMS:
```shell
*/2 * * * *  /bin/bash -lc "cd /var/www/mlab_api && rvm use 3.2.0 && rails r bin/nlims_sync.rb &"
```

Congratulations! You have successfully installed and set up `mlab_api`.