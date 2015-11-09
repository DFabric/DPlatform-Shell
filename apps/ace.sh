#!/bin/sh

git clone https://github.com/ajaxorg/ace/tree/36e6744a5f40df0da52ff22b3bc729657c056e09

./static.py

npm install mime
node ./static.js
