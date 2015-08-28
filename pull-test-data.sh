#!/usr/bin/env bash
# Note: this script assumes a few things:
# - InfluxDB can be reached at localhost:8086
# - There is test data being stored in the db: my_sample_db
# - There is a 'random_ints' series with data loaded into it
# - Python is installed (>= v2.6 for json module)

curl -s -G http://localhost:8086/query --data-urlencode "db=my_sample_db" --data-urlencode "q=SELECT * FROM random_ints" | python -mjson.tool
