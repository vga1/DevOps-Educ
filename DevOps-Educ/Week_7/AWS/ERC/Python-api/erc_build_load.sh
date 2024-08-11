#!/bin/bash

# Build image
docker build -t python_app .
# Taging image
docker tag python_app:latest 856551683390.dkr.ecr.us-east-1.amazonaws.com/devops-tutor:latest
# Push image

docker push 856551683390.dkr.ecr.us-east-1.amazonaws.com/devops-tutor:latest