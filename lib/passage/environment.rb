require 'yaml'
require 'logger'
require 'sinatra/base'
require 'passage/identities'

module Passage
  module Environment
    def configure!(opts)
      opts[:auth] ||= :pass_through

      set :sessions, true
      set :log, opts[:logger] || Logger.new(STDOUT)

      # load identities
      if(opts[:ids_file])
        ids = Identities.new YAML::load_file(opts[:ids_file] ||  ENV['PSG_IDS_FILE'] )
        set :identities, ids
        log.info "loaded #{ids.count} identities from #{opts[:ids_file]}"
      else
        set :identities, {}
        log.info "no identities loaded (free for all)"
      end

      # load auth
      Dir.glob(File.expand_path("auth/**/*.rb", File.dirname(__FILE__))).each do |f|
        require f
        log.debug "discovered auth: #{File.basename(f)[0..-4]}"
      end
      register constantize(opts[:auth] || ENV['PSG_AUTH'])
      log.info "loaded #{opts[:auth] || ENV['PSG_AUTH']} authentication"

    end

    def constantize(word)
       Passage::Auth::const_get(word.to_s.gsub(/(?:^|_)(.)/) { $1.upcase })
    end

    Sinatra.register Environment
  end
end
