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

# Default language. 
# Read wiki/Language_Support to see which languages are supported and how to support additional languages.
$DEFAULT_LANG = 'python'

# IDE. Leave blank if you don't want files to automatically be opened upon `init`
$IDE = 'nvim'

##############################################
#     Things you can change if you want      #
##############################################

# If true, input files are put in the same directory as solutions 
# eg. master_dir/year_dir/solutions/01/input.txt
$INPUTS_WITH_SOLUTIONS = false

# If true, input is put into the AOC_INPUT environment variable
# eg. AOC_INPUT=data... python 1.py
$USE_ENV_INPUT = true

# If true, input is fed via STDIN into your program
# eg. python 1.py < input.txt
$USE_STDIN_INPUT = true

# All solution files are prefixed with this 
# eg. part 1's file would go from 1.py -> {SOLUTION_FILE_PREFIX}1.py
# Absolutely necessary for languages like Java that have special file name requirements
# If you plan to only use good languages, you can leave an empty string.
$SOLUTION_FILE_PREFIX = 'p'

# If your language is compiled and a custom library must be compiled with it, specify here.
# eg. I can #include 'custom.h' and then add 'custom.cpp' to $LIB_FILES
$LIB_FILES = []

##############################################
# Only modify if you know what you are doing #
##############################################

# Here, you can add support for additional languages. Be sure to read wiki/Language_Support throughly
# If your (non-esolang) language seems to be incompatible, I consider that a bug. Please open an issue describing it.
# If you integrate an unsupported language, please open a PR so that the language can be officially supported.

# Map from languages and extensions to extension.
# eg. $LANG_MAP['c++'] = 'cpp'
$LANG_MAP # add your own languages + extensions

# If your language must be compiled, add a line like:
# $COMPILER_MAP['rs'] = 'rustc -o %%BIN_DIR%%/p%%PART%%.out'
# special vars are '%%BIN_DIR%%' and '%%PART%%' which are replaced by the binaries directory and part no. respectively.
$COMPILER_MAP # if your language is interpreted, don't add it.

# If your language is run like a binary, ignore this. Otherwise, add the interpreter.
# Note, some 'compiled' languages like Java are 'interpreted' via `java`
# For some compiled languages like Elixir, you can just use the interpreter instead
$INTERPRETER_MAP

# Specify which file to run. If left nil, the solution file will be ran with the interpreter.
# Best understood via example:
# 'java'  => '%%BIN_DIR%%/%%SOLUTION_FILE_NAME%%',
# 'c'     => '%%BIN_DIR%%/p%%PART%%.out',
# 'cpp'   => '%%BIN_DIR%%/p%%PART%%.out',
# 'rs'    => '%%BIN_DIR%%/p%%PART%%.out',
# Note the special variables. Modify as needed
$RUN_FILE_MAP
