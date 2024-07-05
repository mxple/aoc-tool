require 'net/http'
require 'uri'

require_relative 'constants'

module AocClient
  def self.get_input(day, year)
    !day_unlocked(day, year) && abort("Day #{day} is not unlocked.")

    url = URI.parse("https://adventofcode.com/#{year}/day/#{day}/input")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    request = Net::HTTP::Get.new(url.request_uri)
    request['Cookie'] = "session=#{cookie}"

    puts "Fetching input for day #{day}, #{year}..."
    response = http.request(request)

    return response.body if response.code == '200'

    abort("Server returned with code #{response.code}\n#{response.body} \
\nCould not download input! Make sure the session cookie is correct.")
  end

  module_function

  def day_unlocked(day, year)
    time = Time.new(year, 12, day, 0, 0, 0, '-05:00')
    est= Time.now.getlocal('-05:00')
    est > time
  end

  def cookie()
    return $SESSION unless $SESSION.nil?
    ENV['AOC_COOKIE']
  end
end
