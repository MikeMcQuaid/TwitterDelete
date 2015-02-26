# TwitterDelete
TwitterDelete is a small application to delete your old, unpopular tweets.

## Features
- Delete, unfavorite and unretweet tweets
- Keep tweets based on age, retweet or favourite count
- Delete tweets no longer exposed by Twitter API from a downloaded Twitter archive file

## Usage
To use locally run:
```bash
git clone https://github.com/mikemcquaid/TwitterDelete
cd TwitterDelete
bundle install
# Get these from apps.twitter.com
export TWITTER_CONSUMER_KEY=".."
export TWITTER_CONSUMER_SECRET="..."
export TWITTER_ACCESS_TOKEN="..."
export TWITTER_ACCESS_TOKEN_SECRET="..."
bundle exec ./twitter_delete.rb --user TwitterUsername
```

## Status
Still a work-in-progress but works for deleting the relevant tweets. I may turn this into a web application.

## Contact
[Mike McQuaid](mailto:mike@mikemcquaid.com)

## License
TwitterDelete is licensed under the [MIT License](http://en.wikipedia.org/wiki/MIT_License).
The full license text is available in [LICENSE.txt](https://github.com/mikemcquaid/TwitterDelete/blob/master/LICENSE.txt).
