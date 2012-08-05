# Reddrop
-----------

## Description
Reddrop est un plugin pour Redmine qui permet aux utilisateurs de ce service de synchroniser leurs documents et fichiers avec Dropbox.
Reddrop remplace les onglets _files_ et _documents_ de Redmine et permet de naviguer un dossier spécifique de Dropbox de manière hierarchique.

## Donation
Si vous apprécier Reddrop, n'hésitez pas à faire une donation ;)

[![Donate](https://dl.dropbox.com/s/78atptrrwraymgb/btn_donate_LG.gif)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=EP9QQNXD9BRNE)

## Compatibilité
Reddrop a été testé avec Redmine 2.0.3. Si vous l'avez mis en place avec une autre version, faites-le moi savoir!

## Installation & désinstallation (Redmine 2.0.3)
### Avant l'installation
Il est nécessaire d'optenir vos propres clés pour l'API Dropbox :

1. Aller sur https://www.dropbox.com/developers/apps
2. Créer son application
3. Demander le status de production
4. Configurer les _appkey_ and _appsecret_ dans _redmine_reddrop/app/models/daccess.rb_

### Installation
Une fois les clés configurées, suivre les étapes suivantes :

1. ajouter le dossier `redmine_reddrop` dans le dossier `#{RAILS_ROOT}/plugins` de l'installation Redmine.
2. effectuer la commande `$ rake redmine:plugins:migrate RAILS_ENV=production` (une backup de la base de données est recommandée avant)
3. effectuer la commande `$ bundle install`
4. redémarrer Redmine

Et voilà, le plugin devrait être visible sous _Administration -> Plugins_, vous pouvez maintenant l'utiliser.

### Désinstallation
Pour désinstaller Reddrop, suivre les étapes suivantes :

1. effecter la commande `$ rake redmine:plugins:migrate NAME=redmine_reddrop VERSION=0 RAILS_ENV=production` (une backup de la base de données est recommandée avant)
2. supprimer le répertoire `redmine_reddrop` de `#{RAILS_ROOT}/plugins`
3. effectuer la commande `$ bundle install`
4. redémarrer Redmine

Et voilà, le plugin est maintenant désinstallé de Redmine.

## Fonctionnalités
### Fonctionnalités utilisateur
#### Lier son compte Dropbox à Redmine
Il est nécessaire de lié son compte avant de pouvoir utiliser le plugin.

Afin de lier son compte Dropbox à Redmine, aller sur "Reddrop Linking" via le menu en haut à gauche.
Sur cette page, il est possible de lier ou délier un compte Dropbox en fonction de si vous avez déjà effectué cette opération ou non.

#### Reddrop un projet
Une fois un compte Dropbox lié avec votre compte Redmine, il est possible de "Reddrop" un projet.

Aller sur la page d'un projet, puis onglet Reddrop. Un lien "Reddrop this project" est présent sur la sidebar. Une fois un projet "Reddropé", une structure de dossier sera générée sur votre Dropbox et les autres utilisateurs seront alors capables de les consulter. Les dossiers générés se situent dans le répertoire `/Reddrop/project-id/` de votre Dropbox. Chaque changement effectué dans ce dossier de votre Dropbox sera également effectué sur Redmine.

#### Consulter les dossiers d'un projet
Aller sur la page d'un projet puis onglet Reddrop. Sur la partie principale de la page, se trouve la liste de tous les utilisateurs qui ont "Reddropé" ce projet.
Après avoir choisi un utilisateur, il est possible de consulter ses dossiers ainsi qu'ajouter et supprimer des fichiers.

#### Partager un dossier Reddrop
Il est possible d'utiliser la fonctionnalité de partage de Dropbox pour partager les dossiers liés à Redmine via Reddrop. Il suffit de le partager comme tout autre dossier de Dropbox, il est cependant important de noter qu'une seule personne devra alors "Reddrop" ce dossier afin d'éviter une duplication.

#### Processus habituel pour un groupe
Seule **une personne** "Reddrop" le projet sur Redmine, il va ensuite partager le dossier du projet créé sous Reddrop avec les autres membres du groupe.

### Fonctionnalité administrateur
#### Configurer les permissions
Il est possible de gérer deux permissions : "Reddrop consult projectfolders" qui permet de consulter les Dropbox liées aux projets ainsi que "Reddrop interact projectfolders" qui permet d'autoriser l'ajout et la suppression de fichiers aux Dropbox liées via Redmine.

Afin de modifier ces permissions, il suffit d'aller sous _Administration -> Roles and permissions_. Les permissions sont regroupées sous le label "Reddrop".

#### Configurer les dossiers générés
En tant qu'admin, il est possible de configurer les dossiers générés dans la Dropbox d'un utilisateur lorsque celui-ci "Reddrop" un projet.

Afin d'accéder à cette fonctionnalité, aller sur _Administration -> Reddrop settings_.
Sur cette page, il est possible d'ajouter, supprimer et renommer les dossiers qui seront générés.

## Goodies
### Logos
![16](https://dl.dropbox.com/s/yzucc8550au2ice/reddrop_16.png) 
![32](https://dl.dropbox.com/s/s2g02lhozml8v9r/reddrop_32.png) 
![64](https://dl.dropbox.com/s/ckjv8f9kejmmwl6/reddrop_64.png) 
![128](https://dl.dropbox.com/s/jjttk7knsi6eey3/reddrop_128.png)

### Aperçu
![wrong](https://dl.dropbox.com/s/4dprvkb5arj10ui/reddrop_projectroot.png)

## License
Copyright (c) 2012 Curly Brackets

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.