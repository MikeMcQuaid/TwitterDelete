# TwitterDelete 💀 (archived)

TwitterDelete was a small application to delete your old, unpopular tweets and likes.

> Starting February 9, we will no longer support free access to the Twitter API, both v2 and v1.1. A paid basic tier will be available instead

<https://twitter.com/TwitterDev/status/1621026986784337922>

I have zero interest maintaining anything using the Twitter API given this.

If you're still using Twitter: get yourself to Mastodon which:

- has TwitterDelete behaviour already built-in as a feature
- is nice like Twitter was 10 years ago

Come on, [follow me on Mastodon](https://mastodon.mikemcquaid.com/@mike), it's lovely over here.

## Features

- Delete, unlike and unretweet tweets
- Keep tweets based on age and tweaks based on retweet or favourite count
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

If you fork this PR you can also used the [GitHub Actions scheduled workflow](https://github.com/MikeMcQuaid/TwitterDelete/blob/master/.github/workflows/scheduled.yml) combined with secrets on your fork to run this automatically.

## Status

Works for deleting relevant tweet and likes. I delete my old tweets and am not actively working on improving this but I will accept pull requests.

## Contact

[Mike McQuaid](mailto:mike@mikemcquaid.com)

## License

TwitterDelete is licensed under the [AGPLv3 License](https://en.wikipedia.org/wiki/Affero_General_Public_License).
The full license text is available in [LICENSE.txt](https://github.com/mikemcquaid/TwitterDelete/blob/master/LICENSE.txt).
