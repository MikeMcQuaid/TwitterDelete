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

## Status
Works for deleting relevant tweet, likes and messages. I've deleted my old tweets and am not actively working on this but I will accept pull requests.

[![Build Status](https://travis-ci.org/MikeMcQuaid/TwitterDelete.svg?branch=master)](https://travis-ci.org/MikeMcQuaid/TwitterDelete)

## Contact
[Mike McQuaid](mailto:mike@mikemcquaid.com)

## License
TwitterDelete is licensed under the [AGPLv3 License](https://en.wikipedia.org/wiki/Affero_General_Public_License).
The full license text is available in [LICENSE.txt](https://github.com/mikemcquaid/TwitterDelete/blob/master/LICENSE.txt).
