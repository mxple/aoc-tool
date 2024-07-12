#!/usr/bin/env ruby
require_relative '../lib/commands'
require_relative '../lib/constants'
require_relative '../lib/common'

# Parse args
ARGV.empty? && abort($HELP_MSG)

year, day, etc = parse_problem(ARGV)

validate_config if ARGV[0] != 'config-gen'

case ARGV[0]
when 'c', 'create'
  Commands.create(year, day, etc)
when 'e', 'edit'
  Commands.edit(year, day, etc)
when 'r', 'run'
  Commands.run(year, day, etc)
when 's', 'submit'
  Commands.submit(year, day, etc)
when 'init-year'
  Commands.init_year(year, day, etc)
when 'init-master'
  Commands.init_master(year, day, etc)
when 'config-gen'
  Commands.config_gen
when 'info-dump'
  Commands.info_dump
else
  abort($HELP_MSG)
end
