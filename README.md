# aoc-tool
Organize, download, write, test, and submit Advent of Code puzzles from the command line! 

**aoc-tool** aims to offer a language-agnostic way to solve AoC puzzles from the comfort of the terminal. 

## Install
Depends on: Ruby. And bash (most shells will do).

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
aoc run  # runs puzzle last init-ed puzzle
```
Runs are language agnostic! If your language isn't automatically supported, you can add support in the config file.
Submit with
```
aoc submit  # submits last run's output, or a specified year, day, and answer
```

## Contributing
Contributing language support and
