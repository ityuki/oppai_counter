docker build -t opcnt .
docker stop opcnt
docker rm opcnt
docker run --name opcnt -v oppai_volume:/tmp/log -d opcnt
