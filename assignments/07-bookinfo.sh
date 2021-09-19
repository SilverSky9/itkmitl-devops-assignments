#!/bin/sh

set -e

#Build and start ratings-service on expose port 8080

# Build Docker Image for rating service
docker build -t ratings $(pwd)/itkmitl-bookinfo-ratings

# Run MongoDB with initial data in database
docker run -d --rm --name mongodb -p 27017:27017 \
  -v $(pwd)/databases:/docker-entrypoint-initdb.d bitnami/mongodb:5.0.2-debian-10-r2

# Run ratings service on port 8080
docker run -d --rm --name ratings-service -p 8080:8080 --link mongodb:mongodb \
  -e SERVICE_VERSION=v2 -e 'MONGO_DB_URL=mongodb://mongodb:27017/ratings' ratings


#Build and start details-service on expose port 8081

# Build Dcoker Image for detail service
docker build -t details $(pwd)/itkmitl-bookinfo-details

#Run details service on port 8081
docker run -d --rm --name details-service -p 8081:9080 details


#Build and start review-service on expose port 8082

# Build dockerfile reviews service
docker build -t reviews $(pwd)/itkmitl-bookinfo-reviews

# Run reviews service
docker run -d --rm --name review-service -p 8082:9080 --link ratings-service:ratings-service -e 'ENABLE_RATINGS=true' -e 'RATINGS_SERVICE=http://ratings-service:8080' reviews


#Build and start productpage-service on expose port 8083

# Build docker productpage service
docker build -t productpage $(pwd)/itkmitl-bookinfo-productpage

# Run productpage service
docker run -d --name productpage-service --rm -p 8083:9080 --link details-service:details-service --link ratings-service:ratings-service --link review-service:review-service  -e 'DETAILS_HOSTNAME=http://details-service:9080' -e 'RATINGS_HOSTNAME=http://ratings-service:8080' -e 'REVIEWS_HOSTNAME=http://review-service:9080' productpage