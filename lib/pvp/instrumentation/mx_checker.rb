module PVP
  module Instrumentation
    class MxChecker
      include PVB::Instrumentation::Instrument

      def process
        ap self
      end

    end
  end
end
