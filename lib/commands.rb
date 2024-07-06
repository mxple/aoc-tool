require 'benchmark'
require 'fileutils'

require_relative 'constants'
require_relative 'common'
require_relative 'client'

module Commands
  def self.run(year, day, part)
    abort('`run` may only be used in an year directory or if MASTER_DIR is defined') if $MASTER_DIR.nil? && !in_year_dir
    abort('Unable to run for unknown day!') if year && day.nil?
    # time may be invalid
    year = default_year if year.nil?
    day  = Time.now.getlocal('-05:00').day if day.nil?
    part = parse_part(part)

    part.each do |pt|
      solution_dir = build_solution_dir(year, day)
      solution_file = File.join(solution_dir, Dir.entries(solution_dir).select do |f|
                                                $LANG_MAP.keys.any? do |suf|
                                                  f.end_with?(suf)
                                                end
                                              end.find { |f| f.split('.')[-2].chars.last.to_i == pt })
      !File.exist?(solution_file) && abort("Solution file: '#{solution_file}' does not exist.")

      # get input
      input_file = build_input_file(year, day)
      !File.exist?(input_file) && abort("Input file: '#{input_file}' does not exist.")

      ext = solution_file.split('.').last
      ext = $LANG_MAP[ext]
      abort("Unrecognized file/extension: #{solution_file}") if ext.nil?

      # compile if needed
      binary_dir = build_binary_dir(year, day, pt)
      unless $COMPILER_MAP[ext].nil?
        FileUtils.mkdir_p(binary_dir)

        compile_command = $COMPILER_MAP[ext].dup
        compile_command.gsub!('%%BIN_DIR%%', binary_dir)
        compile_command.gsub!('%%PART%%', pt.to_s)

        compile_command += " #{solution_file}"
        # TODO: add lib files

        puts "Compiling with: #{compile_command}"
        output = `#{compile_command}`
        puts "Compile error running cmd: #{compile_command}\n#{output}" unless $?.success?
      end

      # input is fed via env and via stdin
      aoc_input = File.read(input_file)
      ENV['AOC_INPUT'] = aoc_input if $USE_ENV_INPUT

      interpreter_command = $INTERPRETER_MAP[ext].dup + ' '
      run_file = $RUN_FILE_MAP[ext].dup || solution_file
      run_file.gsub!('%%SOLUTION_FILE_NAME%%', solution_name(pt))
      run_file.gsub!('%%BIN_DIR%%', binary_dir)
      run_file.gsub!('%%PART%%', pt.to_s)

      run_command = "#{interpreter_command}#{run_file}#{$USE_STDIN_INPUT ? ' < ' + input_file : ''}"

      puts "[DEBUG] Running solution with: #{run_command}" if ENV['AOC_DEBUG']

      # TODO: do we want to cache output?
      output = ''
      time = Benchmark.realtime do
        output = `#{run_command}`
      end

      puts "Year #{year}, Day #{day}, Part #{pt}\n----------------\n#{output}"
      puts 'Bad exit code detected' unless $?.success?
      puts "----------------\nExecution time: #{(time * 1000).round(4)} ms\n\n"
      puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
    end
  end

  def self.init(year, day, lang)
    if $MASTER_DIR.nil? && !in_year_dir
      abort('`init` may only be used in an year directory or if MASTER_DIR is defined')
    end
    # none      -> year = aoc_year, day = today (est)
    # just year -> abort, no info to go off of
    # just day  -> year = aoc_year, day = day
    # both      -> do nothing
    abort('Unable to init for unknown day!') if year && day.nil?
    year = default_year if year.nil?
    day  = Time.now.getlocal('-05:00').day if day.nil?

    lang = $DEFAULT_LANG if lang.nil?
    ext  = $LANG_MAP[lang.downcase]
    ext.nil? && abort("Unidentified language: #{lang}")

    input_file_dir  = build_input_dir(year, day)
    input_file_path = build_input_file(year, day)

    # http GET
    input = AocClient.get_input(day, year)

    # create input file
    FileUtils.mkdir_p(input_file_dir)
    File.open(input_file_path, 'w').write(input)

    puts "Input for day #{day}, year #{year} written to #{input_file_path}"

    # create solution file
    solution_path = build_solution_dir(year, day)
    FileUtils.mkdir_p(solution_path)

    # fun template stuff
    puts ext
    template_path = File.join($CONFIG_DIR, 'templates', "template.#{ext}")
    template = File.exist?(template_path) ? File.read(template_path) : ''
    template.gsub!('%%YEAR%%', year.to_s)
    template.gsub!('%%DAY%%', day.to_s)
    template.gsub!('%%PWD%%', solution_path)
    template.gsub!('%%TIME(anything here)%%', Time.now.strftime('anything here'))
    template.gsub!(/%%TIME\((.*?)\)%%/) do
      Time.now.strftime(::Regexp.last_match(1))
    end
    t1 = template.gsub('%%PART%%', '1')
    t2 = template.gsub('%%PART%%', '2')

    p1 = build_solution_file(year, day, 1, ext)
    p2 = build_solution_file(year, day, 2, ext)

    # make solution files if they do not already exist
    File.open(p1, 'w') { |f| f.write(t1) } unless File.exist?(p1)
    File.open(p2, 'w') { |f| f.write(t2) } unless File.exist?(p2)
    puts "Solution files created in #{solution_path}!"

    # spawn editor process, TODO: figure out how to do properly
    return if $IDE.nil?

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
  
