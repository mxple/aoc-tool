module Commands
  def self.init_year(year, day, etc)
    error('Specify a valid year! Usage: `init-year` <year> <dir_name') if year.nil?
    error('Too many arguments! Usage: `init-year` <year> <dir_name>') if day && etc
    error('Too few arguments! Usage: `init-year` <year> <dir_name>') if day.nil? && etc.nil?
    etc = day if etc.nil?

    # create directory
    base = $MASTER_DIR || './'
    year_dir = File.join(base, etc)

    begin
      Dir.mkdir(year_dir)
    rescue Errno::EEXIST => e
      warn "Existing directory, '#{year_dir.bold!}' found. Attempting to reinitialize directory. "
    end

    # create .aoc file in year directory
    File.open(File.join(year_dir, '.aoc_year'), 'w').write(year.to_s)

    # update master dir .aoc file
    # TODO: decereal and cerealize
    $MASTER_DIR && File.open(File.join($MASTER_DIR, '.aoc'), 'a').write("\n#{year}:#{etc}")
  end
end
