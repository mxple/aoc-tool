module Commands
  def self.create(year, day, lang)
    # $MASTER_DIR.nil? && !in_year_dir && error('`create` may only be used in a year directory or if $MASTER_DIR is defined')
    error('Unable to init for unknown day!') if year && day.nil?
    year = default_year if year.nil?
    day  = Time.now.getlocal('-05:00').day if day.nil?

    lang = $DEFAULT_LANG if lang.nil?
    lang_code = Language.get_lang(lang)

    lang_code.nil? && error("Unsupported language: #{lang.bold!}")

    ext = Language.get_ext(lang_code)

    puzzle_file_dir  = build_puzzle_dir(year, day)
    puzzle_file_path = build_puzzle_file(year, day)

    input_file_dir  = build_input_dir(year, day)
    input_file_path = build_input_file(year, day)

    create_puzzle = Thread.new do
      puzzle = parse_html_to_md get_puzzle(day, year)
      
      # create puzzle file
      FileUtils.mkdir_p(puzzle_file_dir)
      f = File.new(puzzle_file_path, 'w')
      f.write(puzzle)
      f.flush
      f.close

      info "Puzzle written to #{puzzle_file_path}"
    end

    create_input = Thread.new do
      input = get_input(day, year)

      # create input file
      FileUtils.mkdir_p(input_file_dir)
      f = File.new(input_file_path, 'w')
      f.write(input)
      f.close

      info "Input written to #{input_file_path}"
    end

    create_puzzle.join()
    create_input.join()

    Metadata.set_last_puzzle(year, day)

    # create solution file
    solution_path = build_solution_dir(year, day)
    p1 = build_solution_file(year, day, 1, ext)
    p2 = build_solution_file(year, day, 2, ext)

    FileUtils.mkdir_p(solution_path)

    template = get_template(ext, year, day, solution_path)
    t1 = template.gsub('%%PART%%', '1')
    t2 = template.gsub('%%PART%%', '2')

    # make solution files if they do not already exist
    unless File.exist?(p1)
      f = File.open(p1, 'w')
      f.write(t1)
      f.close
    end
    unless File.exist?(p2)
      f = File.open(p2, 'w')
      f.write(t2)
      f.close
    end

    info "Solution files created in #{solution_path}/"

    return if $IDE.nil?

    # TODO: figure out how to do properly
    ide_cmd = $IDE.dup
    ide_cmd.gsub!('%%PUZZLE%%', puzzle_file_path)
    ide_cmd.gsub!('%%INPUT%%', input_file_path)
    # ide_cmd.gsub!('%%TESTS%%', )
    ide_cmd.gsub!('%%P1%%', p1)
    ide_cmd.gsub!('%%P2%%', p2)
    ide_cmd.gsub!('%%PART1%%', p1)
    ide_cmd.gsub!('%%PART2%%', p2)

    IO.name
    system(ide_cmd)
  end

  module_function
  def get_template(ext, year, day, solution_path)
    template_path = File.join($CONFIG_DIR, 'templates', "template.#{ext}")
    return '' unless File.exist?(template_path) 

    template = File.read(template_path)
    template.gsub!('%%YEAR%%', year.to_s)
    template.gsub!('%%DAY%%', day.to_s)
    template.gsub!('%%PWD%%', solution_path)
    template.gsub!('%%TIME(anything here)%%', Time.now.strftime('anything here'))
    template.gsub!(/%%TIME\((.*?)\)%%/) { Time.now.strftime(::Regexp.last_match(1)) }
    template
  end

  def get_input(day, year)
    !day_unlocked(day, year) && abort("Day #{day} is not unlocked.")

    url = URI.parse("https://adventofcode.com/#{year}/day/#{day}/input")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == 'https')
    request = Net::HTTP::Get.new(url.request_uri)
    request['Cookie'] = "session=#{cookie}"

    info "Fetching input for #{'Day'.bright_green!} #{day.to_s.red!} #{year.to_s.bright_white!}..."
    response = http.request(request)

    return response.body if response.code == '200'

    error "Server returned with code #{response.code}\n#{response.body} \
\n#{'Could not download input! Make sure the session cookie is correct.'.bold!}"
  end

  def get_puzzle(day, year)
    !day_unlocked(day, year) && abort("Day #{day} is not unlocked.")

    url = URI.parse("https://adventofcode.com/#{year}/day/#{day}")
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

  def parse_html_to_md(html)
    result = ''
    parts = html.extract_main.extract_articles
    parts.each do |part|
      part[0]
        .replace_paragraph_md!
        .replace_header_md!
        .replace_links_md!
        .replace_block_md!
        .replace_code_md!
        .replace_glow_md!
        .replace_star_md!
        .replace_list_md!
        .remove_easter_eggs!

      result += part[0]
      result += "\n"
    end
    result
  end
end
