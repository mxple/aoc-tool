module Metadata 
  @meta = nil

  def self.cache_results(year, day, p1, p2)
    # read metadata from .aoc
    deserialize
    
    # write run data to metadata object
    @meta['last_run_year'] = year.to_s
    @meta['last_run_day']  = day.to_s

    @meta['p1cache'] = p1.lines.last.strip if p1 && p1.length > 0
    @meta['p2cache'] = p2.lines.last.strip if p2 && p2.length > 0

    # serialize object into .aoc
    serialize
  end

  def self.get_cached_results(part)
    deserialize
    part == 1 ? @meta['p1cache'] : @meta['p2cache']
  end

  def self.set_last_puzzle(year, day, lang_code)
    @meta = deserialize
    @meta['last_puzzle'] = "#{year},#{day},#{lang_code}"
    serialize
  end

  def self.last_puzzle
    @meta = deserialize
    @meta['last_puzzle'].split(',').map(&:to_i)
  end

  def self.year_dir(year)
    @meta = deserialize
    @meta[year.to_s]
  end

  def self.last_run
    deserialize
    [@meta['last_run_year'], @meta['last_run_day']]
  end

  def self.load
    deserialize
  end

  module_function
  def deserialize
    check_metafile_exists

    return @meta if @meta

    @meta = {}
    File.read(File.join($MASTER_DIR, '.aoc'))
      .split("\n")
      .map(&:strip)
      .select { |l| !l.empty? && l[0] != '#' }
      .map { |l| l.split(':', 2).map(&:strip) }
      .each do |k, v|
        @meta[k] = v
      end
    @meta
  end

  def serialize
    check_metafile_exists

    aoc_path = File.join($MASTER_DIR, '.aoc')

    f = File.open(aoc_path, 'w')

    @meta.each do |k, v|
      f.write("#{k}:#{v}\n")
    end

    f.close
  end

  def check_metafile_exists
    if !Dir.exist?($MASTER_DIR) || !File.exist?(File.join($MASTER_DIR, '.aoc'))
      error("Master directory is not initialized! Initialize with `aoc init-master`") 
    end
  end

end
