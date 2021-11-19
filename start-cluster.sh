#!/bin/bash

set -e

minikube -p helm-secret-demo start \
  --memory=8g \
  --cpus=4 \
  --disk-size=50g 