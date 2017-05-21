docker stop opcnt
docker rm opcnt
docker run --name opcnt -d opcnt $1
