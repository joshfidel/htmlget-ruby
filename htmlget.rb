#!/usr/bin/env ruby
require "net/http"
require 'redis'

@redis = Redis.new

puts "enter site name ('example.com'): "
@sitename = gets.chomp

puts "enter a filename: "
fname = gets.chomp

@count = 0

while true
	dirname = File.basename(Dir.getwd)
	@outfile = File.new("/home/ubuntu/htmlget/logs/"+fname, "a+")
	f = @outfile.read
	t = Time.now
	t.to_a
	t = t.strftime "%Y-%m-%d %H:%M:%S"
	uri = URI.parse("http://"+@sitename)

	http = Net::HTTP.new(uri.host, uri.port)
	request = Net::HTTP::Get.new(uri.request_uri)

	response = http.request(request)

	if response.code == "200"
		@outfile.puts(t + " : Site is up [received 200 response code]")
		puts t + " : Site is up [received 200 response code]"
	else
		@outfile.puts(t + " : WARNING - Received other than 200 response")
		puts t + " : WARNING - Received other than 200 response"
	end
	@count += 1
	if @count >= 5
		f.each_line {|x| @redis.rpush(@sitename, x.chop) }
		File.truncate("/home/ubuntu/htmlget/logs/"+fname, 0)
		@count = 0
	end
	@outfile.close
	sleep 120
end
