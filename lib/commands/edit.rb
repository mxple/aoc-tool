module Commands
  def self.edit(year, day, lang = nil)
    error('Cannot specify year without specifying day.') if year && day.nil?

    if year.nil? && day.nil?
      year, day, lang_code = Metadata.last_puzzle
      error("No previous run found.") if year.nil? || day.nil?
    end

    year = default_year if year.nil?

    lang = $DEFAULT_LANG if lang.nil?
    lang_code = Language.get_lang(lang) if lang_code.nil?

    lang_code.nil? && error("Unsupported language: #{lang.bold!}")

    ext = Language.get_ext(lang_code)

    puzzle_file_dir  = build_puzzle_dir(year, day)
    puzzle_file_path = build_puzzle_file(year, day)

    input_file_dir  = build_input_dir(year, day)
    input_file_path = build_input_file(year, day)

    p1 = build_solution_file(year, day, 1, ext)
    p2 = build_solution_file(year, day, 2, ext)

    ide_cmd = $IDE.dup
    ide_cmd.gsub!('%%PUZZLE%%', puzzle_file_path)
    ide_cmd.gsub!('%%INPUT%%', input_file_path)
    ide_cmd.gsub!('%%P1%%', p1)
    ide_cmd.gsub!('%%P2%%', p2)
    ide_cmd.gsub!('%%PART1%%', p1)
    ide_cmd.gsub!('%%PART2%%', p2)

    system(ide_cmd)
  end
end
