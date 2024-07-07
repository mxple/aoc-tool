require 'net/http'
require 'uri'

require_relative 'common'
require_relative 'constants'

module AocClient
  def self.get_input(day, year)
    !day_unlocked(day, year) && abort("Day #{day} is not unlocked.")

    url = URI.parse("https://adventofcode.com/#{year}/day/#{day}/input")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    request = Net::HTTP::Get.new(url.request_uri)
    request['Cookie'] = "session=#{cookie}"

    info "Fetching puzzle for #{'Day'.bright_green!} #{day.to_s.red!} #{year.to_s.bright_white!}..."
    response = http.request(request)

    return response.body if response.code == '200'

    error "Server returned with code #{response.code}\n#{response.body} \
\n#{'Could not download input! Make sure the session cookie is correct.'.bold!}"
  end

  module_function

  def day_unlocked(day, year)
    time = Time.new(year, 12, day, 0, 0, 0, '-05:00')
    est= Time.now.getlocal('-05:00')
    est > time
  end

end
