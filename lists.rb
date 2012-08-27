require 'twitter'
require 'fileutils'
# require 'pp'

Twitter.configure do |config|
  config.consumer_key = "your consumer key";
  config.consumer_secret = "your consumer secret";
  config.oauth_token = "your oauth token";
  config.oauth_token_secret = "your oauth token secret";
end

# pp Twitter.rate_limit_status

date = Time.now.strftime "%Y%m%d"
FileUtils.mkdir_p("lists/#{date}") unless FileTest.exist?("lists/#{date}")

response = Twitter.get("/1/lists/all.json")
if response[:body] && response[:body].length != 0
  response[:body].each do |list|
    name = list[:name]
    File.open("lists/#{date}/#{date}_#{name}.json", 'w') { |f|
      f.puts "{"
      f.puts "  id: #{list[:id_str]},"
      f.puts "  name: \"#{name}\","
      list_description = Regexp.escape(list[:description])
      f.puts "  description: \"#{list_description}\","
      f.puts "  users: ["

      next_cursor = -1
      until next_cursor == 0 do
        members = Twitter.get("/1/lists/members.json", {:list_id => list[:id], :cursor => next_cursor})
        next_cursor = members[:body][:next_cursor]
        members[:body][:users].each do |member|
          f.puts "    {"
          f.puts "      id: #{member[:id_str]},"
          f.puts "      name: \"#{member[:name]}\","
          f.puts "      screen_name: \"#{member[:screen_name]}\","
          user_description = Regexp.escape(member[:description])
          f.puts "      description: \"#{user_description}\""
          f.puts "    },"
        end
      end

      f.puts "  ]"
      f.puts "}"
    }
  end
end
