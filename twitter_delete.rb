#!/usr/bin/env ruby
require "twitter"
require "trollop"
require "csv"

MAX_API_TWEETS = 3200
MAX_TWEETS_PER_PAGE = 250
MAX_TWEETS_PER_REQUEST = 100

# Get these from apps.twitter.com
unless `ENV` =~ /TWITTER/
  ENV["TWITTER_CONSUMER_KEY"] = ""
  ENV["TWITTER_CONSUMER_SECRET"] = ""
  ENV["TWITTER_ACCESS_TOKEN"] = ""
  ENV["TWITTER_ACCESS_TOKEN_SECRET"] = ""
end

@options = Trollop::options do
  opt :force, "Actually delete/unfavourite/unretweet tweets"
  opt :user, "The Twitter username to purge", type: :string
  opt :csv, "Twitter archive tweets.csv file", type: :string
  opt :unfav, "Unfavourite my favorite tweets"
  opt :days, "Keep tweets under this many days old", default: 28
  opt :rts, "Keep tweet with this many retweets", default: 5
  opt :favs, "Keep tweets with this many favourites", default: 5
end

Trollop::die :user, "must be set" unless @options[:user_given]
if @options[:csv_given] && !File.exist?(@options[:csv])
  Trollop::die :csv, "must be a file that exists"
end

[ "TWITTER_CONSUMER_KEY", "TWITTER_CONSUMER_SECRET",
  "TWITTER_ACCESS_TOKEN", "TWITTER_ACCESS_TOKEN_SECRET"].each do |env|
  Trollop::die "#{env} environment variable must be set" unless ENV[env]
end

@client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV["TWITTER_CONSUMER_KEY"]
  config.consumer_secret = ENV["TWITTER_CONSUMER_SECRET"]
  config.access_token = ENV["TWITTER_ACCESS_TOKEN"]
  config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
end

@oldest_tweet_time_to_keep = Time.now - @options[:days]*24*60*60

def too_new? tweet
  tweet.created_at > @oldest_tweet_time_to_keep
end

def too_new_or_popular? tweet
  return true if too_new? tweet
  return false if tweet.retweeted?
  return false if tweet.text.start_with? "RT @"

  if tweet.retweet_count >= @options[:rts]
    puts "Ignoring tweet: too RTd: #{tweet.text}"
    return true
  end

  if tweet.favorite_count >= @options[:favs]
    puts "Ignoring tweet: too favourited: #{tweet.text}"
    return true
  end

  false
end

def api_call method, *args
  @client.send method, *args
rescue Twitter::Error::TooManyRequests => error
  puts "Rate limit exceeded; waiting until #{error.rate_limit.reset_at}"
  sleep error.rate_limit.reset_in
  retry
end

user = api_call :user, @options[:username]
tweets_to_delete = []

unless !@options[:unfav]
  tweets_to_unfavourite = []
  puts "==> Checking favourites..."
  total_favorites = [user.favorites_count, MAX_API_TWEETS].min
  oldest_favorites_page = (total_favorites / MAX_TWEETS_PER_PAGE).to_i

  oldest_favorites_page.downto(0) do |page|
    tweets = api_call :favorites, count: MAX_TWEETS_PER_PAGE, page: page
    tweets_to_unfavourite += tweets.reject &method(:too_new?)
  end

  puts "==> Unfavoriting #{tweets_to_unfavourite.size} tweets"
  tweets_to_unfavourite.each_slice(MAX_TWEETS_PER_REQUEST) do |tweets|
    api_call :unfavorite, tweets
  end
end

puts "Checking timeline..."
total_tweets = [user.statuses_count, MAX_API_TWEETS].min
oldest_tweets_page = (total_tweets / MAX_TWEETS_PER_PAGE).to_i

oldest_tweets_page.downto(0) do |page|
  tweets = api_call :user_timeline, count: MAX_TWEETS_PER_PAGE, page: page
  tweets_to_delete += tweets.reject &method(:too_new_or_popular?)
end

if @options[:csv_given]
  puts "==> Checking archive CSV..."
  csv_tweet_ids = []
  CSV.foreach(@options[:csv]) do |row|
    tweet_id = row.first
    next if tweet_id == "tweet_id"
    csv_tweet_ids << tweet_id
  end

  csv_tweet_ids.each_slice(MAX_TWEETS_PER_REQUEST) do |tweet_ids|
    tweets = api_call :statuses, tweet_ids
    tweets_to_delete += tweets.reject &method(:too_new_or_popular?)
  end
end

puts "==> Deleting #{tweets_to_delete.size} tweets"
tweets_not_found = []
tweets_to_delete.each_slice(MAX_TWEETS_PER_REQUEST) do |tweets|
  begin
    api_call :destroy_status, tweets
  rescue Twitter::Error::NotFound => error
    tweets_not_found += tweets
  end
end

tweets_not_found.each do |tweet|
  begin
    api_call :destroy_status, tweet
  rescue Twitter::Error::NotFound => error
  end
end
