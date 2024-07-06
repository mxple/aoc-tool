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

def default_year
  y = in_year_dir ? File.readlines('.aoc')[0].strip : nil
  return y.to_i if y.to_i.between?(2015, Time.now.year) 

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
  File.join(get_year_dir(year), 'solutions', f02(day), '/')
end

def build_input_dir(year, day)
  return File.join(get_year_dir(year), 'solutions', f02(day), '/') if $INPUTS_WITH_SOLUTIONS

  File.join(get_year_dir(year), 'inputs/')
end

def build_binary_dir(year, day, part)
  File.join(get_year_dir(year), 'binaries')
end

def build_solution_file(year, day, part, ext)
  File.join(get_year_dir(year), 'solutions', f02(day), "#{$SOLUTION_FILE_PREFIX}#{part}.#{ext}")
end

def build_input_file(year, day)
  return File.join(get_year_dir(year), 'solutions', f02(day), 'input.txt') if $INPUTS_WITH_SOLUTIONS

  File.join(get_year_dir(year), 'inputs', f02(day)+'.txt')
end

def solution_name(part)
  "#{$SOLUTION_FILE_PREFIX}#{part}"
end

def most_recent_dir(year)
  Dir.glob("#{get_year_dir(year)}/*").select { |f| File.directory?(f) && /\d/.match?(f) }.max_by { |f| File.mtime(f) }
end

def most_recent_day(year, day)
end

def get_year_dir(year)
  return './' if in_year_dir

  unless $MASTER_DIR.nil?
    !File.exists?(File.join($MASTER_DIR, '.aoc')) && abort('Master directory is missing \'.aoc\' file! Run `aoc master-init` to initialize the master directory.')
    year_dir = parse_aoc(File.read(File.join($MASTER_DIR, '.aoc')))[year.to_s]
    year_dir.nil? && abort("No year directory found for #{year}. Initialize one with `aoc create <year>`")
    return File.join($MASTER_DIR, year_dir, '/')
  end

  nil
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
