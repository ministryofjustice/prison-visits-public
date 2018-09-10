module CalendarHelper
  def each_day_of_week(time = Time.zone.today)
    first = time.beginning_of_week(:sunday)
    7.times.each do |offset|
      yield(first + offset.day)
    end
  end

  def weeks(slots)
    begin_on = Time.zone.today.beginning_of_week
    end_on = slots.last_bookable_date.end_of_month.end_of_week
    (begin_on..end_on).group_by(&:beginning_of_week).values
  end

  def calendar_day(date, bookable)
    day = content_tag(
      :span, I18n.l(date, format: :day_of_month),
      class: 'BookingCalendar-day'
    )
    return day if bookable == false

    content_tag(
      :a, day,
      class: 'BookingCalendar-dateLink', 'data-date': date.iso8601,
      href: "#date-#{date.iso8601}"
    )
  end

  def bookable(slots, day)
    slots.bookable_date?(day) ? 'bookable' : 'unavailable'
  end

  def slot_options_reflecting_existing_selections(slots_step, reviewing)
    slots_step.slot_constraints.map do |slot|
      [
        format_slot_begin_time_for_public(slot),
        slot.iso8601,
        selection_options(slots_step, slot, reviewing)
      ]
    end
  end

  def selection_options(slots_step, slot, reviewing)
    if slots_step.options.include?(slot.iso8601)
      return slot_selected_options(reviewing)
    end

    slot_constraints = slots_step.slot_constraints
    unless slot_constraints.bookable_slot?(slot)
      return unavailable_reason_options(slot_constraints, slot)
    end

    {}
  end

  def unavailable_reason_options(slot_constraints, slot)
    reason = slot_constraints.unavailability_reasons(slot).first

    {
      'disabled' => 'disabled',
      'data-message' => I18n.t(reason, scope: %i[booking_requests chosen_options])
    }
  end

  def slot_selected_options(reviewing)
    options = {
      'data-slot-chosen' => true,
      'data-message' => I18n.t('booking_requests.chosen_options.already_chosen')
    }

    options['disabled'] = 'disabled' unless reviewing
    options
  end
end
