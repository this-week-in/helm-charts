# This Week In Helm Chart

## What is This Week In

This Week In is a set of services designed to support the accumulation of data related to certain topics. This system runs on Kubernetes and handles monitoring Twitter channels, RSS/Atom feeds, and more, and dumping them into Pinboard. Another process then comes along and takes everything in Pinboard and synchronizes it into a PostgreSQL database. The `bookmark-api` is a Spring Boot-powered module that supports authenticated manipulation of the data in the database, The studio module is an HTTP and Vue.js powered front-end application that supports manipulating data through the API. You can search, change the text for, update, delete any entries in the studio. From there, the sky's the limit. The data can be exported to a bullet list in Markdown or some other process could come along and generate a static site.

## Pre-Conditions

This Helm chart can be used to parameterize and install the system in a cluster of Google's Kubernetes implementation, GKE. It is Kubernetes, so in theory much of this 
should work on other Kubernetes distributions, but it has only been tested on Google Cloud GKE. 

There's a script in the root of the directory that demonstrates its use. A few things are worth mentioning: 

The script `install.sh` demonstrates  that you'll need to think of a prefix that gets used all throughout the system to configure things like the Kubernetes namespace into which to install the system. This prefix is also used when naming all the Kubernetes infrastructure, so you have two levels of isolation: namespace, and resource name. 

This Helm chart assumes that you've got some Google Cloud External IPs configured. You'll need to specify a prefix when using this Helm chart. That prefix informs the names that are expected for the external IPs. Lets suppose that the prefix lives in an environment variable called `$NS`, the Helm chart will look for `<NS>-twi-studio-ip` and  `<NS>-twi-api-ip`. The `install.sh` script builds these for you if they don't already exist. 

You'll also need to point a domain to these two External IPs. Use an A Name reocrd to map `bookmark-api.<YOUR_DOMAIN>` to the IP indicated by `<NS>-twi-api-ip`, and  use an A Name record to map `studio.<YOUR_DOMAIN>` to the IP indicated by `<NS>-twi-studio-ip`.

This Helm chart assumes that you've configured a Redis and a PostgreSQL instance and that you have the connection information in the various environment variables used in `install.sh`. See below for a more complete discussion of the environment variables expected.

## Installation using the Helm Chart 

For an up-to-date and more realistic example, please consult `install.sh`. Here's what using only the Helm chart looks like.


```shell
helm install --values ./values.yaml  \
 --set twi.prefix=$NS   \
 --set twi.ingest.tags.ingest=$INGEST_TAG \
 --set twi.ingest.tags.ingested=$INGESTED_TAG \
 --set twi.domain=$TWI_DOMAIN  \
 --set twi.postgres.username=$DB_USER  \
 --set twi.postgres.password=$DB_PW  \
 --set twi.postgres.host=$DB_HOST  \
 --set twi.postgres.schema=$DB_DB  \
 --set twi.redis.host=$REDIS_HOST \
 --set twi.redis.password=$REDIS_PW \
 --set twi.redis.port=$REDIS_PORT \
 --set twi.pinboard.token=$PINBOARD_TOKEN \
 --set twi.twitter.client_key=${TWITTER_CLIENT_KEY} \
 --set twi.twitter.client_key_secret=${TWITTER_CLIENT_KEY_SECRET} \
 --set twi.ingest.feed.mappings=$INGEST_FEED_ENCODED_MAPPINGS \
 --set twi.ingest.twitter.mappings=$INGEST_TWITTER_ENCODED_MAPPINGS \
 --namespace $NS  \
 twi-${NS}-helm-chart . 
```

