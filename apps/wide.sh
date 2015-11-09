#!/bin/sh

git clone https://github.com/b3log/wide
apt-get install go
# Get dependencies
go get
go get github.com/visualfc/gotools github.com/nsf/gocode github.com/bradfitz/goimports

# Compile wide
go build


# Get Docker image
docker pull 88250/wide:latest
docker run -p 127.0.0.1:7070:7070 88250/wide:latest ./wide -docker=true -channel=ws://127.0.0.1:7070
echo Open browser: http://127.0.0.1:7070
