# frozen_string_literal: true

module Facter
  module Resolvers
    class Xen < BaseResolver
      @semaphore = Mutex.new
      @fact_list ||= {}

      XEN_PATH = '/proc/xen/capabilities'

      class << self
        private

        def post_resolve(fact_name)
          @fact_list.fetch(fact_name) { chech_xen_dirs(fact_name) }
        end

        def chech_xen_dirs(fact_name)
          xen_type = 'xen0' if File.exist?('/dev/xen/evtchn')
          xen_type = 'xenu' if !xen_type && (File.exist?('/proc/xen') || File.exist?('/dev/xvda1'))

          @fact_list[:vm] = xen_type
          @fact_list[:privileged] = privileged?

          @fact_list[fact_name]
        end

        def privileged?
          content = Util::FileHelper.safe_read(XEN_PATH, nil)
          content&.strip == 'control_d'
        end
      end
    end
  end
end
