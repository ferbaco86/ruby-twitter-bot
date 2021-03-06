require 'dotenv/load'
require 'twitter'
require_relative 'robo_handler.rb'
require 'time'

class TwitterHandler
  include RoboHandler

  def initialize(user, hash, d100format)
    @user = user
    @tweet_hash = hash
    @d100format = d100format
    @client = twitter_dev_init
    @last_tweet = []
    @d100_record = [[]]
  end

  # rubocop:disable Layout/LineLength
  def last_hash_tweet?
    @client.search("from:#{@user} #{@tweet_hash} -filter:retweets", result_type: 'recent', tweet_mode: 'extended').take(1).each_with_index do |tweet, index|
      # Checks that the tweet is not a RT and has the D100 format.
      if tweet.full_text.match(@d100format)
        @d100_record[index] = tweet.created_at.to_s
        @d100_record << (tweet.full_text.match(@d100format).to_a << tweet.full_text)
      end
    end
    [@d100_record[-1].nil? ? nil : @d100_record[-1][1], @d100_record[-1][2], @d100_record[-1][3], @d100_record[0]]
  end
  # rubocop:enable Layout/LineLength

  def send_100dc_tweet(raw_text)
    # this method should send a prevalidated message with the required format
    return false if raw_text.nil?

    @client.update(raw_text) ? true : false
  end

  private

  def twitter_dev_init
    Twitter::REST::Client.new do |config|
      config.consumer_key = ENV['CONFIG_CONSUMER_KEY']
      config.consumer_secret = ENV['CONFIG_CONSUMER_SECRET']
      config.access_token = ENV['CONFIG_ACCESS_TOKEN']
      config.access_token_secret = ENV['CONFIG_ACCESS_TOCKEN_SECRET']
    end
  end
end
