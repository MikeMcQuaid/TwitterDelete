# TwitterDelete
TwitterDelete is a small application to delete your old, unpopular tweets, likes and direct messages.

## Features
- Delete, unlike and unretweet tweets
- Delete direct messages
- Keep tweets/messages based on age and tweeks based on retweet or favourite count
- Delete tweets no longer exposed by Twitter API from a downloaded Twitter archive file

## Usage
To setup locally run:
```bash
git clone https://github.com/mikemcquaid/TwitterDelete
cd TwitterDelete
bundle install
```

Get the Twitter API variables from https://apps.twitter.com and add the following variables to a `.env` file in the `TwitterDelete` folder:
```bash
TWITTER_CONSUMER_KEY=...
TWITTER_CONSUMER_SECRET=...
TWITTER_ACCESS_TOKEN=...
TWITTER_ACCESS_TOKEN_SECRET=...
```

Now run TwitterDelete:
```bash
./twitter_delete.rb --user TwitterUsername
```

Alternatively, you can run TwitterDelete via [Docker](https://www.docker.com/),
which you may wish to do if you do not have [Bundler](https://bundler.io/)
or [Ruby](https://www.ruby-lang.org/) installed. Run TwitterDelete using docker,
do the following:

```bash
docker build -t twitter-delete $PATH_TO_THIS_REPO
docker run --env-file $PATH_TO_ENV_FILE twitter-delete
```

where `$PATH_TO_THIS_REPO` is the location on your filesystem where you
checkout out this repo and `$PATH_TO_ENV_FILE` is the path to a "dot env"
file formatted something like the following:

```
TWITTER_USER=yourtwitterhandle
TWITTER_CONSUMER_KEY=2Hzv0yPsQnPEdNL5RryGlbnCY
TWITTER_CONSUMER_SECRET=8uzRKNl05dyxaSy18jZnibK4mp4vQ2SayMpG2Q38P7SjP1VxWD
TWITTER_ACCESS_TOKEN=148111111-8RFYuBp4fvvlsw6WcO5CQ5cV0cuuxNZEjjlTo7WY
TWITTER_ACCESS_TOKEN_SECRET=kap8Lc5bKl1hXtPpl6JSWclNscDH18o7FghPn8VtLJrph
```

When you need to run the script and actually delete your tweets, rather
than a dry run which is the default, you can add the `--force` flag to 
the `docker run` invocation.

## Status
Works for deleting relevant tweet, likes and messages. I've deleted my old tweets and am not actively working on this but I will accept pull requests.

[![Build Status](https://travis-ci.org/MikeMcQuaid/TwitterDelete.svg?branch=master)](https://travis-ci.org/MikeMcQuaid/TwitterDelete)

## Contact
[Mike McQuaid](mailto:mike@mikemcquaid.com)

## License
TwitterDelete is licensed under the [AGPLv3 License](https://en.wikipedia.org/wiki/Affero_General_Public_License).
The full license text is available in [LICENSE.txt](https://github.com/mikemcquaid/TwitterDelete/blob/master/LICENSE.txt).
