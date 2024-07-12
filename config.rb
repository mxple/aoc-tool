# Example configuration file. Typically stored as ~/.config/aoc/config.rb
# If you ever break your config, you can generate a new one with `aoc config-gen > config.rb`

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

# If true, puzzle files are put in the same directory as solutions 
$PUZZLES_WITH_SOLUTIONS = false


# Choose your naming scheme. Changing these may break aoc-tool for old directories.
# Must use %%DAY%% and %%PART%% special variables.
$DAY_DIRECTORY_NAME = '%%DAY%%'
$SOLUTION_FILE_NAME = 'p%%PART%%'

# Enable to put input into AOC_INPUT environment variable
$USE_ENV_INPUT = true

# Enable to feed input as stdin
$USE_STDIN_INPUT = true

# If a custom library should be compiled with solutions, specify the path here.
$LIB_FILES = []

##############################################
# Only modify if you know what you are doing #
##############################################

# Here, you can add support for additional languages. Check out the example for Java below.
# If your language seems to be incompatible, I consider that a bug. Please open an issue describing it.
# If you integrate an unsupported language, please open a PR so that the language can be officially supported.

# Language.add(
#   name        = 'java',
#   extension   = 'java',
#   compile_cmd = 'javac -d %%BIN_DIR%% %%SRC_FILE%% %%LIB_FILES%%', # nil for interpreted langs
#   interpreter = 'java -cp %%BIN_DIR%% %%RUN_FILE_BASE%%'
# )

# Using the above command, you can override existing language configurations too.
# For example, you can change compiler from g++ to MSVC and stuff.
