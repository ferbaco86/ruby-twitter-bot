require 'twitter'
require_relative "../secret/key.rb"
require 'time'

class TwitterHandler
    include EnviVars

    def initialize(user,hash,d100format)
        @user = user
        @tweet_hash = hash
        @d100format = d100format
        @client = twitter_dev_init
        @last_tweet = []
        @d100_tweet
        @rt_regexp = /^RT @/
        @d100_record = [[]]
    end

    def last_hash_tweet?
      @client.search("from:#{USER} #{TWEET_HASH}", result_type: "recent", tweet_mode: "extended").take(2).each_with_index do |tweet,index|
        # Checks that the tweet is not a RT and has the D100 format.
        if !tweet.full_text.match(@rt_regexp) && tweet.full_text.match(D100_FORMAT)
            @d100_record[index] = tweet.created_at.to_s
            @d100_record << (tweet.full_text.match(D100_FORMAT).to_a << tweet.full_text)
        end
      end
      return @d100_record[-1].nil? ? nil: @d100_record[-1][1],@d100_record[-1][2],@d100_record[-1][3],@d100_record[0]

    end

    def send_100DC_tweet(raw_text)
        #this method should send a prevalidated message with the required format
        return @client.update(raw_text)
    end

    private
    def twitter_dev_init
        return Twitter::REST::Client.new do |config|
            config.consumer_key        = CONFIG_CONSUMER_KEY
            config.consumer_secret     = CONFIG_CONSUMER_SECRET
            config.access_token        = CONFIG_ACCESS_TOKEN
            config.access_token_secret = CONFIG_ACCESS_TOCKEN_SECRET
          end
    end


end
