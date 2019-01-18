[![Docker Repository on Quay](https://quay.io/repository/gamerefinery/keycloak-server/status?token=a62058c3-143f-4a51-8623-11d9debd8f37 "Docker Repository on Quay")](https://quay.io/repository/gamerefinery/keycloak-server)

#  Keycloak Docker Image

Build container image

`$ docker build --tag keycloak-server .`

If you would like to build image for clustered mode add build argument

`$ docker build  --build-arg OPERATING_MODE=clustered --tag keycloak-server .`

Get image id and and tag image for dockerhub

`$ docker images`
`$ docker tag IMAGE_ID tpahonen/keycloak-server:v3.4.2`

Login to dockerhub

`$ docker login`

Push image

`$ docker push tpahonen/keycloak-server:v3.4.2` 

