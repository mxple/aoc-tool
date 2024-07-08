#!/usr/bin/env ruby
require_relative '../lib/commands'
require_relative '../lib/constants'
require_relative '../lib/common'

# Parse args
ARGV.empty? && abort($HELP_MSG)

year, day, name = parse_problem(ARGV)

validate_config if ARGV[0] != 'config-gen'

case ARGV[0]
when 'r', 'run'
  Commands.run(year, day, name)
when 'c', 'create'
  Commands.create(year, day, name)
when 's', 'submit'
  Commands.submit(year, day, name)
when 'init-year'
  Commands.init_year(year, day, name)
when 'init-master'
  Commands.init_master(year, day, name)
when 'config-gen'
  Commands.config_gen
when 'info-dump'
  Commands.info_dump
else
  abort($HELP_MSG)
end
