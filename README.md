# Setup

Script to install base environment for Ruby development.

## Install on Mac OS X

```
curl -L https://raw.githubusercontent.com/ombulabs/setup/master/mac.sh | bash
```

## Installed libraries

The script will install:

* homebrew
* imagemagick
* oh-my-zsh
* mysql
* postgres
* redis
* rvm
* ruby-2.1.7
* nvm
* qt
* chromedriver
* github desktop
* heroku-toolbelt
* spotify
* slack
* firefox

# FAQ

## I get a permissions error. Why?

You may need to update your local libraries directory. 

```
sudo chown -R $(whoami):admin /Library/Caches/Homebrew
sudo chown -R $(whoami):admin /opt/homebrew-cask/
sudo chown -R $(whoami):admin /usr/local/
```

## But I don't want \<application> installed. 

Just remove \<application> from https://github.com/ombulabs/setup/blob/master/mac.sh

## Contributions

Please fork this repository and send a pull request with the changes. Thanks!
