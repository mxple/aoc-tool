module Commands
  def self.create_year(year, day, name)
    error('Specify a valid year! Usage: `init-year` <year> <dir_name') if year.nil?
    error('Too many arguments! Usage: `init-year` <year> <dir_name>') if day && name
    error('Too few arguments! Usage: `init-year` <year> <dir_name>') if day.nil? && name.nil?
    name = day if name.nil?

    # create directory
    base = $MASTER_DIR || './'
    year_dir = File.join(base, name)

    begin
      Dir.mkdir(year_dir)
    rescue Errno::EEXIST => e
      warn "Existing directory, '#{year_dir.bold!}' found. Attempting to reinitialize directory. "
    end

    # create .aoc file in year directory
    File.open(File.join(year_dir, '.aoc_year'), 'w').write(year.to_s)

    # update master dir .aoc file
    # TODO: decereal and cerealize
    $MASTER_DIR && File.open(File.join($MASTER_DIR, '.aoc'), 'a').write("\n#{year}:#{name}")
  end
end