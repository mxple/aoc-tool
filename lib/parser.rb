class Parser
  attr_accessor :str

  def initialize(str)
    @str = str
  end

  # html parse methods
  def replace_links_md!
    regex = /<a href=[^>]+>([^<]+)<\/a>/
    @str.gsub!(regex) do |m| "[#{regex.match(m)[1]}]"; end
    self
  end
  
  def replace_header_md!
    regex = /<h2.*?>([\S\s]+?)<\/h2>/
    @str.gsub!(regex) do |m| "## #{regex.match(m)[1]}"; end
    self
  end

  def replace_paragraph_md!
    regex = /<p>([\S\s]+?)<\/p>/
    @str.gsub!(regex) do |m| "\n#{regex.match(m)[1]}"; end
    self
  end

  def replace_block_md!
    regex = /<pre><code>([\S\s]+?)<\/code><\/pre>/
    @str.gsub!(regex) do |m| "```\n#{regex.match(m)[1]}```"; end
    self
  end

  def replace_code_md!
    regex = /<code>([\S\s]+?)<\/code>/
    @str.gsub!(regex) do |m| "`#{regex.match(m)[1]}`"; end
    self
  end

  def replace_glow_md!
    regex = /<em>([\S\s]+?)<\/em>/
    @str.gsub!(regex) do |m| "**#{regex.match(m)[1]}**"; end
    self
  end

  def replace_star_md!
    regex = /<em class="star">([\S\s]+?)<\/em>/
    @str.gsub!(regex) do |m| "***#{regex.match(m)[1]}***"; end
    self
  end

  def replace_list_md!
    regex = /<ul>([\S\s]+?)<\/ul>/
    @str.gsub!(regex) do |m| regex.match(m)[1] end

    regex = /<li>([\S\s]+?)<\/li>/
    @str.gsub!(regex) do |m| "- #{regex.match(m)[1]}" end
    self
  end

  def remove_easter_eggs!
    regex = /<span[^>]+>([\S\s]+?)<\/span>/
    @str.gsub!(regex) do |m| regex.match(m)[1]; end
    self
  end

  def extract_main!
    regex = /<main>([\S\s]+?)<\/main>/
    @str = regex.match(@str)[1].strip
    self
  end

  def extract_articles
    regex = /<article[^>]*?>([\S\s]+?)<\/article>/
    articles = @str.scan(regex)
    articles.flatten
  end

  def replace_links!
    regex = /<a href=[^>]+>([^<]+)<\/a>/
    @str.gsub!(regex) do |link| regex.match(link)[1].blue!; end
    self
  end

  def replace_stars!
    @str.gsub!("<span class=\"day-success\">one gold star</span>", 'one gold star'.bright_yellow!)
    self
  end

  def replace_guess!
    regex = /\(You guessed <span style=[^>]+><code.([^<]+)<\/code>.\)<\/span>/
    @str.gsub!(regex) do |link| 
      "(You guessed #{regex.match(link)[1].bright_white!.bold!})."
    end
    self
  end

  def get_str
    @str
  end
end
