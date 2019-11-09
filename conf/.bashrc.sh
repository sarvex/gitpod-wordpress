
# WordPress Setup Script
function wp-init-database () {
  # user     = wordpress
  # password = wordpress
  # database = wordpress
  mysql -e "CREATE DATABASE wordpress /*\!40100 DEFAULT CHARACTER SET utf8 */;"
  mysql -e "CREATE USER wordpress@localhost IDENTIFIED BY 'wordpress';"
  mysql -e "GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost';"
  mysql -e "FLUSH PRIVILEGES;"
}

function wp-setup () {
  FLAG="$HOME/.wordpress-installed"

  # search the flag file
  if [ -f $FLAG ]; then
    echo 'WordPress already installed'
    return 1
  fi
  
  # this would cause mv below to match hidden files
  shopt -s dotglob
  
  wp-init-database
  
  REPO_NAME=$(basename $GITPOD_REPO_ROOT)
  DESTINATION=${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}/wp-content/$1/${REPO_NAME}
  
  # install project dependencies
  cd ${GITPOD_REPO_ROOT}
  if [ -f composer.json ]; then
    composer install
  fi
  if [ -f package.json ]; then
    npm install
  fi

  # move the workspace temporarily
  mkdir $HOME/workspace
  mv ${GITPOD_REPO_ROOT}/* $HOME/workspace/

  # create webserver root and install WordPress there
  mkdir -p ${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}
  mv $HOME/wordpress/* ${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}/

  # put the project files in the correct place
  mkdir $DESTINATION
  mv $HOME/workspace/* $DESTINATION
  
  # create a wp-config.php
  cp $HOME/gitpod-wordpress/conf/wp-config.php ${GITPOD_REPO_ROOT}/${APACHE_DOCROOT}/wp-config.php

  cd $DESTINATION
  
  if [ -f $DESTINATION/init.sh ]; then
    $DESTINATION/init.sh
  fi
  
  shopt -u dotglob
  touch $FLAG
}

function wp-setup-theme () {
  wp-setup "themes"
}

function wp-setup-plugin () {
  wp-setup "plugins"
}

export -f wp-setup-theme
export -f wp-setup-plugin

# Helpers

function open-url () {
  URL=$(gp url 8080 | sed -e s/https:\\/\\/// | sed -e s/\\///)
  ENDPOINT=${1:-""}
  
  gp preview $URL
}

function open-dbadmin () {
  open-url "database"
}


function open-phpinfo () {
  open-url "phpinfo"
}

function open-mailcatcher () {
  # TO DO
}