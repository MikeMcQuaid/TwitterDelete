# TwitterDelete
TwitterDelete is a small application to delete your old, unpopular tweets.

## Features
- Delete, unfavorite and unretweet tweets
- Keep tweets based on age, retweet or favourite count
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

## Status
Works for deleting relevant tweets. I've deleted all my tweets and don't really use Twitter any more so am not actively working on this but will accept pull requests.

[![Build Status](https://travis-ci.org/mikemcquaid/TwitterDelete.svg?branch=master)](https://travis-ci.org/mikemcquaid/TwitterDelete)

## Contact
[Mike McQuaid](mailto:mike@mikemcquaid.com)

## License
TwitterDelete is licensed under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
The full license text is available in [LICENSE.txt](https://github.com/mikemcquaid/TwitterDelete/blob/master/LICENSE.txt).
