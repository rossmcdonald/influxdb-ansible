#!/bin/bash

debug=0 # enable debug messages

DATABASE="test"
HOSTNAME="localhost"
PORT="8086"

SERIES_NAME="data" # name of series
VALUE_MOD=100 # number to `mod` random values by
TAG_COUNT=5 # number of tags
TAG_VALUE_COUNT=4 # number of possible values per tag
ENABLE_BLANK_TAGS=0 # allow for blank tags
BLANK_TAG_DIST=10 # random distribution of blank tags
WRITE_FREQUENCY=0.2 # in s
WRITE_BATCH_SIZE=5 # how many points per batch
WRITE_DURATION=30 # how many times to write

declare -a TAGS
declare -a TAG_VALUES

function generate_tags {
    test $debug && echo -e "generate_tags"
    for i in $(seq 0 $(( $TAG_COUNT - 1 )) ); do
	tag_name=$(random_string)
	test $debug && echo -e "\tGenerated tag ($i/$(( $TAG_COUNT - 1 ))) name: $tag_name"
	TAGS[$i]="$tag_name"
    done
}

function generate_tag_values {
    test $debug && echo -e "generate_tag_values"
    for i in $(seq 0 $(( $TAG_VALUE_COUNT - 1 )) ); do
	value_name=$(random_string)
	test $debug && echo -e "\tGenerated tag value ($i/$(( $TAG_VALUE_COUNT - 1 ))) name: $value_name"
	TAG_VALUES[$i]="$value_name"
    done
}

function random_string {
    length=$1
    if [[ -z $length ]]; then
	let length=8
    fi
    if [[ $(uname -s) -eq "Darwin" ]]; then
	cat /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w $length | head -n 1
    else
	cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w $length | head -n 1
    fi
}

function generate_point {
    # test $debug && echo -e "generate_point"
    line="$SERIES_NAME,"
    for i in $(seq 0 $(( $TAG_COUNT - 1 )) ); do
	skip="$(( $RANDOM % $BLANK_TAG_DIST ))"
	test $ENABLE_BLANK_TAGS -a $skip -eq 0 && continue
	line="$line${TAGS[$i]}="
	line="$line${TAG_VALUES[$(( $RANDOM % $TAG_VALUE_COUNT ))]},"
    done
    line="${line%?}" # drop last value (a comma)
    line="$line value=$(( $RANDOM % $VALUE_MOD ))"
    # test $debug && echo -e "\tPoint generated: $line"
    echo "$line"
}

generate_tags
generate_tag_values
for i in $(seq 1 $WRITE_DURATION); do
    POINTS=""
    for j in $(seq 0 $(( $WRITE_BATCH_SIZE - 1 )) ); do
	p="$(generate_point)\n"
	# test $j -eq 0 -a $WRITE_BATCH_SIZE -eq 1 && p="${p%?}" && p="${p%?}"
	POINTS="$POINTS$p"
    done
    # test $WRITE_BATCH_SIZE > 1 && POINTS="${POINTS%?}" && POINTS="${POINTS%?}"
    test $debug && echo -e "Generated $WRITE_BATCH_SIZE points."
    # test $debug && echo -e "Generated $WRITE_BATCH_SIZE points:\n${POINTS[*]}"
    echo -e "Writing $WRITE_BATCH_SIZE points to http://$HOSTNAME:$PORT/write?db=$DATABASE"
    curl -v -XPOST "http://$HOSTNAME:$PORT/write?db=$DATABASE" --data-binary "$(printf "$POINTS")" &>/dev/null
    test $? -eq 0 || echo "Received bad code ($?) from POST."
    sleep $WRITE_FREQUENCY
done
