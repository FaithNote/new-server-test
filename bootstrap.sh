GIT_USER=$1
GIT_PASSWORD=$2

#############################################################
# Build OS environment and get dependencies
#############################################################
sudo apt-get -y clean
sudo apt-get update
sudo apt-get -y upgrade

# We have to install this bullshit because, as always, the standard Ubuntu repo
# has a criminally old version of node
sudo apt-get install -y python-software-properties software-properties-common python g++ make
sudo add-apt-repository -y ppa:chris-lea/node.js
sudo apt-get update

echo '==> Installing base os dependencies'
sudo apt-get -y install nginx nodejs git curl htop monit

#############################################################
# Download and build application
#############################################################
if [$GIT_USER]; then
    echo '==> GITing the app'
    cd /home
    git clone https://$GIT_USER:$GIT_PASSWORD@bitbucket.org/nswarr/flipnote-server.git
    cd flipnote-server
fi

echo '==> Installing grunt and loading app dependencies'
sudo npm install -g grunt-cli grunt request
npm install
grunt build

#############################################################
# Update nginx configuration
#############################################################
echo '==> Updating nginx'
sudo cp -f ./install/weloveflipnote /etc/nginx/sites-enabled/weloveflipnote
sudo service nginx restart

# Only happens on server deployment
if [$GIT_USER]; then
    #############################################################
    # Create application user
    #############################################################
    echo '==> Creating flipnote user'
    useradd -m -p dfbaNl6JWRVrI -s /bin/bash flipnote
    chown -R flipnote /home/flipnote-server/

    #############################################################
    # Create upstart service script
    #############################################################
    echo '==> Creating upstart script'
    cp -f ./install/upstart /etc/init/flipnote.conf
    service flipnote start

    #############################################################
    # Create cron job to automatically deploy new code
    #############################################################
    echo '==> Creating cron job for app updates'
    chmod +x ./install/cron_update_app
    crontab ./install/cron_update_app
    service cron restart
fi