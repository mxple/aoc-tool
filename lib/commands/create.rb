module Commands
  def self.init(year, day, lang)
    # $MASTER_DIR.nil? && !in_year_dir && error('`create` may only be used in a year directory or if $MASTER_DIR is defined')
    # none      -> year = aoc_year, day = today (est)
    # just year -> abort, no info to go off of
    # just day  -> year = aoc_year, day = day
    # both      -> do nothing
    error('Unable to init for unknown day!') if year && day.nil?
    year = default_year if year.nil?
    day  = Time.now.getlocal('-05:00').day if day.nil?

    lang = $DEFAULT_LANG if lang.nil?
    lang_code = Language.get_lang(lang)

    lang_code.nil? && error("Unsupported language: #{lang.bold!}")

    ext = Language.get_ext(lang_code)

    input_file_dir  = build_input_dir(year, day)
    input_file_path = build_input_file(year, day)

    # http GET
    input = AocClient.get_input(day, year)

    # create input file
    FileUtils.mkdir_p(input_file_dir)
    File.open(input_file_path, 'w').write(input)

    info "Input written to #{input_file_path}"

    # create solution file
    solution_path = build_solution_dir(year, day)
    FileUtils.mkdir_p(solution_path)

    # fun template stuff
    template_path = File.join($CONFIG_DIR, 'templates', "template.#{ext}")
    template = File.exist?(template_path) ? File.read(template_path) : ''

    template.gsub!('%%YEAR%%', year.to_s)
    template.gsub!('%%DAY%%', day.to_s)
    template.gsub!('%%PWD%%', solution_path)
    template.gsub!('%%TIME(anything here)%%', Time.now.strftime('anything here'))
    template.gsub!(/%%TIME\((.*?)\)%%/) { Time.now.strftime(::Regexp.last_match(1)) }

    t1 = template.gsub('%%PART%%', '1')
    t2 = template.gsub('%%PART%%', '2')

    p1 = build_solution_file(year, day, 1, ext)
    p2 = build_solution_file(year, day, 2, ext)

    # make solution files if they do not already exist
    File.open(p1, 'w') { |f| f.write(t1) } unless File.exist?(p1)
    File.open(p2, 'w') { |f| f.write(t2) } unless File.exist?(p2)

    info "Solution files created in #{solution_path}"

    return if $IDE.nil?

    # TODO: figure out how to do properly
    Process.wait(spawn("#{$IDE} #{p1} #{p2}"))
  end
end
