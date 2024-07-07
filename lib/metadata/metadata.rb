module Metadata 
  def self.cache_results(year, day, p1, p2)
    # read metadata from .aoc
    meta = deserialize
    
    # write run data to metadata object
    meta['last_run_year'] = year.to_s
    meta['last_run_day']  = day.to_s

    meta['p1cache'] = p1.lines.last.strip if p1 && p1.length > 0
    meta['p2cache'] = p2.lines.last.strip if p2 && p2.length > 0

    # serialize object into .aoc
    serialize meta
  end

  def self.get_cached_results(part)
    meta = deserialize
    return part == 1 ? meta['p1cache'] : meta['p2cache']
  end

  def self.last_run
    meta = deserialize
    return [meta['last_run_year'], meta['last_run_day']]
  end

  module_function
  def deserialize
    check_metafile_exists

    contents = File.read(File.join($MASTER_DIR, '.aoc'))

    meta = {}
    contents
      .split("\n")
      .map(&:strip)
      .select { |l| !l.empty? && l[0] != '#' }
      .map(&:strip)
      .map { |l| l.split(':').map(&:strip) }
      .each do |k, v|
        meta[k] = v
      end
    meta
  end

  def serialize(meta)
    check_metafile_exists

    aoc_path = File.join($MASTER_DIR, '.aoc')

    File.open(aoc_path, 'w').write('') # clear

    meta.each do |k, v|
      File.open(aoc_path, 'a').write("#{k}:#{v}\n")
    end
  end

  def check_metafile_exists
    if !Dir.exist?($MASTER_DIR) || !File.exist?(File.join($MASTER_DIR, '.aoc'))
      error("Master directory is not initialized! Initialize with `aoc master-init`") 
    end
  end

end
