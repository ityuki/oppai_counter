docker build -t opcnt .
docker stop opcnt
docker rm opcnt
# これ最悪
docker run --name opcnt -v /tmp/log:/tmp/log -d opcnt
