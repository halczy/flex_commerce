## Flex Commerce Dependencies 

The following installation instruction is tested on Ubuntu 16.04 and Debian 9.

### System
ImageMagic and PostgreSQL library
```bash
sudo apt install imagemagick libmagickcore-dev libmagickwand-dev graphicsmagick libpq-dev
```

Javascript Runtime via NodeJS
```bash
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
sudo apt install -y nodejs
```

PostgreSQL

Please this visit this [page](https://www.postgresql.org/download/) for guides on setting up PostgreSQL

```bash
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  sudo apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" | sudo tee /etc/apt/sources.list.d/pgdg.list
sudo apt update
sudo apt install postgresql-10 
```

Yarn

Please visit this [page](https://yarnpkg.com/en/docs/install) for the latest instruction.
```bash
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
sudo apt update && sudo apt install yarn
```

### Ruby
Please visit this [page](https://rvm.io/) for the latest instruction.

RVM
```bash
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB

\curl -sSL https://get.rvm.io | bash -s stable
```

Ruby
```bash
rvm install 2.4.2
rvm use 2.4.2 --default
```

Bundler
```bash
gem install bundler
```