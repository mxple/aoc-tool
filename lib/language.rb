module Language
  @language_id = 0

  LANG_TO_ID    = {}
  EXTENSION_MAP = []
  COMPILER_MAP  = []
  RUN_CMD_MAP   = []

  def self.add(name, extension, compile_cmd, interpreter)
    name = name.downcase

    unless LANG_TO_ID[name]
      LANG_TO_ID[name] = @language_id
      LANG_TO_ID[extension.downcase] = @language_id
      EXTENSION_MAP[@language_id] = extension.downcase
      @language_id += 1
    end

    COMPILER_MAP[LANG_TO_ID[name]] = compile_cmd unless compile_cmd.nil?
    RUN_CMD_MAP[LANG_TO_ID[name]]  = interpreter unless interpreter.nil?
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
    return self.get_compiler(lang)
  end

  def self.dump
    puts LANG_TO_ID
    puts COMPILER_MAP
    puts RUN_CMD_MAP
  end
end
