#!/bin/bash

# example image source Id's
# failing image source can be created by using this git repo to create a Dockerfile Image source type.
# success can just be any image from dockerhub
# API KEY is created under Hub > API Keys 
# Hub ID is found on Hub > settings
# example ids (wont work for you) 
# 555da4b3ded14fda9ca84644 success 
# 55502dceded14fda9ca8467b fail


response=$(curl https://api.cycle.io/v1/images \
  -H "Authorization: Bearer $APIKEY" \
  -H "X-Hub-Id: $HUBID" \
  -H 'Content-Type: application/json' \
  -d '{"source_id": "555da4b3ded14fda9ca84644"}' \
  -X POST)

id=$(echo "$response" | jq -r ".data.id")

importResponse=$(curl https://api.cycle.io/v1/images/$id/tasks \
  -H "Authorization: Bearer $APIKEY" \
  -H "X-Hub-Id: $HUBID" \
  -H 'Content-Type: application/json' \
  -d '{"action":"import"}' \
  -X POST)


jobid=$(echo "$importResponse" | jq -r ".data.job.id")

while true; do
    data=$(curl https://api.cycle.io/v1/jobs/$jobid \
      -H "Authorization: Bearer $APIKEY" \
      -H "X-Hub-Id: $HUBID")
    # Extract the "current" state value
    state=$(echo "$data" | jq -r '.data.state.current')

    # Check the state value
    if [[ "$state" == "completed" ]]; then
        echo "job completed"
        break
    elif [[ "$state" == "error" ]]; then
        # Extract and print the error message
        error_message=$(echo "$data" | jq -r '.data.state.error.message')
        echo "$error_message"
        break
    else
        # Sleep for 10 seconds before rechecking
        echo "$state"
        sleep 10
    fi
done


