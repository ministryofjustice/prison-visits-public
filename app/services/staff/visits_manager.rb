class Staff::VisitsManager
  ParameterError = Class.new(StandardError)

  # class << self
  def create(params)
    check_params(params)
    @vsip_slots = {}
    prison = Staff::Prison.find(params[:prison_id])
    if prison.estate.vsip_supported && Rails.configuration.use_vsip
      @vsip_slots = VsipVisitSessions.get_sessions(prison.estate.nomis_id, prisoner_step(params).number).keys
      if @vsip_slots == [:vsip_api_failed]
        prison.vsip_failed = true
        @vsip_slots = {}
      end
    end

    fail_if_invalid('prisoner', prisoner_step(params))
    fail_if_invalid('visitors', visitors_step(params))
    fail_if_invalid('slot_options', slots_step(params))
    @visit = Staff::BookingRequestCreator.new.create!(
      @prisoner_step, @visitors_step, @slots_step, I18n.locale
    )
  end

  def destroy(human_id)
    @visit = Staff::Visit.where(human_id:).first
    return(@visit) unless @visit

    if VisitorCancellationResponse.new(visit: @visit).visitor_can_cancel?
      VisitorCancellationResponse.new(visit: @visit).cancel!
    elsif VisitorWithdrawalResponse.new(visit: @visit).visitor_can_withdraw?
      VisitorWithdrawalResponse.new(visit: @visit).withdraw!
    end
    @visit.visit_state_changes.last.update!(creator_type: :Visitor)
    @visit
  end

private

  def check_params(params)
    fail ParameterError, 'Missing parameter: contact_email_address' if params[:contact_email_address].nil?
  end

  def fail_if_invalid(param, step)
    p :rwx1
    p param
    p step
    p step.valid?
    unless step.valid?
      fail ParameterError,
           "#{param} (#{step.errors.full_messages.join(', ')})"
    end
  end

  def prison(prison_id)
    @prison = Staff::Prison.find(prison_id)
  end

  def prisoner_step(params)
    @prisoner_step = Staff::PrisonerStep.new(params[:prisoner].merge(prison_id: params[:prison_id]))
  end

  def visitors_step(params)
    @visitors_step = Staff::VisitorsStep.new(
      email_address: params[:contact_email_address],
      phone_no: params[:contact_phone_no],
      visitors: visitors(params[:visitors]),
      prison: prison(params[:prison_id])
    )
  end

  def slots_step(params)
    check_slots(params[:slot_options])
    @slots_step = Staff::SlotsStep.new(
      option_0: params[:slot_options][0], # We expect at least 1 slot
      option_1: params[:slot_options][1],
      option_2: params[:slot_options][2],
      prison: prison(params[:prison_id]),
      vsip_slots: @vsip_slots
    )
  end

  def visitors(visitors)
    @visitors = visitors.map { |v| Staff::Visitor.new(v) }
  end

  def check_slots(slots)
    @slots = slots.tap do |obj|
      unless obj.is_a?(Array) && obj.size >= 1
        fail ParameterError, 'slot_options must contain >= slot'
      end
    end
  end
end
