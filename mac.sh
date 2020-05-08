#!/usr/bin/env bash

if [[ ! -d "$HOME/.bin/" ]]; then
  mkdir "$HOME/.bin"
fi

if [ ! -f "$HOME/.bashrc" ]; then
  touch $HOME/.bashrc
fi

println() {
  printf "%b\n" "$1"
}

brew_install_or_upgrade() {
  if brew_is_installed "$1"; then
    if brew_is_upgradable "$1"; then
      brew upgrade "$@"
      println "Upgraded $1"
    else
      println "$1 already installed"
    fi
  else
    brew install "$@"
  fi
}

brew_expand_alias() {
  brew info "$1" 2>/dev/null | head -1 | awk '{gsub(/:/, ""); print $1}'
}

brew_is_installed() {
  local NAME=$(brew_expand_alias "$1")

  brew list -1 | grep -Fqx "$NAME"
}

brew_is_upgradable() {
  local NAME=$(brew_expand_alias "$1")

  local INSTALLED=$(brew ls --versions "$NAME" | awk '{print $NF}')
  local LATEST=$(brew info "$NAME" 2>/dev/null | head -1 | awk '{gsub(/,/, ""); print $3}')

  [ "$INSTALLED" != "$LATEST" ]
}

if ! command -v brew &>/dev/null; then
  println "The missing package manager for OS X"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

  if ! grep -qs "recommended by brew doctor" ~/.bashrc; then
    println "Put Homebrew location earlier in PATH..."
      printf '\n# recommended by brew doctor\n' >> ~/.bashrc
      printf 'export PATH="/usr/local/bin:$PATH"\n' >> ~/.bashrc
      export PATH="/usr/local/bin:$PATH"
  fi
else
  println "Homebrew already installed. Skipping..."
fi

println "Updating Homebrew formulas..."
brew update

println "Installing iTerm2..."
  brew cask install iterm2

println "Installing Firefox..."
  brew cask install firefox

println "Installing Github..."
  brew cask install github

println "Installing Atom..."
  brew cask install atom

println "Installing Slack..."
  brew cask install slack

println "Installing Spotify..."
  brew cask install spotify

println "Installing Postgres..."
  brew_install_or_upgrade 'postgres'

println "Installing Postgres.app..."
  brew cask install postgres

println "Installing Redis..."
  brew_install_or_upgrade 'redis'

println "Installing MySQL 5.6..."
  brew_install_or_upgrade 'mysql@5.6'

println "Installing ImageMagick, to crop and resize images..."
  brew_install_or_upgrade 'imagemagick'

println "Installing ChromeDriver, to drive Chrome via Selenium..."
  brew tap homebrew/cask
  brew cask install chromedriver

println "Installing Docker..."
  brew cask install docker

println "Installing docker-compose..."
  brew_install_or_upgrade 'docker-compose'

println "Installing Git..."
  brew_install_or_upgrade 'git'

node_version="0.10.40"

println "Installing NVM, Node.js, and NPM, for running apps and installing JavaScript packages..."
  brew_install_or_upgrade 'nvm'

  if ! grep -qs 'source $(brew --prefix nvm)/nvm.sh' ~/.bashrc; then
    printf 'export PATH="$PATH:/usr/local/lib/node_modules"\n' >> ~/.bashrc
    printf 'source $(brew --prefix nvm)/nvm.sh\n' >> ~/.bashrc
  fi

  source $(brew --prefix nvm)/nvm.sh
  nvm install "$node_version"

  println "Setting $node_version as the global default nodejs..."
  nvm alias default "$node_version"

if ! command -v rvm &>/dev/null; then

  println "Installing rvm, to change Ruby versions..."
  curl -sSL https://get.rvm.io | bash -s stable --ruby --auto-dotfiles
  source ~/.rvm/scripts/rvm

else

  println "Rvm already installed. Skipping..."
fi

println "Upgrading and linking OpenSSL..."
  brew_install_or_upgrade 'openssl'
  brew unlink openssl && brew link openssl --force

ruby_version="2.6.6"

println "Installing Ruby $ruby_version..."
  rvm install "$ruby_version"
  rvm use "$ruby_version"

println "Updating to latest Rubygems version..."
  gem update --system

println "Configuring Bundler for faster, parallel gem installation..."
  gem install bundler --no-ri --no-rdoc
  number_of_cores=$(sysctl -n hw.ncpu)
  bundle config --global jobs $((number_of_cores - 1))

println "Installing Heroku CLI client..."
  brew tap heroku/brew
  brew_install_or_upgrade 'heroku/brew/heroku'

println "Installing the heroku-config plugin to pull config variables locally to be used as ENV variables..."
  heroku plugins:install heroku-config
