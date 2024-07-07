# Example configuration file. Typically stored as ~/.config/aoc/config.rb
# If you ever break your config, you can generate a new one with `aoc make-config > config.rb`

##############################################
#     Things you should probably change      #
##############################################

# Unique session cookie as a hex string. Required to interface with AoC server. 
# Read wiki/Cookie to see how to get your unique session cookie.
$SESSION = ''

# Specifies master directory (recommended). For more info, check the wiki/Master_Directory
$MASTER_DIR = nil

# Default language files are created with.
$DEFAULT_LANG = 'python'

# IDE. Leave blank if you don't want files to be automatically opened.
$IDE = 'nvim'

##############################################
#     Things you can change if you want      #
##############################################

# If true, input files are put in the same directory as solutions 
$INPUTS_WITH_SOLUTIONS = true

# Choose your naming scheme. Changing these may break aoc-tool for old directories.
# Must use %%DAY%% and %%PART%% special variables.
$DAY_DIRECTORY_NAME = '%%DAY%%'
$SOLUTION_FILE_NAME = 'p%%PART%%' # Java require non-numeric file name.

# AOC_INPUT=data... python 1.py
$USE_ENV_INPUT = true

# python 1.py < input.txt
$USE_STDIN_INPUT = true

# If a custom library should be compiled with solutions, specify the path here.
$LIB_FILES = []

##############################################
# Only modify if you know what you are doing #
##############################################

# Here, you can add support for additional languages. Be sure to read wiki/Language_Support throughly
# If your (non-esolang) language seems to be incompatible, I consider that a bug. Please open an issue describing it.
# If you integrate an unsupported language, please open a PR so that the language can be officially supported.

# Language.add(
#   name        = 'java',
#   extension   = 'java',
#   compile_cmd = 'java -d %%BIN_DIR%% %%SRC_FILE%% %%LIB_FILES%%',
#   interpreter = 'java'
# )
