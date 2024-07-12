module Language
  @language_id = 0

  LANG_TO_ID    = {}
  EXTENSION_MAP = []
  COMPILER_MAP  = []
  RUN_CMD_MAP   = []

  def self.add(etc, extension, compile_cmd, run_cmd)
    etc = etc.downcase

    unless LANG_TO_ID[etc]
      LANG_TO_ID[etc] = @language_id
      LANG_TO_ID[extension.downcase] = @language_id
      EXTENSION_MAP[@language_id] = extension.downcase
      @language_id += 1
    end

    COMPILER_MAP[LANG_TO_ID[etc]] = compile_cmd unless compile_cmd.nil?
    RUN_CMD_MAP[LANG_TO_ID[etc]]  = run_cmd unless run_cmd.nil?
  end

  def self.get_lang(string)
    LANG_TO_ID[string.downcase]
  end

  def self.get_ext(lang)
    lang = [self.get_lang(lang)] if lang.is_a?(String)

    EXTENSION_MAP[lang]
  end

  def self.get_compiler(lang)
    lang = self.get_lang(lang) if lang.is_a?(String) 

    COMPILER_MAP[lang] ? COMPILER_MAP[lang] : nil
  end

  def self.get_run_cmd(lang)
    lang = self.get_lang(lang) if lang.is_a?(String)

    RUN_CMD_MAP[lang] ? RUN_CMD_MAP[lang] : ''
  end

  def self.is_compiled?(lang)
    return !self.get_compiler(lang).nil?
  end

  def self.dump
    puts LANG_TO_ID
    puts COMPILER_MAP
    puts RUN_CMD_MAP
  end
end
