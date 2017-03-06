module PVP
  module Instrumentation
    class MxChecker
      include PVB::Instrumentation::Instrument

      def process
        PVB::Instrumentation.append_to_log(category => event.duration)
        logger.info(
          format(
            'Validating email address MX record: - %.2fms',
            event.duration
          )
        )
      end

    private

      def category
        event.payload[:category]
      end
    end
  end
end
