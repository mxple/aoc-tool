module Commands
  def self.master_init(year, day, name)
    error('`aoc master-init` takes no arguments!') if year || day || name
    error('$MASTER_DIR is nil! Make sure to define it in your config!') if $MASTER_DIR.nil?
    Dir.exist?($MASTER_DIR) && File.exist?(File.join($MASTER_DIR,
                                                     '.aoc')) && error('Master directory already initialized!')

    FileUtils.mkdir_p($MASTER_DIR)
    File.open(File.join($MASTER_DIR, '.aoc'), 'w').write($TAMPER_WARNING)
  end
end
