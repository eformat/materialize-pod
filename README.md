# Materialize on OpenShift

Materialize is a streaming data warehouse. Materialize accepts input data from a variety of streaming sources (e.g. Kafka) and files (e.g. CSVs), and lets you query them using the PostgreSQL dialect of SQL.

This demo uses a realtime event stream from Meetup.com to continually poupulate materalized views that we can query using sql.

The materialize schema is loaded at the start using a kubernetes Job pod.

Checkout `Materialize` here:
- https://materialize.io/docs/install/

Read more about differential dataflow here:
- https://timelydataflow.github.io/differential-dataflow/

Prerequisites:
- access to registry.redhat.io images
- psql client

## Run Meetup.com Demo on OpenShift

Lets take a look at `Meetup.com` live streaming data based on RSVP's to events.

Create application pods in OpenShift:
```
oc new-project materialize
oc apply -f ./materialize-demo.yml
```

Connect to materialize using postgresql client:
```
oc port-forward svc/materialize 6875:6875 &
psql -h localhost -p 6875 materialize
```

See whats popular globally in Meetup.com right now based on live data stream:
```
materialize=> SELECT * FROM popularglobal;
   me_id    |                                   name                                    |      city      | state | country | count 
------------+---------------------------------------------------------------------------+----------------+-------+---------+-------
 1835433044 | "Beer Mongers Stammtisch"                                                 | "Portland"     | "OR"  | "us"    |     4
 1835433075 | "Virtual Advanced Class!"                                                 | "Laguna Hills" | "CA"  | "us"    |     4
 1835433048 | "Virtual Intermediate Class!"                                             | "Laguna Hills" | "CA"  | "us"    |     4
 1835433096 | "Bird Walk/Talk- Flycatchers & Thrush"                                    | "New York"     | "NY"  | "us"    |     4
 1835433139 | "Real Estate Investment Networking"                                       | "Wilkes Barre" | "PA"  | "us"    |     4
 1835433135 | "Family & Friends Support Group - ONLINE"                                 | "La Jolla"     | "CA"  | "us"    |     4
 1835433124 | "Deep Learning in Document Imaging (Online Webinar)"                      | "Bangalore"    |       | "in"    |     4
 1835433071 | "Board Gaming in Lincolnshire, IL now Online "                            | "Chicago"      | "IL"  | "us"    |     4
 1835433045 | "Sentiment Analysis on Product Review (Lemmatization, tf-idf)"            | "Bangalore"    |       | "in"    |     9
 1835433061 | "🤯Top 10 Social Media Digital Marketing Strategy of 2020 - Talk & Social" | "Toronto"      | "ON"  | "ca"    |     9
(10 rows)
```

To see the total number of Meetup RSVP's that we have so far:
```
materialize=> SELECT * FROM meetuploccounter;
 COUNT 
-------
   136
(1 row)
```

Checkout more queries below.

## Materialized Views and Data

PVC's used to store streaming event data and materialize data. 

Getting the data into materialize is as easy as:
```
while true; do
  curl --max-time 9999999 -N http://stream.meetup.com/2/rsvps >> /work/meetups/data
done
--
CREATE SOURCE meetups
FROM FILE '/work/meetups/data'
WITH ( tail=true )
FORMAT REGEX '^(?P<meet>\{.*)';
```

Raw data is queryable like postgresql jsonb data;

Checkout `load.sql` Config Map in [`materizlize-demo.yaml`](./materialize-demo.yml) for the created schema magic.

Meetup.com event stream from here: `http://stream.meetup.com/2/rsvps`

Try out some of these queries:
```
SELECT * FROM meetuploccounter;
SELECT * FROM meetuplocation;
SELECT * FROM meetupall;
SELECT * FROM meetupevent;
SELECT * FROM locationbycountry;
SELECT * FROM top10country;
SELECT * FROM brisbanemeets;
SELECT * FROM nzmeets;
SELECT * FROM popularbrisbane;
SELECT * FROM nocountrymeets;
SELECT * FROM popularnz;
SELECT * FROM gbmeets;
SELECT * FROM populargb;
SELECT * FROM usmeets;
SELECT * FROM popularus;
SELECT * FROM aumeets;
SELECT * FROM popularau;
SELECT * FROM frmeets;
SELECT * FROM popularfr;
SELECT * FROM jpmeets;
SELECT * FROM popularjp;
SELECT * FROM inmeets;
SELECT * FROM popularin;
SELECT * FROM globalmeets;
SELECT * FROM popularglobal;
```

## Local Development

Tweak to suit your environment:
```
make podman-run
```