def self.config_gen
    puts "# Example configuration file. Typically stored as ~/.config/aoc/config.rb
# If you ever break your config, you can generate a new one with `aoc make-config > config.rb`

##############################################
#     Things you should probably change      #
##############################################

# Unique session cookie as a hex string. Required to interface with AoC server. 
# Read wiki/Cookie to see how to get your unique session cookie.
$SESSION = ''

# Specifies master directory (recommended). For more info, check the wiki/Master_Directory
$MASTER_DIR = nil

# Default language. 
# Read wiki/Language_Support to see which languages are supported and how to support additional languages.
$DEFAULT_LANG = 'python'

# IDE. Leave blank if you don't want files to automatically be opened upon `init`
$IDE = 'nvim'

##############################################
#     Things you can change if you want      #
##############################################

# If true, input files are put in the same directory as solutions 
# eg. master_dir/year_dir/solutions/01/input.txt
$INPUTS_WITH_SOLUTIONS = false

# If true, input is put into the AOC_INPUT environment variable
# eg. AOC_INPUT=data... python 1.py
$USE_ENV_INPUT = true

# If true, input is fed via STDIN into your program
# eg. python 1.py < input.txt
$USE_STDIN_INPUT = true

# All solution files are prefixed with this 
# eg. part 1's file would go from 1.py -> {SOLUTION_FILE_PREFIX}1.py
# Absolutely necessary for languages like Java that have special file name requirements
# If you plan to only use good languages, you can leave an empty string.
$SOLUTION_FILE_PREFIX = 'p'

# If your language is compiled and a custom library must be compiled with it, specify here.
# eg. I can #include 'custom.h' and then add 'custom.cpp' to $LIB_FILES
$LIB_FILES = []

##############################################
# Only modify if you know what you are doing #
##############################################

# Here, you can add support for additional languages. Be sure to read wiki/Language_Support throughly
# If your (non-esolang) language seems to be incompatible, I consider that a bug. Please open an issue describing it.
# If you integrate an unsupported language, please open a PR so that the language can be officially supported.

# Map from languages and extensions to extension.
# eg. $LANG_MAP['c++'] = 'cpp'
$LANG_MAP # add your own languages + extensions

# If your language must be compiled, add a line like:
# $COMPILER_MAP['rs'] = 'rustc -o %%BIN_DIR%%/p%%PART%%.out'
# special vars are '%%BIN_DIR%%' and '%%PART%%' which are replaced by the binaries directory and part no. respectively.
$COMPILER_MAP # if your language is interpreted, don't add it.

# If your language is run like a binary, ignore this. Otherwise, add the interpreter.
# Note, some 'compiled' languages like Java are 'interpreted' via `java`
# For some compiled languages like Elixir, you can just use the interpreter instead
$INTERPRETER_MAP

# Specify which file to run. If left nil, the solution file will be ran with the interpreter.
# Best understood via example:
# 'java'  => '%%BIN_DIR%%/%%SOLUTION_FILE_NAME%%',
# 'c'     => '%%BIN_DIR%%/p%%PART%%.out',
# 'cpp'   => '%%BIN_DIR%%/p%%PART%%.out',
# 'rs'    => '%%BIN_DIR%%/p%%PART%%.out',
# Note the special variables. Modify as needed
$RUN_FILE_MAP
"
  end
end


