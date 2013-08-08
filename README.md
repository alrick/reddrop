# Reddrop
-----------

## Description
Reddrop is a plugin for Redmine that allows users of that service to sync their documents and files using Dropbox. 
Reddrop is a replacement for the _files_ and _documents_ tabs in Redmine and allows to browse a Dropbox's folder hierarchically.

## Donate
If you like it, feel free to donate some love ;)

[![Donate](https://dl.dropboxusercontent.com/s/lo09p6qmz5o20so/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=EP9QQNXD9BRNE)

## Compatibility
Reddrop is compatible with the following versions :

* 2.0.3 (tested)
* 2.3.0 (tested)

Let me know if you succeeded run it on other versions.

## Install & Uninstall
### Before install
You have to get your own Dropbox's API keys : 

1. Go to https://www.dropbox.com/developers/apps
2. Create your application (Warning : you need Access level : Full Dropbox)
3. Ask for production status
4. Configure the _appkey_ and _appsecret_ in _redmine_reddrop/app/models/daccess.rb_

### How to install
Once you've configured your Dropbox's keys, simply follow this steps : 

1. add the `redmine_reddrop` folder in the `#{RAILS_ROOT}/plugins` folder of your Redmine installation.
2. run `$ bundle install`
3. run `$ rake redmine:plugins:migrate RAILS_ENV=production` (you should make a DB backup before)
4. restart Redmine

And that's all, you should be able to view the plugin in _Administration -> Plugins_ and start using it.

### How to uninstall
To uninstall Reddrop, simply follow this steps :

1. run `$ rake redmine:plugins:migrate NAME=redmine_reddrop VERSION=0 RAILS_ENV=production` (you should make a DB backup before)
2. remove `redmine_reddrop` from `#{RAILS_ROOT}/plugins`
3. run `$ bundle install`
4. restart Redmine

And that's all, the plugin is removed from your Redmine.

## Functionalities
### User functionalities
#### Link your Dropbox account to Redmine
You have to link your account before you can use the plugin.

In order to link you Dropbox account to Redmine go to "Reddrop Linking" page with the top left menu.
On this page, you can link or unlink a Dropbox account depending on whether you have already linked your account or not.

#### Reddrop a project
When you've linked your Dropbox account with your Redmine account, you're able to "Reddrop" a project.

Go on a project page and then Reddrop tab. You will find a "Reddrop this project" link on the sidebar of each Reddrop tab. Once you've Reddroped a project, the structure of folders will be generated on your Dropbox and other users will be able to consult them. The generated folders are located at `/Reddrop/project-id/` in your Dropbox. Each changes in your Dropbox folders will be reflected in Redmine.

#### Consult folders of a project
Go on a project page and then Reddrop Tab. In the main part of the page, you'll find all users that have reddroped this project.
Select a user and you will be able to browse its folders, add and remove files.

#### Share a Reddrop folder
You can use the Dropbox "shared folders" option to share folders that are linked to Redmine with Reddrop. Simply share any folders you want to but remember that only one person have to Reddrop this folder to avoid duplication.

#### Usual process for a group
Only **one person** reddrop the project on Redmine and share it with others with Dropbox "shared folders" functionality.

### Admin functionalities
#### Configure permissions
There is two permissions that you can manage : "Reddrop consult projectfolders" which allows consulting linked Dropboxs and "Reddrop interact projectfolders" which allows to add and remove files in the linked Dropboxs.

In order to modify this permissions, simply go to _Administration -> Roles and permissions_. They are grouped as "Reddrop".

#### Configure generated folders
As an admin, you can configure folders that are generated in the user's Dropbox when they Reddrop a project.

In order to access this functionality, go to _Administration -> Reddrop_ settings.
On this page you can add, remove or rename folders that are generated.

## Goodies
### Logos
![16](https://dl.dropboxusercontent.com/s/gad8ki5u4v531dr/reddrop_16.png) 
![32](https://dl.dropboxusercontent.com/s/9sakooz0zqvo234/reddrop_32.png) 
![64](https://dl.dropboxusercontent.com/s/8voz7sccasf0m3w/reddrop_64.png) 
![128](https://dl.dropboxusercontent.com/s/0loez2xn3qw8r9h/reddrop_128.png)

### Preview
![wrong](https://dl.dropbox.com/s/bzanck89rh2ude6/reddrop_projectroot.png)

## License
Copyright (c) 2012 Curly Brackets

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
