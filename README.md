# Helm Charts

## Use
Want to use this Helm Chart? `helm repo add https://this-week-in.github.io/helm-charts` 

Once it's added then you can use it like this: 

```shell

#!/usr/bin/env bash 

NS=$TWI_NS
CHART_NAME=twi-${NS}-helm-chart 

function create_ip(){
    IPN=$1
    gcloud compute addresses list --format json | jq '.[].name' -r | grep $IPN || gcloud compute addresses create $IPN --global
}

function init(){
    create_ip ${NS}-twi-studio-ip 
    create_ip ${NS}-twi-bookmark-api-ip 
    kubectl get ns/$NS || kubectl create namespace ${NS} 
}

init 


HELM_COMMAND="install"
helm list -n $NS | grep $CHART_NAME  && HELM_COMMAND="upgrade" 
echo "Performing a helm ${HELM_COMMAND}..."

helm  $HELM_COMMAND   --values ./values.yaml  \
 --set twi.prefix=$NS   \
 --set twi.domain=$TWI_DOMAIN  \
 --set twi.postgres.username=$DB_USER  \
 --set twi.postgres.password=$DB_PW  \
 --set twi.postgres.host=$DB_HOST  \
 --set twi.postgres.schema=$DB_DB  \
 --set twi.redis.host=$REDIS_HOST \
 --set twi.redis.password=$REDIS_PW \
 --set twi.redis.port=$REDIS_PORT \
 --set twi.ingest.tags.ingest=$INGEST_TAG \
 --set twi.ingest.tags.ingested=$INGESTED_TAG \
 --set twi.pinboard.token=$PINBOARD_TOKEN \
 --set twi.twitter.client_key=${TWITTER_CLIENT_KEY} \
 --set twi.twitter.client_key_secret=${TWITTER_CLIENT_KEY_SECRET} \
 --set twi.ingest.feed.mappings=$INGEST_FEED_ENCODED_MAPPINGS \
 --set twi.ingest.twitter.mappings=$INGEST_TWITTER_ENCODED_MAPPINGS \
 --namespace $NS  \
 $CHART_NAME . 

# TODO restore this _AFTER_ youve ensured youre reading config in the same way as you are feed ingest configuration
kubectl create job --from=cronjob/${NS}-twi-twitter-ingest-cronjob ${NS}-twi-twitter-ingest-cronjob-${RANDOM} -n $NS 
kubectl create job --from=cronjob/${NS}-twi-bookmark-ingest-cronjob ${NS}-twi-bookmark-ingest-cronjob-${RANDOM} -n $NS 
kubectl create job --from=cronjob/${NS}-twi-feed-ingest-cronjob ${NS}-twi-feed-ingest-cronjob-${RANDOM} -n $NS 



```

## Build
Want to publish a new version of the chart? Run `helm_package.sh` 
