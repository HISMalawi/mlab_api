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

2. Checkout the `dev_staging` branch:

```shell
git checkout dev_staging
```

## Configure Application Settings

1. Copy the `application.yml.example` file to `application.yml`:

```shell
cp application.yml.example application.yml
```

2. Edit the `application.yml` file to configure the DDE and NLIMS settings:

```shell
vim application.yml
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
rails r bin/moh_report_init.rb  # Run this in tmux
```

## Data Initialization for Sites without Previous iBLIS Installation

Run the following command to initialize the database:

```shell
rails r bin/setup/initialize_database.rb
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

Congratulations! You have successfully installed and set up `mlab_api`.