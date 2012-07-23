require 'log4r'
require 'log4r/yamlconfigurator'
require 'log4r/outputter/datefileoutputter'

module Log4rLoggersHelper
  @ymlCfgFile = "#{RAILS_ROOT}/config/log4r.yml"
  
  def self.generate_log4r_config
    yml = Hash.new
    yml['log4r_config'] = Hash.new
    yml['log4r_config']['pre_config'] = get_pre_config
    
    yml['log4r_config']['loggers'] = Array.new
    log4r_loggers = Log4rLogger.all
    logger_names = Array.new
    log4r_loggers.each do |logger|
      yml['log4r_config']['loggers'].push(get_logger(logger))
      logger_names.push(logger.name)
    end
    
    yml['log4r_config']['outputters'] = get_outputters(logger_names)
    
    write_to_yml(yml)

  end
  
  def self.write_to_yml(yml)
    File.open(@ymlCfgFile, 'w') do |file|
      file.puts(yml.to_yaml)
    end 
  end
  def self.get_outputters(logfile_names)
    logfile_names.push('stderr')
    
    outputters = Array.new
    logfile_names.each do |name|
      outputter = Hash.new
      outputter['name'] = name
      outputter['level'] = 'DEBUG'
      outputter['formatter'] = get_formatter
      if name == 'stderr'
        outputter['type'] = 'StderrOutputter'
      else
        outputter['type'] = 'DateFileOutputter'
        outputter['dirname'] = "\#{RAILS_ROOT}/log"
        outputter['filename'] = "#{name}.log"
      end
      outputters.push(outputter)
    end
    return outputters
  end
  
  def self.get_formatter
    return {
      'date_pattern' => '%y%m%d %H:%M:%S',
      'pattern' => '%d %l: %m ',
      'type' => 'PatternFormatter',
    }
  end

  def self.get_logger(logger)
    loggerHash = Hash.new
    name = logger.name
    loggerHash['name'] = name
    loggerHash['level'] = logger.log_level
    loggerHash['additive'] = 'false'
    loggerHash['trace'] = 'false'
    loggerHash['outputters'] = Array.new
    loggerHash['outputters'].push('stderr')
    loggerHash['outputters'].push(name)
    return loggerHash
  end
  
  def self.get_pre_config
    return {
      'custom_levels' => get_custom_levels,
      'global' => get_default_level,
      'root' => get_default_level,
    }
  end

  def self.get_default_level
    return {'level' => 'DEBUG'}
  end
  
  def self.get_custom_levels
    return ['NONE', 'INFO', 'DEBUG']
  end


end
