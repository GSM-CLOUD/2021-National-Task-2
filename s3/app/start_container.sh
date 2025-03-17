#!/bin/bash
IMAGE_URI=$(cat /home/ec2-user/imagedefinitions.json | jq -r ".[0].imageUri")
echo "Pulling new image: $IMAGE_URI"
sudo docker pull $IMAGE_URI
sudo docker run -d -p 80:80 --restart always $IMAGE_URI