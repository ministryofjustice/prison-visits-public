class BookingRequestCreator
  def create!(prisoner_step, visitors_step, slots_step, locale)
    prisoner = prisoner_step.prisoner_attributes
    visitors = visitors_step.visitors.map(&:attributes)

    params = {
      prison_id: prisoner_step.prison_id,
      prisoner:,
      visitors:,
      contact_email_address: visitors_step.email_address,
      contact_phone_no: visitors_step.phone_no,
      slot_options: [
        slots_step.option_0,
        slots_step.option_1,
        slots_step.option_2
      ],
      locale:
    }

    PrisonVisits::Api.instance.request_visit(**params)
  end
end
