#!/usr/bin/env ruby

# Made By TheZero (2014)

# Dependences
# gem install twitter
# gem install openwferu-scheduler
# gem install rufus-scheduler --source http://gemcutter.org

require 'net/http'
require 'json'
require 'twitter'
require 'rubygems'
require 'rufus/scheduler'
require 'bigdecimal'
scheduler = Rufus::Scheduler.new

class TwitterBot
	@client = nil
	
	def initialize(consumer_key="",consumer_secret="",access_token="", access_token_secret="")
		# Twitter login
		@client = Twitter::REST::Client.new do |config|
			config.consumer_key        = consumer_key
			config.consumer_secret     = consumer_secret
			config.access_token        = access_token
			config.access_token_secret = access_token_secret
		end
	end
	def tweet(text)
		begin
			@client.update(text)
			puts "Tweet Sent! " + Time.now.to_s
			puts text
		rescue Twitter::Error => e
			puts "#{e.message}."
		end 
	end
end


class Bitcoin
	def query(path)
		begin
			uri = URI.parse("https://btc-e.com/api/"+path)
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			request = Net::HTTP::Get.new(uri.request_uri)
			response = http.request(request)
			data = JSON.parse(response.body)
			
			usd = data["ticker"]["last"]
			return usd.to_s
		rescue Exception
		  return nil
		end
	end
end

class Zetacoin
	def query_bter(btc)
		begin
			uri = URI.parse("https://data.bter.com/api/1/ticker/zet_btc")
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			request = Net::HTTP::Get.new(uri.request_uri)
			response = http.request(request)
			data = JSON.parse(response.body)
			
			usd = data["last"]
			zet=btc.to_f.round(8)*usd.to_f.round(8)
			return usd.to_s+" BTC = "+zet.round(4).to_s+" USD"
		rescue Exception
		  return nil
		end
	end
  
  def query_cryptsy(btc)
		begin
			req = Net::HTTP.get_response(URI.parse("http://pubapi.cryptsy.com/api.php?method=singlemarketdata&marketid=85"))
			data = JSON.parse(req.body)
			
			usd = data["return"]["markets"]["ZET"]["lasttradeprice"]
			zet=btc.to_f.round(8)*usd.to_f.round(8)
			return usd.to_s+" BTC = "+zet.round(4).to_s+" USD"
		rescue Exception
		  return nil
		end
	end
  
  def query_mintpal(btc)
		begin
			uri = URI.parse("https://api.mintpal.com/v1/market/stats/ZET/BTC")
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = true
			http.verify_mode = OpenSSL::SSL::VERIFY_NONE
			request = Net::HTTP::Get.new(uri.request_uri)
			response = http.request(request)
			data = JSON.parse(response.body)
			
			usd = 0

			data.each {|x| 
				if x["code"] == "ZET"then
					usd = x["last_price"]
				end
			}

			zet=btc.to_f.round(8)*usd.to_f.round(8)
			return usd.to_s+" BTC = "+zet.round(4).to_s+" USD"
		rescue Exception
		  return nil
		end
	end
end

def tweet_price(t,b,z) 
	price_usd = b.query("2/btc_usd/ticker")
	price_eur = b.query("2/btc_eur/ticker")
	t.tweet("1 BTC = "+price_usd+" USD = "+price_eur+" EUR")
		
	price_bter = z.query_bter(price_usd)
	price_cryptsy = z.query_cryptsy(price_usd)
	price_mintpal = z.query_mintpal(price_usd)
	mtweet = ""
	if price_bter != nil then
		mtweet = mtweet + "1 ZET = "+price_bter+" #bter\n"
	end
	if price_cryptsy != nil then
		mtweet = mtweet + "1 ZET = "+price_cryptsy+" #cryptsy\n"
	end
	if price_mintpal != nil then
		mtweet = mtweet + "1 ZET = "+price_mintpal+" #mintpal"
	end

	t.tweet(mtweet)
end
  
  
tbot = TwitterBot.new("consumer_key",
	"consumer_secret",
	"access_token", 
	"access_token_secret")
btc = Bitcoin.new
zet = Zetacoin.new
  
tweet_price(tbot,btc,zet)


scheduler.every '1h' do
  tweet_price(tbot,btc,zet)
end

scheduler.every '100h' do
	tbot.tweet("Donate BTC: 1GV4ckHwhsqn9UAwgM8qFYArA8njCqZ21y"+"\n"+"Donate ZET: ZTZzLDehWqC3vm36kSXrvhqtgAecBdCrVZ")
end

scheduler.join
