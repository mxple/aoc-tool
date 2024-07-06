require_relative 'lib/commands'
require_relative 'lib/constants'
require_relative 'lib/common'

# Parse args
ARGV.empty? && abort($HELP_MSG)

year, day, name = parse_problem(ARGV)

case ARGV[0]
when 'r', 'run'
  Commands.run(year, day, name)
when 'i', 'init'
  Commands.init(year, day, name)
when 's', 'submit'
  Commands.submit(year, day, name)
when 'create-year'
  Commands.create_year(year, day, name)
when 'master-init'
  Commands.master_init(year, day, name)
when 'config-gen'
  Commands.config_gen
when 'info-dump'
  Commands.info_dump
else
  abort($HELP_MSG)
end
