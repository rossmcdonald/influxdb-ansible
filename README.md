# InfluxDB Ansible Deployment

Today we will be deploying InfluxDB to a remote instance using Ansible.

## Repository Overview

In the root directory of this repository, you should find the following files:

- `site.yml` => This is the 'main' for our Ansible script. This file can be used to limit which roles get applied to which hosts. This is more important for larger playbooks, but we're including it here as well for brevity.

- `run-playbook.sh` => This is a helper script for getting started deploying the playbook. Usage for this script is described later.

- `pull-test-data.sh` => This is another helper script that will be used to verify our installation once it's completed.

- `Vagrantfile` => This is a vagrant configuration file used to replicate local testing. Assuming you have `vagrant` installed, you can simply run `vagrant up` within this repo to provision a VM and deploy InfluxDB.

- `roles/` => These are where the individual Ansible roles are stored (just influxdb in this case).

## Installing Ansible

If you don't have Ansible already installed, you can do so using `pip` and `virtualenv`:

```
# Create our virtual environment, and set our environment variables accordingly
$ virtualenv venv
$ source venv/bin/activate

# Install the necessary packages
$ pip install -r requirements.txt
```

## Local Testing

If you also have Vagrant installed, you can test the playbook using the following command:

```
$ vagrant up
```

Which should provision a VM, install InfluxDB, start the InfluxDB service, and load some random test data into a 'my_sample_db' database. This should also enable port forwarding for the VM, so that InfluxDB can be reached using `localhost:8086`. The `pull-test-data.sh` script can be used here to verify the data has been loaded and the ports have been mapped correctly:

```
$ ./pull-test-data.sh localhost
```

## Deploying InfluxDB

Once 