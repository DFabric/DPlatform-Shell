#!/bin/sh
. sysutils/nodejs.sh
. sysutils/mongodb.sh
cd $HOME
# https://docs.nodebb.org/en/latest/installing/os.html

## Installing NodeBB
# Install the base software stack
$install mongodb imagemagick git build-essential

# Clone the repository
git clone -b v0.9.x https://github.com/NodeBB/NodeBB.git nodebb

# Obtain all dependencies required by NodeBB via NPM
cd nodebb
npm install --production

# Install NodeBB by running the app with –setup flag
./nodebb setup

# Run the NodeBB forum
./nodebb start

whiptail --msgbox "NodeBB successfully installed!

Open http://$IP:4567 in your browser

Run the NodeBB forum: cd nodebb && ./nodebb start" 12 64

# https://www.npmjs.com/package/nodebb-plugin-blog-comments
<<ghost_comment_plugin
Installation

First install the plugin:

npm install nodebb-plugin-blog-comments

Activate the plugin in the ACP and reboot NodeBB. Head over to the Blog Comments section in the ACP and select the Category ID you'd like to publish your blog content to (default is Category 1). Make sure you put the correct URL to your blog.
Ghost Installation

Paste this any where in yourtheme/post.hbs, somewhere between {{#post}} and {{/post}}. All you have to edit is line 3 (nbb.url) - put the URL to your NodeBB forum's home page here.

<a id="nodebb/comments"></a>
<script type="text/javascript">
var nbb = {};
nbb.url = '//your.nodebb.com'; // EDIT THIS

(function() {
nbb.articleID = '{{../post.id}}'; nbb.title = '{{../post.title}}';
nbb.tags = [{{#../post.tags}}"{{name}}",{{/../post.tags}}];
nbb.script = document.createElement('script'); nbb.script.type = 'text/javascript'; nbb.script.async = true;
nbb.script.src = nbb.url + '/plugins/nodebb-plugin-blog-comments/lib/ghost.js';
(document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(nbb.script);
})();
</script>
<script id="nbb-markdown" type="text/markdown">{{{../post.markdown}}}</script>
<noscript>Please enable JavaScript to view comments</noscript>

If you wish, you can move <a id="nodebb/comments"></a> to where you want to place the actual comments widget.

Comments Counter

You may optionally put a "# of comments" counter anywhere on the page with the following code:

<span id="nodebb-comments-count"></span> Comments




Author and Category information

To use NodeBB's category and author information (instead of using Ghost's user/tag system), there are two elements that this plugin searches for:

Published by <span id="nodebb-comments-author"></span> in <span id="nodebb-comments-category"></span>
ghost_comment_plugin
