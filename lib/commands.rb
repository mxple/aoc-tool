require 'benchmark'
require 'fileutils'

require_relative 'constants'
require_relative 'common'
require_relative 'client'

module Commands
  def self.run(year, day, part)
    $MASTER_DIR.nil? && !in_year_dir && abort('`run` may only be used in an year directory or if $MASTER_DIR is defined')
    year && day.nil? && abort('Unable to run for unknown day!')

    # time may be invalid
    year = default_year if year.nil?
    day  = Time.now.getlocal('-05:00').day if day.nil?
    part = parse_part(part)

    outputs = ['', '']
    times   = [0, 0]
    part.each do |pt|
      # todo: add support for choosing language
      solution_dir = build_solution_dir(year, day)
      solution_file = File.join(solution_dir, Dir.entries(solution_dir).select do |f|
                                                Language::EXTENSION_MAP.any? do |suf|
                                                  f.end_with?(suf)
                                                end
                                              end.find { |f| f.split('.')[-2].chars.last.to_i == pt })
      !File.exist?(solution_file) && abort("Solution file: '#{solution_file}' does not exist.")

      # get input
      input_file = build_input_file(year, day)
      !File.exist?(input_file) && abort("Input file: '#{input_file}' does not exist.")

      ext = solution_file.split('.').last
      lang = Language.get_lang(ext)
      abort("Unrecognized extension: #{solution_file}") if lang.nil?

      # compile if needed
      binary_dir = build_binary_dir(year, pt)
      if Language.get_compiler(lang)
        FileUtils.mkdir_p(binary_dir)

        # remove old binaries
        Dir.entries(binary_dir).each do |file|
          FileUtils.rm(file) if File.file?(file)
        end

        compile_command = Language.get_compiler(lang).dup
        compile_command.gsub!('%%BIN_DIR%%', binary_dir)
        compile_command.gsub!('%%SRC_FILE%%', solution_file)

        lib_files = ''
        $LIB_FILES.each do |file| 
          lib_files += " #{file}"
        end

        compile_command.gsub!('%%LIB_FILES%%', lib_files)

        puts "Compiling with: #{compile_command}"

        output = `#{compile_command}`

        unless $?.success? 
          outputs[pt - 1] = "COMPILE_ERROR".bright_red!.blink!
          next puts "Compile error running cmd: #{compile_command}\n#{output}" unless $?.success?
        end
      end

      # input is fed via env and via stdin
      aoc_input = File.read(input_file)
      ENV['AOC_INPUT'] = aoc_input if $USE_ENV_INPUT

      interpreter_command = Language.get_run_cmd(lang)
      run_file = ''
      if Language.get_compiler(lang)
        # search for binary
        puts Dir.glob(File.join(binary_dir, '*'))
        run_file = Dir.glob(File.join(binary_dir, '*')).first # find { |f| File.file?(f) }
      else
        run_file = solution_file
      end

      run_command = "#{interpreter_command} #{run_file} #{$USE_STDIN_INPUT ? '< ' + input_file : ''}"

      puts "[DEBUG] Running solution with: #{run_command}" if ENV['AOC_DEBUG']

      # TODO: do we want to cache output?
      times[pt - 1] = Benchmark.realtime do
        outputs[pt - 1] = `#{run_command}`
      end
      unless $?.success?
        puts "Error code detected:\n#{outputs[pt - 1]}"
        outputs[pt - 1] = "\e[31mERROR\e[0m"
      end
    end

    present_run(year, day, outputs[0], outputs[1], times[0], times[1])
  end

  def self.init(year, day, lang)
    $MASTER_DIR.nil? && !in_year_dir && abort('`init` may only be used in a year directory or if $MASTER_DIR is defined')
    # none      -> year = aoc_year, day = today (est)
    # just year -> abort, no info to go off of
    # just day  -> year = aoc_year, day = day
    # both      -> do nothing
    abort('Unable to init for unknown day!') if year && day.nil?
    year = default_year if year.nil?
    day  = Time.now.getlocal('-05:00').day if day.nil?

    lang = $DEFAULT_LANG if lang.nil?
    lang_code = Language.get_lang(lang)

    lang_code.nil? && abort("Unidentified language: #{lang}")

    ext = Language.get_ext(lang_code)

    input_file_dir  = build_input_dir(year, day)
    input_file_path = build_input_file(year, day)

    # http GET
    input = AocClient.get_input(day, year)

    # create input file
    FileUtils.mkdir_p(input_file_dir)
    File.open(input_file_path, 'w').write(input)

    puts "Input written to #{input_file_path}"

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

    puts "Solution files created in #{solution_path}"

    return if $IDE.nil?

    # TODO: figure out how to do properly
    Process.wait(spawn("#{$IDE} #{p1} #{p2}"))
  end

  def self.submit(_year, _day, _ans)
    abort('Submit not yet implemented!')
  end

  def self.create_year(year, day, name)
    abort('Specify a valid year! Usage: `create` <year> <dir_name') if year.nil?
    abort('Too many arguments! Usage: `create` <year> <dir_name>') if day && name
    abort('Too few arguments! Usage: `create` <year> <dir_name>') if day.nil? && name.nil?
    name = day if name.nil?

    # create directory
    base = $MASTER_DIR || './'
    year_dir = File.join(base, name)

    begin
      Dir.mkdir(year_dir)
    rescue Errno::EEXIST => e
      abort "Year directory at '#{year_dir}' already exists!"
    end

    # create .aoc file in year directory
    File.open(File.join(year_dir, '.aoc_year'), 'w').write(year.to_s)

    # update master dir .aoc file
    $MASTER_DIR && File.open(File.join($MASTER_DIR, '.aoc'), 'a').write("\n#{year}:#{name}")
  end

  def self.master_init(year, day, name)
    abort('`aoc master-init` takes no arguments!') if year || day || name
    abort('$MASTER_DIR is nil! Make sure to define it in your config!') if $MASTER_DIR.nil?
    Dir.exist?($MASTER_DIR) && File.exist?(File.join($MASTER_DIR,
                                                     '.aoc')) && abort('Master directory already initialized!')

    FileUtils.mkdir_p($MASTER_DIR)
    File.open(File.join($MASTER_DIR, '.aoc'), 'w').write($TAMPER_WARNING)
  end

  def self.info_dump
    puts 'wip feature ^^'
  end

  module_function

  # if year directories are renamed or if master/.aoc was tampered with
  # this function fixes it based on the .aoc files in its chilren dirs
  def reinit_master; end

  def present_run(year, day, out1, out2, time1, time2)
    out1 = out1.split("\n") unless out1.nil?
    out2 = out2.split("\n") unless out2.nil?

    longest_line = [out1.map(&:length).max]

    table_left = '+--------+'
    table_center = '-' * [(out1 ? out1.map(&:visible_length).max : 0) + 4, (out2 ? out2.map(&:visible_length).max : 0) + 4, 10].max
    table_right = '+-------------+'

    seperator_row = table_left + table_center + table_right

    puts '-' * seperator_row.length
    puts "Run results for year #{year}, day #{day}" 
    puts ''

    puts seperator_row
    puts "|  Part  |  Result  #{' ' * (table_center.length - 10)}|  Exec time  |"
    puts seperator_row

    [[out1, time1, 1], [out2, time2, 2]].each do |out, time, pt|
      next if out.nil?

      exec_time = "#{(time * 1000).round(2)} ms"
      out.each_with_index do |line, i|
        print_info = i == (out.length + 1) / 2 - 1  # print info on middle line
        print "|  #{print_info ? pt.to_s : ' '}     |"
        print "  #{line}#{' ' * (table_center.length - line.visible_length - 2)}"
        puts "|  #{print_info ? exec_time : ' ' * exec_time.length}#{' ' * (table_right.length - exec_time.length - 4)}|"
      end
      puts seperator_row
    end
  end
end
