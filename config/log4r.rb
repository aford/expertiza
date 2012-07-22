require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'

cfg = Log4r::YamlConfigurator
cfg['RAILS_ROOT'] = RAILS_ROOT
cfg['RAILS_ENV']  = RAILS_ENV

# load the YAML file if it exists
ymlCfg = "#{RAILS_ROOT}/config/log4r.yml"
if File.exist? ymlCfg
  cfg.load_yaml_file(ymlCfg)
end
