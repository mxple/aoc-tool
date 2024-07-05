# aoc-tool
Organize, download, write, test, and submit Advent of Code puzzles from the command line! 

**aoc-tool** aims to offer a language-agnostic way to solve AoC puzzles from the comfort of the terminal. 

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
Run `aoc config-gen > ~/.config/aoc/config.rb` to generate a sample config file.

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
aoc master-init  # creates master_dir and some metadata
```
Choose a year to start off with:
```
aoc create-year 2023 aoc2023  # creates master_dir/aoc/2023 and some metadata
```
Download a puzzle:
```
aoc init 2023 1 rust  # download input and makes 2 rust files based off ~/.config/aoc/templates/template.rs
```
Happy coding! Once you finish a solution, you can run it on the input with:
```
aoc run  # runs specified puzzle or last init-ed puzzle
```
Runs are language agnostic! If your language isn't automatically supported, you can add support in the config file.
Submit with:
```
aoc submit  # submits last run's output, or a specified year, day, and answer
```

## Features
Smart commands can parse ambigous arguments:
```
aoc init 4 rs  # downloads puzzle 4 for latest AoC year and makes 2 rust files from templates
aoc r 3 2017  # runs solution for puzzle 3 of 2017, argument order doesn't (really) matter
aoc init  # downloads latest available puzzle
```

Input fed via environment variables and STDIN:
```python
for line in os.getenv('AOC_INPUT').splitlines(): # ...
```
```cpp
while (std::getline(std::cin, line)) // read in each line...
```

With `$MASTER_DIR` set, run `aoc` to download, edit, and run files from any directory:
```
$ pwd
/usr/bin      # be literally anywhere in your file system
$ aoc init    # download latest puzzle and have your IDE automatically called on the solution files
$ aoc test    # run latest puzzle solutions on custom test cases
$ aoc run     # compile/interpret and run on input data
$ aoc submit  # submit latest run result to corresponding puzzle
```

Organize the way you prefer with config options specifying how directories should be laid out:
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
You can mix languages, and have some (not total) control over the naming scheme of files.

## Advanced Features
**aoc-tool** also offers some features for advanced users:
- Support for custom libraries to compile with
- Add support for less popular languages via config
- Write Ruby code in config for more nuanced behavior

## Contributing
Contributions, especially for adding language support, are very welcome!
