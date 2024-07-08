require 'benchmark'

module Commands 
  def self.run(year, day, part)
    $MASTER_DIR.nil? && !in_year_dir && error('`run` may only be used in an year directory or if $MASTER_DIR is defined')
    year && day.nil? && error('Cannot figure out which day to run.') # todo, change this

    year, day = Metadata.last_puzzle if year.nil? && day.nil?
    year = default_year if year.nil?
    part = parse_part(part)

    error('Cannot figure out which day to run.') if day.nil?

    outputs = []
    times   = []
    part.each do |pt| outputs[pt - 1], times[pt - 1] = run_part(year, day, pt); end

    present_run(year, day, outputs[0], outputs[1], times[0], times[1])
  end

  module_function

  def run_part(year, day, pt) 
    solution_dir = build_solution_dir(year, day)
    solution_file = File.join(solution_dir, Dir.entries(solution_dir).select do |f|
                                              Language::EXTENSION_MAP.any? do |suf|
                                                f.end_with?(suf)
                                              end
                                            end.find { |f| f.split('.')[-2].chars.last.to_i == pt })
    !File.exist?(solution_file) && error("Solution file: '#{solution_file}' does not exist.")

    # get input
    input_file = build_input_file(year, day)
    !File.exist?(input_file) && error("Input file: '#{input_file}' does not exist.")

    ext = solution_file.split('.').last
    lang = Language.get_lang(ext)
    error("Unrecognized extension on: #{solution_file}") if lang.nil?

    binary_dir = build_binary_dir(year, pt)

    # compile
    if Language.is_compiled?(lang) 
      compile_success = compile(lang, binary_dir, solution_file)
      return ['COMPILE_ERROR'.red!, 0] unless compile_success
    end

    # feed input
    aoc_input = File.read(input_file)
    ENV['AOC_INPUT'] = aoc_input if $USE_ENV_INPUT

    run_file = Language.is_compiled?(lang) ? Dir.glob(File.join(binary_dir, '*')).first : solution_file
    run_cmd = "#{Language.get_run_cmd(lang)} #{run_file} #{$USE_STDIN_INPUT ? "< #{input_file}" : ''}"

    debug "Running solution with: #{run_cmd}"

    output = nil
    exec_time = Benchmark.realtime do output = `#{run_cmd}`; end

    unless $?.success?
      warn "Error code detected!\n#{output}"
      output = "RUNTIME_ERROR".red!
    end

    return [output, exec_time]
  end

  def compile(lang, binary_dir, solution_file)
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

    info "Compiling #{File.basename(solution_file).bold!}..."
    debug "Compiling with: #{compile_command}"

    output = `#{compile_command}`

    if $?.success? 
      info 'Compilation successful!'.green!
      return true
    else
      warn "#{'Compilation failed!'.red!}\n#{output}"
      return false
    end
  end


  def present_run(year, day, out1, out2, time1, time2)
    truncated = false
    [out1, out2].each_with_index do |out, index| 
      next if out.nil?

      out = out.split("\n")
      
      truncated = true if out.size > 1
      out = out.empty? ? '' : out.last 
      truncated = true if out.visible_length > 67
      out = "#{out[0, 64]}#{'...'.red!}" if out.visible_length > 67

      if index == 0 
        out1 = out
        Metadata.cache_results(year, day, out1, nil) unless truncated
      else 
        out2 = out
        Metadata.cache_results(year, day, nil, out2) unless truncated
      end
    end

    table_left = '+--------+'
    table_center = '-' * [(out1 ? out1.visible_length : 0) + 4, (out2 ? out2.visible_length : 0) + 4, 10].max
    table_right = '+-------------+'
    seperator_row = table_left + table_center + table_right

    warn 'Your output has been truncated. Run with `aoc run-raw` to get raw stdout without the pretty formatting.' if truncated

    puts '-' * seperator_row.length
    info "Run results for Year #{year}, Day #{day}" 
    puts ''

    puts seperator_row
    puts "|  Part  |  Result  #{' ' * (table_center.length - 10)}|  Exec time  |"
    puts seperator_row

    [[out1, time1, 1], [out2, time2, 2]].each do |out, time, pt|
      next if out.nil?

      exec_time = "#{(time * 1000).round(2)} ms"
      print "|  #{pt.to_s}     |"
      print "  #{out}#{' ' * (table_center.length - out.visible_length - 2)}"
      puts "|  #{exec_time}#{' ' * (table_right.length - exec_time.length - 4)}|"
      puts seperator_row
    end
  end
end
