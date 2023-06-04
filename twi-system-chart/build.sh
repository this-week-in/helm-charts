#!/usr/bin/env bash

# to add this repo, somebody would say   
# helm repo add twi https://github.com/this-week-in/helm-chart
TWIC=$HOME/Desktop/temp/this-week-in-charts 
mkdir -p $TWIC 
gsutil rsync  gs://this-week-in-charts  $TWIC 
 
helm package  .
helm repo index  . --url https://this-week-in-charts.storage.googleapis.com
TGZ=$(find . -iname "twi-helm-chart*.tgz" )
INDEX=$(find . -iname index.yaml)
cp $TGZ $TWIC
cp $INDEX $TWIC
gsutil rsync $TWIC gs://this-week-in-charts/