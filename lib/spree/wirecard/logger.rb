
module Spree::Wirecard
  class Logger
    include Singleton
    
    # Native logger object
    attr_reader :native_logger
    
    # Sets initial data.
    def initialize
      @native_logger = ::Logger.new 'log/wirecard_checkout_page.log'
    end
    
    def log(level, message)
      timestamp = Time.now.utc.to_s
      native_logger.debug '[' + timestamp + '] ' + level.to_s.upcase + ' -- : ' + message
    end
    
    def debug message
      return if Rails.env.production?
      self.log :debug, message
    end
    
    def error message
      self.log :error, message
    end
    
    def fatal message
      self.log :fatal, message
    end
    
    def info message
      self.log :info, message
    end
    
    def warn message
      self.log :warn, message
    end
    
    def self.debug message
      Spree::Wirecard::Logger.instance.debug message
    end
    
    def self.error message
      Spree::Wirecard::Logger.instance.error message
    end
    
    def self.fatal message
      Spree::Wirecard::Logger.instance.fatal message
    end
    
    def self.info message
      Spree::Wirecard::Logger.instance.info message
    end
    
    def self.warn message
      Spree::Wirecard::Logger.instance.warn message
    end
  end
end