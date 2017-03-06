module PVP
  module Instrumentation
    class MxChecker
      include PVB::Instrumentation::Instrument

      def process
        RequestStore.store[category] = payload[:path].split('/').last
      end

      private

      def category
        payload[:name]
      end
    end
  end
end
