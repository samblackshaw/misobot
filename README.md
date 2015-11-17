Misobot
=======

## Overview

Misobot is a [Twitch](http://twitch.tv) bot originally designed for the [Tohfoo](http://twitch.tv/tohfoo_/profile) channel.

The bot is written in [Node](https://nodejs.org).


## Features

* Automated viewer loyalty system (tokens)
* Viewer line management
* User acknowledgement commands
* General information commands


## Deployment

Pushing to the `production` branch will automatically deploy the bot to its Heroku instance.

The bot should not automatically run upon deployment so that its use can be limited per stream session.


## Setup

After cloning the repository, you must create a `.env` file in the root directory with the following key/value pairs:

    TWITCH_USER={Twitch Username}
    TWITCH_BOT_USER={Twitch Bot Username}
    TWITCH_OAUTH_TOKEN={OAuth Token, get it from http://www.twitchapps.com/tmi/}
    TOKENS_NAME={Stream Currency Name}
    FOLLOWER_NAME={Name of Singular Channel Follower}
    MONGOLAB_URI={MongoDB String}
    MODERATORS={Mods, Comma + Space Separated}
    TWITTER_URL={Twitter URL}
    YOUTUBE_URL={YouTube URL}

Set the database env variables to correspond to a local or remote MongoDB database.

Make sure you have icu4c installed on your machine prior to running `npm install`. If you have Homebrew, this can be done by simply running `brew install icu4c && brew link icu4c --force`.
