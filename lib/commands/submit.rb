require 'net/http'
require 'uri'

module Commands 
  def self.submit(year, day, ans)
    error('Cannot specify year without specifying day.') if year && day.nil?

    if year.nil? && day.nil?
      year, day = Metadata.last_run
      error("No previous run found.") if year.nil? || day.nil?
    end

    info 'Preparing to submit. This may take a few seconds.'

    year = default_year if year.nil?
    part = get_part(year, day)
    ans = Metadata.get_cached_results(part) if ans.nil?

    return unless confirm_submit?(year, day, part, ans)

    url = URI.parse("https://adventofcode.com/#{year}/day/#{day}/answer")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Post.new(url.path)
    request['Cookie'] = "session=#{cookie}"
    request.set_form_data('level' => part.to_s, 'answer' => ans.to_s)

    response = http.request(request)

    if response.code != '200'
      error "POST request failed with code: #{response.code}"
    end

    html_response = response.body

    puts html_response.extract_main.extract_articles[0][0].replace_paragraph_md!.replace_links!.replace_stars!
  end

  module_function

  def confirm_submit?(year, day, part, ans)
    msg = "#{'[AOC-INFO]'.bright_white!} Submit #{ans.to_s.bold!.bright_white!} for #{"Day #{day}, Part #{part} (#{year})".underline!}? (Y/n) "
    while true
      print msg
      input = STDIN.gets.chomp.downcase
      return true if input == 'y' || input == ''
      return false if input == 'n'
    end
  end

  def get_part(year, day)
    # Get the current part
    url = URI.parse("https://adventofcode.com/#{year}/day/#{day}")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true

    request = Net::HTTP::Get.new(url.request_uri)
    request['Cookie'] = "session=#{cookie}"
    response = http.request(request)

    error("Unable to fetch data. ") if response.code != '200'

    if response.body.include?('To play, please identify yourself via one of these services:')
      error("Session cookie is invalid. Set cookie in config or use AOC_SESSION environment variable") 
    end

    response.body.include?('<article class="day-desc"><h2 id="part2">--- Part Two ---</h2><p>') ? 2 : 1
  end
end
