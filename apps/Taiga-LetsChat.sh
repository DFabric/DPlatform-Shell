#!/bin/sh

# Taiga Back

# In your Taiga back python virtualenv install the pip package taiga-contrib-letschat with:

pip install taiga-contrib-letschat

# Then modify your settings/local.py and include the line:

INSTALLED_APPS += ["taiga_contrib_letschat"]

# Migrations to generate the new need table

python manage.py migrate taiga_contrib_letschat

# Taiga Front

# Download in your dist/js/ directory of Taiga front the taiga-contrib-letschat compiled code:

cd dist/js
wget "https://raw.githubusercontent.com/taigaio/taiga-contrib-letschat/$(pip show taiga-contrib-letschat | awk '/^Version: /{print $2}')/front/dist/letschat.js"

# Include in your dist/js/conf.json in the contribPlugins list the value "/js/letschat.js":

...
    "contribPlugins": ["/js/letschat.js"]
...
