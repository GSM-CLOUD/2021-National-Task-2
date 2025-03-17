#!/bin/bash

running_containers=$(sudo docker ps -q)

if [ -z "$running_containers" ]; then
    echo "No running containers to remove."
else
    echo "Stopping and removing running containers..."
    sudo docker rm -f $running_containers
    echo "All running containers have been removed."
fi