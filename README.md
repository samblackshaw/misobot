Misobot
=======

## Overview

Misobot is a [Cinch](https://github.com/cinchrb/cinch)-based [Twitch](http://twitch.tv) bot originally designed for the [Tohfoo](http://twitch.tv/tohfoo_/profile) channel.

The bot is written in [Ruby](http://ruby-lang.org) and utilizes popular gems such as [ActiveRecord](https://github.com/rails/rails/tree/master/activerecord) and [ActiveSupport](https://github.com/rails/rails/tree/master/activesupport).


## Features

* Persistent data storage using [Heroku](http://heroku.com) PostgreSQL databases
* Automated viewer loyalty system (tokens)
* Viewer line management
* Giveaway raffles (to be implemented...)


## Deployment

Pushing to the `production` branch will automatically deploy the bot to its Heroku instance. To actually run the bot, use the command:

    heroku run bundle exec ruby app/misobot.rb

The bot does not automatically run upon deployment so that its use can be limited per stream session.


## Setup

After cloning the repository, you must create a `.env` file in the root directory with the following key/value pairs:

    TWITCH_USER={Twitch Username}
    TWITCH_BOT_USER={Twitch Bot Username}
    TWITCH_OAUTH_TOKEN={OAuth Token, get it from http://www.twitchapps.com/tmi/}
    TOKENS_NAME={Stream Currency Name}
    HEROKU_DATABASE_NAME={PG Database Name}
    HEROKU_DATABASE_HOST={PG Database Host}
    HEROKU_DATABASE_PORT={PG Database Port}
    HEROKU_DATABASE_USER={PG Database User}
    HEROKU_DATABASE_PASSWORD={PG Database Password}

Set the database env variables to correspond to a local or remote PostgreSQL database.
