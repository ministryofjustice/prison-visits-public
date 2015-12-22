module SmokeTest
  module Steps
    class PrisonBookingConfirmationCopy < BaseStep
      include ImapProcessor

      def validate!
        unless email
          fail 'Could not find prison booking confirmation copy email'
        end
      end

      def complete_step
        # nothing for us to do with this email
      end

    private

      def expected_email_subject
        'COPY of booking confirmation for %s' % [state.prisoner.full_name]
      end
    end
  end
end
