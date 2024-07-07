# year day etc
def parse_problem(argv)
  abort("Too many arguments!\n#{$HELP_MSG}") if argv.length > 4

  ret = [nil, nil, nil]

  argv.each_with_index do |e, i|
    next if i.zero?

    ptr = 0
    while ptr < 3
      ei = e.to_i
      if ei.to_s == e
        break ret[0] = ei if ptr == 0 && ret[0].nil? && ei.between?(2015, Time.now.year)
        break ret[1] = ei if ptr == 1 && ret[1].nil? && ei.between?(1, 25)
        break ret[2] = e  if ptr == 2 && ret[2].nil?
      elsif ptr == 2
        ret[2] = e
      end
      ptr += 1
    end
  end

  ret
end

def validate_config
  !$DAY_DIRECTORY_NAME.include?('%%DAY%%') && abort("Config error: Config value $DAY_DIRECTORY_NAME must include '%%DAY%%'")
  !$SOLUTION_FILE_NAME.include?('%%PART%%') && abort("Config error: Config value $SOLUTION_FILE_NAME must include '%%PART%%'")
  !$INPUT_FILE_NAME.include?('%%DAY%%') && !$INPUTS_WITH_SOLUTIONS && abort("Config error: Config value $INPUT_FILE_NAME must include '%%DAY%%' when $INPUTS_WITH_SOLUTIONS is false")

  # TODO: extra validation. for now, just fail/ub if the user enters atrocities.
end

def default_year
  return File.readlines('.aoc_year')[0].strip.to_i if in_year_dir

  most_recent_aoc_year
end

def parse_part(part)
  return [1]    if %w[1 one p1 P1 part1 Part1 part_1 Part_1].include?(part)
  return [2]    if %w[2 two p2 P2 part2 Part2 part_2 Part_2].include?(part)
  return [1, 2] if %w[12 both all].include?(part) || part.nil?

  abort("Unable to parse argument as part: '#{part}'")
end

# path builders
def build_solution_dir(year, day)
  File.join(year_dir(year), $SOLUTIONS_DIR_NAME, day_dir(day))
end

def build_solution_file(year, day, part, ext)
  File.join(year_dir(year), $SOLUTIONS_DIR_NAME, day_dir(day), "#{solution_file_name(part)}.#{ext}")
end

def build_input_dir(year, day)
  return File.join(year_dir(year), $SOLUTIONS_DIR_NAME, day_dir(day)) if $INPUTS_WITH_SOLUTIONS

  File.join(year_dir(year), $INPUTS_DIR_NAME)
end

def build_input_file(year, day)
  return File.join(year_dir(year), $SOLUTIONS_DIR_NAME, day_dir(day), input_file_name(day)) if $INPUTS_WITH_SOLUTIONS

  File.join(year_dir(year), $INPUTS_DIR_NAME, input_file_name(day))
end

def build_binary_dir(year, pt)
  File.join(year_dir(year), 'binaries', pt.to_s)
end

def day_dir(day)
  $DAY_DIRECTORY_NAME.gsub('%%DAY%%', f02(day))
end

def input_file_name(day)
  $INPUT_FILE_NAME.gsub('%%DAY%%', f02(day))
end

def solution_file_name(part)
  $SOLUTION_FILE_NAME.gsub('%%PART%%', part.to_s)
end

def year_dir(year)
  # TODO: warn user of potential mis-intent
  return Dir.pwd if in_year_dir && year.nil?

  year = default_year if year.nil?

  unless $MASTER_DIR.nil?
    !File.exist?(File.join($MASTER_DIR, '.aoc')) && abort('Master directory is missing \'.aoc\' file! Run `aoc master-init` to initialize the master directory.')
    year_dir = parse_aoc(File.read(File.join($MASTER_DIR, '.aoc')))[year.to_s]
    year_dir.nil? && abort("No year directory found for #{year}. Initialize one with `aoc create <year> <directory>`")
    return File.join($MASTER_DIR, year_dir)
  end

  abort("No year directory found for #{year}. Initialize one with `aoc create <year> <directory>`")
end

def most_recent_dir(year)
  Dir.glob("#{year_dir(year)}/*").select { |f| File.directory?(f) && /\d/.match?(f) }.max_by { |f| File.mtime(f) }
end

def parse_aoc(contents)
  aoc = {}
  contents
    .split("\n")
    .map(&:strip)
    .select { |l| !l.empty? && l[0] != '#' }
    .map(&:strip)
    .map { |l| l.split(':').map(&:strip) }
    .each do |kv|
      aoc[kv[0]] = kv[1]
    end
  aoc
end

def f02(i)
  format('%02d', i)
end

def most_recent_aoc_year
  est = Time.now.getlocal('-05:00')
  return est.year if est.month == 12

  est.year - 1
end

def in_year_dir
  File.exist?('.aoc_year')
end

def error(msg)
  puts "#{'[AOC-ERROR]'.red!} #{msg}"
  exit 1
end

def warn(msg)
  puts "#{'[AOC-WARN]'.yellow!} #{msg}"
end

def info(msg)
  puts "#{'[AOC-INFO]'.bright_white!} #{msg}"
end

def debug(msg)
  return unless ENV['AOC_DEBUG']

  print "[AOC-DEBUG] "
  p msg
end

class String
  # Color escape codes
  def black!;       "\e[30m#{self}\e[0m" end
  def red!;         "\e[31m#{self}\e[0m" end
  def green!;       "\e[32m#{self}\e[0m" end
  def yellow!;      "\e[33m#{self}\e[0m" end
  def blue!;        "\e[34m#{self}\e[0m" end
  def magenta!;     "\e[35m#{self}\e[0m" end
  def cyan!;        "\e[36m#{self}\e[0m" end
  def white!;       "\e[37m#{self}\e[0m" end

  # Bright color escape codes
  def bright_black!;   "\e[90m#{self}\e[0m" end
  def bright_red!;     "\e[91m#{self}\e[0m" end
  def bright_green!;   "\e[92m#{self}\e[0m" end
  def bright_yellow!;  "\e[93m#{self}\e[0m" end
  def bright_blue!;    "\e[94m#{self}\e[0m" end
  def bright_magenta!; "\e[95m#{self}\e[0m" end
  def bright_cyan!;    "\e[96m#{self}\e[0m" end
  def bright_white!;   "\e[97m#{self}\e[0m" end

  # Formatting escape codes
  def bold!;          "\e[1m#{self}\e[0m" end
  def italic!;        "\e[3m#{self}\e[0m" end
  def underline!;     "\e[4m#{self}\e[0m" end
  def reverse_color!; "\e[7m#{self}\e[0m" end

  # Combination of attributes
  def bold_red!;      "\e[1;31m#{self}\e[0m" end

  def visible_length
    gsub(/\e\[[0-9;]*m/, '').length
  end
end
