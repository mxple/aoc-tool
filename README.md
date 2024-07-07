# aoc-tool
Organize, download, write, test, and submit Advent of Code puzzles from the command line! 

**aoc-tool** offers a language-agnostic way to solve AoC puzzles from the comfort of the terminal. 

## Install
Depends on: Ruby

From source:
```
$ git clone https://github.com/mxple/aoc-tool  # somewhere safe
$ cd aoc-tool
$ ln -s $(pwd)/aoc /usr/bin/aoc
```

From AUR:
```
$ yay -S aoc-tool
```

From Gems
```
$ gem install aoc-tool
```

Windows people, use WSL until Windows is officially supported :p

## Getting Started
Run `aoc config-gen > ~/.config/aoc/config.rb` to generate a sample config file if there is not one already.

Modify the variables:
```
$SESSION      = 'your_session_cookie'
$MASTER_DIR   = '/path/to/master/dir'
$DEFAULT_LANG = 'your favorite language'
$IDE          = 'your IDE of choice'
```
That's all the configuration most users will need!

Then, initialize the master directory:
```
$ aoc init-master  # creates master_dir and some metadata
```
Choose a year to start off with:
```
$ aoc init-year 2023 aoc2023  # creates master_dir/aoc2023 and some metadata
```
Download a puzzle, its test cases, create solution files from templates, and open an IDE:
```
$ aoc create 2023 1 rust
```
Happy coding! Once you finish a solution, you can run it like so:
```
$ aoc run   # run specified puzzle or last init-ed puzzle
$ aoc test  # run the solution on test cases
```
Runs are language agnostic! If your language isn't automatically supported, you can add support in the config file.

Finally, submit with:
```
$ aoc submit  # submits last run's output, or a specified year, day, and answer
```

For more information about commands and usage:
```
$ aoc help
```
Or check the wiki (wip)!

## Features
Smart commands can parse ambigous arguments:
```
aoc create 4 rs  # download puzzle 4 for latest AoC year and makes 2 rust files from templates
aoc r 3 2017     # runs solution for puzzle 3 of 2017, argument order doesn't (really) matter
aoc create       # download latest available puzzle
```

Input fed via environment variables, STDIN, and file:
```python
lines = os.getenv('AOC_INPUT').splitlines()
lines = [line.strip() for line in sys.stdin]
lines = [line.strip() for line in open(os.getenv('AOC_INPUT_PATH')] 
```
The above four are all identical. Using **aoc-tool**'s supported inputs methods allow for dynamic and fast testing.

Run `aoc` to download, edit, and run files from any directory:
```
$ pwd
/usr/bin      # be literally anywhere in your file system
$ aoc init    # download latest puzzle and have your IDE automatically called on the solution files
$ aoc test    # run latest puzzle solutions on custom test cases
$ aoc run     # compile/interpret and run on input data
$ aoc submit  # submit latest run result to corresponding puzzle
```

Organize the way you prefer with a multitude of config options. Specify how files are named and how directories should be laid out:
```
# Two file trees generated with different configs
master                       |     master
├── advent22                 |     ├── advent22                
│   └── solutions            |     │   ├── inputs             
│       └── 04               |     │   │   └── 04.txt         
│           ├── input.txt    |     │   └── solutions          
│           ├── p1.py        |     │       └── 04             
│           └── p2.java      |     │           ├── part1.rs      
└── aoc2023                  |     │           └── part2.rs      
    └── solutions            |     └── aoc2023                
        ├── 01               |         ├── inputs             
        │   ├── input.txt    |         │   ├── 01.txt         
        │   ├── p1.py        |         │   └── 02.txt         
        │   └── p2.py        |         └── solutions          
        └── 02               |             ├── 01             
            ├── input.txt    |             │   ├── part1.py      
            ├── p1.hs        |             │   └── part2.py      
            └── p2.exs       |             └── 02             
                             |                 ├── part1.rb      
                             |                 └── part2.rb      
```
Mixing languages, even within the same puzzle, is valid! Adding `.md` writeup files to the puzzle directory is also okay.

## Advanced Features
**aoc-tool** also offers some features for advanced users:
- Support for custom libraries to compile with
- Add support for less popular languages via config
- Write Ruby code in config for more nuanced behavior

## Contributing
Contributions, especially for adding language support, are very welcome!
