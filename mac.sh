#!/usr/bin/env bash

if [ ! -f "$HOME/.zshrc" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

if [[ ! -d "$HOME/.bin/" ]]; then
  mkdir "$HOME/.bin"
fi

if [ ! -f "$HOME/.bashrc" ]; then
  touch $HOME/.bashrc
fi

if [[ `uname -m` == 'arm64' ]]; then
  softwareupdate --install-rosetta
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
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  if ! grep -qs "recommended by brew doctor" ~/.bashrc; then
    println "Put Homebrew location earlier in PATH..."
      printf '\n# recommended by brew doctor\n' >> ~/.bashrc
      printf 'export PATH="/usr/local/bin:$PATH"\n' >> ~/.bashrc
      export PATH="/usr/local/bin:$PATH"

    (echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> ~/.zshrc
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
else
  println "Homebrew already installed. Skipping..."
fi

println "Updating Homebrew formulas..."
brew update

println "Installing iTerm2..."
  brew reinstall --cask iterm2

println "Installing Firefox..."
  brew reinstall --cask firefox

println "Installing Github..."
  brew reinstall --cask github

println "Installing Slack..."
  brew reinstall --cask slack

println "Installing Redis..."
  brew_install_or_upgrade 'redis'

println "Installing ImageMagick, to crop and resize images..."
  brew_install_or_upgrade 'imagemagick'

println "Installing ChromeDriver, to drive Chrome via Selenium..."
  brew reinstall --cask chromedriver

println "Installing Docker..."
  brew reinstall --cask docker

println "Installing docker-compose..."
  brew_install_or_upgrade 'docker-compose'

println "Installing Git..."
  brew_install_or_upgrade 'git'

node_version="18.20.2"

println "Installing NVM, Node.js, and NPM, for running apps and installing JavaScript packages..."
  brew_install_or_upgrade 'nvm'

  if ! grep -qs 'source $(brew --prefix nvm)/nvm.sh' ~/.zshrc; then
    printf 'export PATH="$PATH:/usr/local/lib/node_modules"\n' >> ~/.zshrc
    printf 'source $(brew --prefix nvm)/nvm.sh\n' >> ~/.zshrc
  fi

  source $(brew --prefix nvm)/nvm.sh
  nvm install "$node_version"

  println "Setting $node_version as the global default nodejs..."
  nvm alias default "$node_version"

if ! command -v rbenv &>/dev/null; then
  println "Installing rbenv, to change Ruby versions..."
  brew_install_or_upgrade 'rbenv' 
  brew_install_or_upgrade 'ruby-build'
  echo 'eval "$(~/.rbenv/bin/rbenv init - zsh)"' >> ~/.zshrc
  source ~/.zshrc
else
  println "rbenv already installed. Skipping..."
fi

ruby_version="3.2.3"

println "Installing Ruby $ruby_version..."
  rbenv install "$ruby_version"

println "Configuring Bundler for faster, parallel gem installation..."
  gem install bundler --no-ri --no-rdoc
  number_of_cores=$(sysctl -n hw.ncpu)
  bundle config --global jobs $((number_of_cores - 1))

println "Installing Heroku CLI client..."
  brew tap heroku/brew && brew install heroku
