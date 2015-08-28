# InfluxDB Ansible Deployment

Today we will be deploying InfluxDB to a remote instance using Ansible.

## Repository Overview

In the root directory of this repository, you should find the following files:
- `Vagrantfile` => This is a vagrant configuration file used to replicate local testing. Assuming you have `vagrant` installed, you can simply run `vagrant up` within this repo to provision a VM and deploy InfluxDB.
- `site.yml` => This is the 'main' for our Ansible script. This file can be used to limit which roles get applied to which hosts. This is more important for larger playbooks, but we're including it here as well for brevity.
- `roles/` => This is where the individual Ansible roles are stored (just influxdb in this case).
- `run-playbook.sh` => This is a helper script for getting started deploying the playbook. Usage for this script is described later, but assumes that your inventory is located in a 'hosts' file in the root directory of the repo.
- `pull-test-data.sh` => This is another helper script that will be used to verify our installation once it's completed.
- `requirements.txt` => Our pinned python dependencies. Can be installed using `pip`. For this experiment, we are using Ansible 1.9.2.

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

## Deploying InfluxDB to a Remote Server

Once all of our dependencies are met, we are ready to deploy Influx to a remote server. Since Ansible uses SSH, all you need to know is how to connect to your remote server. For example, to deploy Influx to a Digital Ocean droplet (wink wink):


```
# Populate our inventory with the connection parameters of our server(s)
$ echo "<username>@<ip address>:<SSH port, if non-standard>" > hosts

# If your SSH configuration is already setup, then that might be all you need
$ ./run-playbook.sh

# Other options can be included, if needed. For example, to get prompted for a password:
$ ./run-playbook.sh -k
```

Once the script is completed, you can verify that everything was successful by running the `pull-test-data.sh` script:

```
$ ./pull-test-data.sh <ip address>
```

Which should dump JSON output similar to:

```
{
    "results": [
        {
            "series": [
                {
                    "columns": [
                        "time",
                        "value"
                    ],
                    "name": "random_ints",
                    "tags": {
                        "host": "server_0"
                    },
                    "values": [
                        [
                            "2015-08-28T16:29:28.495769722Z",
                            76
                        ]
                    ]
                }...
		<snip-snip>
            ]
        }
    ]
}
```

## Verifying Installation

To verify that InfluxDB is up and running correctly, you can utilize Influx's `/ping` HTTP endpoint:

```
$ curl -v http://<IP ADDRESS>:8086/ping
* Hostname was NOT found in DNS cache
*   Trying <IP ADDRESS>...
* Connected to <IP ADDRESS> (<IP ADDRESS>) port 8086 (#0)
> GET /ping HTTP/1.1
> User-Agent: curl/7.37.1
> Host: <IP ADDRESS>:8086
> Accept: */*
> 
< HTTP/1.1 204 No Content
< Request-Id: ff394228-4da3-11e5-8013-000000000000
< X-Influxdb-Version: 0.9.2
< Date: Fri, 28 Aug 2015 16:44:07 GMT
< 
* Connection #0 to host <IP ADDRESS> left intact
```

Which should generate a HTTP 204 return code and display the correct InfluxDB version when `curl`'d.

## Loading Test Data

The Ansible playbook will automatically load a small set of test data once the installation has been verified. If you would like to load data manually, you can use the following commands utilizing Influx's HTTP API endpoints:

```
# To add data into the existing 'random_ints' measurement, in the 'my_sample_db' database
$ curl -i -XPOST 'http://<ip address>:8086/write?db=my_sample_db' --data-binary 'random_ints,host=server<RANDOM INT>,region=us-west value=<RANDOM INT>'

# If you would like to create a new database to store measurements
$ curl -G http://<ip address>:8086/query --data-urlencode "q=CREATE DATABASE <db name>"

# And then write data to it
$ curl -i -XPOST 'http://<ip address>:8086/write?db=<db name>' --data-binary '<measurement>[,<tags>] value=<value> [timestamp]'

# And then to read data back
$ curl -G 'http://localhost:8086/query' --data-urlencode "db=<db name>" --data-urlencode "q=SELECT value FROM <measurement> WHERE <tag key>=<tag value>"
```

More information about the HTTP API endpoint can be found here:
- https://influxdb.com/docs/v0.9/guides/writing_data.html
- https://influxdb.com/docs/v0.9/guides/querying_data.html

In addition to the HTTP API, the Influx shell can also be used to interact with the database (either locally or remote). For more information about Influx Shell commands, please see the full documentation here:
- https://influxdb.com/docs/v0.9/tools/shell.html

# Full Documentation

For the full set of InfluxDB documentation, you can use the following link:

https://influxdb.com/docs/v0.9/introduction/index.html

# Considerations/Caveats

Please note that this playbook is for test and demonstration purposes only, and should not be used for production environments. Security considerations have not been addressed (firewall or apparmor), and this script assumes you are running Ubuntu 14.04. Other distros and versions are currently untested, so mileage may vary.

# Bugs/Contribution

Any and all contributions are always welcome! Please open an issue if any bugs or defects are found.

- Ross