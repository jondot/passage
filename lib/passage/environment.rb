require 'yaml'
require 'logger'
require 'sinatra/base'

module Passage
  module Environment
    def configure!(opts)
      opts[:auth] ||= :pass_through

      set :sessions, true
      set :log, opts[:logger] || Logger.new(STDOUT)
      set :identities, opts[:ids_file].nil? ? {} : YAML::load_file(opts[:ids_file])

      Dir.glob(File.expand_path("auth/**/*.rb", File.dirname(__FILE__))).each do |f|
        require f
        log.debug "discovered auth: #{File.basename(f)[0..-4]}"
      end

      register constantize(opts[:auth])
      log.info "loaded auth: #{opts[:auth]}"
    end

    def constantize(word)
       Passage::Auth::const_get(word.to_s.gsub(/(?:^|_)(.)/) { $1.upcase })
    end

    Sinatra.register Environment
  end
end
