# :nocov:
# Ignoring this for coverage as only brought to support testing when moved from staff to public app.  Not used in the
# by the pubic app in requesting a visit, but kept in for future reference.
class BookingResponder
  class Cancel < BookingRequestProcessor
    def process_request(message = nil)
      super do
        visit.cancel!
        visit.cancellation.save!

        template_id = '12969e6f-96b4-40a6-994c-14432e604965'
        cancellation = visit.cancellation.decorate

        @gov_notify_email = GovNotifyEmailer.new
        @gov_notify_email.send_email(visit, template_id, nil, nil, cancellation)

        BookingResponse.successful
      end
    end
  end
end
