#!/usr/bin/env ruby
require "pathname"
ENV["BUNDLE_GEMFILE"] ||= File.expand_path "#{__FILE__}/../Gemfile"
require "rubygems"
require "bundler/setup"

require "twitter"
require "trollop"
require "csv"
require "dotenv"

MAX_API_TWEETS_MESSAGES = 3200
MAX_TWEETS_MESSAGES_PER_PAGE = 200.0
MAX_TWEETS_MESSAGES_PER_REQUEST = 100
MAX_LIKES_PER_PAGE = 100.0

Dotenv.load

@options = Trollop.options do
  opt :force, "Actually delete/unlike/unretweet tweets/messages", type: :boolean, default: false
  opt :user, "The Twitter username to purge", type: :string, default: ENV["TWITTER_USER"]
  opt :csv, "Twitter archive tweets.csv file", type: :string
  opt :days, "Keep tweets/likes/messages under this many days old", default: 28
  opt :olds, "Keep tweets/likes/messages more than this many days old", default: 9999
  opt :rts, "Keep tweet with this many retweets", default: 5
  opt :favs, "Keep tweets with this many likes", default: 5
end

Trollop.die :user, "must be set" if @options[:user].to_s.empty?
if @options[:csv_given] && !File.exist?(@options[:csv])
  Trollop.die :csv, "must be a file that exists"
end

%w[TWITTER_CONSUMER_KEY TWITTER_CONSUMER_SECRET
   TWITTER_ACCESS_TOKEN TWITTER_ACCESS_TOKEN_SECRET].each do |env|
  Trollop.die "#{env} environment variable must be set" unless ENV[env]
end

@client = Twitter::REST::Client.new do |config|
  config.consumer_key = ENV["TWITTER_CONSUMER_KEY"]
  config.consumer_secret = ENV["TWITTER_CONSUMER_SECRET"]
  config.access_token = ENV["TWITTER_ACCESS_TOKEN"]
  config.access_token_secret = ENV["TWITTER_ACCESS_TOKEN_SECRET"]
end

@oldest_tweet_time_to_keep = Time.now - @options[:days] * 24 * 60 * 60
@newest_tweet_time_to_keep = Time.now - @options[:olds] * 24 * 60 * 60

def too_new?(tweet)
  tweet.created_at > @oldest_tweet_time_to_keep || tweet.created_at < @newest_tweet_time_to_keep
end

def too_new_or_popular?(tweet_or_message)
  return true if too_new? tweet_or_message
  return false unless tweet_or_message.is_a?(Twitter::Tweet)

  tweet = tweet_or_message
  return false if tweet.retweeted?
  return false if tweet.text.start_with? "RT @"

  if tweet.retweet_count >= @options[:rts]
    puts "Ignoring tweet: too RTd: #{tweet.text}"
    return true
  end

  if tweet.favorite_count >= @options[:favs]
    puts "Ignoring tweet: too liked: #{tweet.text}"
    return true
  end

  false
end

def api_call(method, *args)
  @client.send method, *args
rescue Twitter::Error::TooManyRequests => error
  puts "Rate limit exceeded; waiting until #{error.rate_limit.reset_at}"
  sleep error.rate_limit.reset_in
  retry
end

user = api_call :user, @options[:username]
tweets_to_unlike = []
tweets_to_delete = []
messages_to_delete = []

puts "==> Checking likes..."
total_likes = [user.favorites_count, MAX_API_TWEETS_MESSAGES].min
oldest_likes_page = (total_likes / MAX_LIKES_PER_PAGE).ceil

oldest_likes_page.downto(1) do |page|
  tweets = api_call :favorites, count: MAX_LIKES_PER_PAGE, page: page
  tweets_to_unlike += tweets.reject(&method(:too_new?))
end

puts "==> Checking timeline..."
total_tweets = [user.statuses_count, MAX_API_TWEETS_MESSAGES].min
oldest_tweets_page = (total_tweets / MAX_TWEETS_MESSAGES_PER_PAGE).ceil

oldest_tweets_page.downto(1) do |page|
  tweets = api_call :user_timeline, count: MAX_TWEETS_MESSAGES_PER_PAGE, page: page
  tweets_to_delete += tweets.reject(&method(:too_new_or_popular?))
end

puts "Checking messages..."
oldest_messages_page = (MAX_API_TWEETS_MESSAGES / MAX_TWEETS_MESSAGES_PER_PAGE).ceil
oldest_messages_page.downto(1) do |page|
  messages = api_call :direct_messages, count: MAX_TWEETS_MESSAGES_PER_PAGE, page: page
  messages_to_delete += messages.reject(&method(:too_new_or_popular?))
end

if @options[:csv_given]
  puts "==> Checking archive CSV..."
  csv_tweet_ids = []
  CSV.foreach(@options[:csv]) do |row|
    tweet_id = row.first
    next if tweet_id == "tweet_id"
    csv_tweet_ids << tweet_id
  end

  csv_tweet_ids.each_slice(MAX_TWEETS_MESSAGES_PER_REQUEST) do |tweet_ids|
    tweets = api_call :statuses, tweet_ids
    tweets_to_delete += tweets.reject(&method(:too_new_or_popular?))
  end
end

unless @options[:force]
  puts "==> To unlike #{tweets_to_unlike.size} and delete #{tweets_to_delete.size} tweets, re-run the command with --force"
  exit 0
end

puts "==> Unliking #{tweets_to_unlike.size} tweets"
tweets_not_found = []
tweets_to_unlike.each_slice(MAX_TWEETS_MESSAGES_PER_REQUEST) do |tweets|
  begin
    api_call :unfavorite, tweets
  rescue Twitter::Error::NotFound
    tweets_not_found += tweets
  end
end

puts "==> Deleting #{tweets_to_delete.size} tweets"
tweets_to_delete.each_slice(MAX_TWEETS_MESSAGES_PER_REQUEST) do |tweets|
  begin
    api_call :destroy_status, tweets
  rescue Twitter::Error::NotFound
    tweets_not_found += tweets
  end
end

tweets_not_found.each do |tweet|
  begin
    api_call :destroy_status, tweet
  rescue Twitter::Error::NotFound
    nil
  end
end

puts "==> Deleting #{messages_to_delete.size} messages"
messages_not_found = []
messages_to_delete.each_slice(MAX_TWEETS_MESSAGES_PER_REQUEST) do |messages|
  begin
    api_call :destroy_direct_message, messages
  rescue Twitter::Error::NotFound
    messages_not_found += messages
  end
end

messages_not_found.each do |message|
  begin
    api_call :destroy_direct_message, message
  rescue Twitter::Error::NotFound
    nil
  end
end