To use this Helm chart, the easiest approach is to `git clone` this repository and then in the root of the Helm chart, run `helm install` as shown above. The `install.sh` script can do more of the heavy lifting for you. It'll install the whole system assuming you've authenticated to Google Cloud (GKE) on the same machine you run `helm` in. It also notably leaves as an exercise to you the installation of a PostgreSQL and Redis database. 

 * `NS` the Kubernetes namespace you'd like to use. I use the namespace `twis` for  _This Week in Spring_. 
 * `INGEST_TAG` is the tag or tags (`twis` for one, or, `twis, spring` for multiple tags) in Pinboard that should be synchronized to the database. I use `twis` for _This Week in Spring_. This tells the Pinboard ingest module which tag or tags to look for in Pinboard for import.
 * `INGESTED_TAG` is the tag in Pinboard that tells us whether a given item has already been synchronized. I use `twis-ingested` so that the item doesn't get imported again. 
 * `TWI_DOMAIN` is  which DNS domain you'd like to use to host the two HTTP endpoints. I bought a domain [in Gandi.net ](http://gandi.net) and use that. You could also setup a domain in any of the dozens of other DNS registrars out there.  
 * `DB_USER` is the user of the PostgreSQL database  
 * `DB_PW` is the password  of the PostgreSQL database  
 * `DB_HOST` is the host of the PostgreSQL database
 * `REDIS_HOST` is the host of the Redis database
 * `REDIS_PW` is the password of the Redis database 
 * `REDIS_PORT` is the port of the Redis database
 * `PINBOARD_TOKEN` is the token to use to connect to Pinboard  
 * `TWITTER_CLIENT_KEY` is the client key for the Twitter application with which the Twitter ingest module will read Tweets. See the Twitter developer documentation.
 * `TWITTER_CLIENT_KEY_SECRET` is the client key secret for the Twitter application with which the Twitter ingest module will read Tweets. See the Twitter developer documentation.
 * `INGEST_TWITTER_ENCODED_MAPPINGS` is a Base64 encoded string of JSON configuration for the Twitter ingest module. More on that momentarily.
 * `INGEST_FEED_ENCODED_MAPPINGS` is a Base64 encoded string of JSON configuration for the feed ingest module. More on that momentarily. 

Those last two environment variables require a little more work. Broadly, these are two `.json` configuration files that describe the functioning of the Twitter Ingest and Feed Ingest modules. 

## Configuring the Twitter Ingest Module 

The Twitter Ingest module reads Twitter feeds data  and then imports any new entries into the Pinboard service. That Pinboard data is eventually imported into the backend SQL database. You need to specify which feeds you'd like to follow and provide an indication of which tags new entries in those Twitter feeds should result in. 

Here's an an example: 


```json
{ 
  "lemondefr" : { 
    "cuisine": [ "cuisine" ,  "repo",  "resto", "diner"] 
	} ,  
	"wapo" : { 
		"coronavirus": [ "covid", "covid-19" , "covid-19" , "coronavirus"  ] ,
		"politics": [ "biden", "trump"  , "democrat" , "republican", "GOP"] 
	} 
}  

```

This mapping specifies two twitter accounts, `@wapo` (for the American journal the _Washington Post_) and `@lemondefr` (for the French journal _Le Monde_). For `@lemondefr`, the Twitter ingest module will add the Pinboard tag `cuisine` for any Tweet containing any of the words `cuisine`, `repo`, `resto`, and `diner`. For `@wapo`, the Twitter ingest module will add the Pinboard tag `coronavirus` for any Tweet containing any of the words `covid`, `covid-19`, `covid-19`, and  `coronavirus`. For `@wapo`, the Twitter ingest module will add the Pinboard tag `politics` for any Tweet containing any of the words `biden`, `trump`, `democrat`, `republican`, and `GOP`.  

Save the configuration above into a file and then Base64 encode the file and stash it in an environment variable, like this:

```shell
export INGEST_TWITTER_ENCODED_MAPPINGS=$( cat my-twitter-config.json | base64  )
```

## Configuring the Feed Ingest Module 

The Feed Ingest module reads RSS and ATOM feed data and then imports any new entries into the Pinboard service. That Pinboard data is eventually imported into the backend SQL database. You need to specify which ATOM and RSS feeds  you'd like to follow and provide an indication of which Pinboard tags new entries in those RSS and ATOM feeds should result in. 

Here's an example: 

```json
{ 
 	"https://www.politico.com/rss/politicopicks.xml" : [ "politics"]
}
```

This mapping specifies two twitter accounts, `@wapo` (for the American journal the _Washington Post_) and `@lemondefr` (for the French journal _Le Monde_). For `@lemondefr`, the Twitter ingest module will add the Pinboard tag `cuisine` for any Tweet containing any of the words `cuisine`, `repo`, `resto`, and `diner`. For `@wapo`, the Twitter ingest module will add the Pinboard tag `coronavirus` for any Tweet containing any of the words `covid`, `covid-19`, `covid-19`, and  `coronavirus`. For `@wapo`, the Twitter ingest module will add the Pinboard tag `politics` for any Tweet containing any of the words `biden`, `trump`, `democrat`, `republican`, and `GOP`.  

Save the configuration above into a file and then Base64 encode the file and stash it in an environment variable, like this:

```shell
export INGEST_FEED_ENCODED_MAPPINGS=$( cat my-feed-config.json | base64  )
```

