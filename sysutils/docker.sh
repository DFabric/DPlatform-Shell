#!/bin/sh

# Verify that you have wget installed. If wget isn’t installed, install it
if hash wget 2>/dev/null
	then $install wget
fi
# Get the latest Docker package.
wget -qO- https://get.docker.com/ | sh

echo Docker installed
