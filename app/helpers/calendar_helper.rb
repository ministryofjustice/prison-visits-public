module CalendarHelper
  def each_day_of_week(time = Time.zone.today)
    first = time.beginning_of_week(:sunday)
    7.times.each do |offset|
      yield(first + offset.day)
    end
  end

  def today?(day)
    day == Time.zone.today
  end

  def future?(day)
    day > Time.zone.today
  end

  def first_day_of_month?(day)
    day.beginning_of_month == day
  end

  def tagged?(day)
    today?(day) || first_day_of_month?(day)
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

  def slot_options_reflecting_existing_selections(slot_step_object)
    existing_selections = slot_step_object.options

    slot_step_object.slot_constraints.map do |s|
      displayed = s.iso8601
      options = existing_selections.include?(displayed) ? chosen_options : {}
      [format_slot_begin_time_for_public(s), displayed, options]
    end
  end

  def chosen_options
    {
      'data-slot-chosen' => true,
      'data-message' => 'Already chosen',
      'disabled' => 'disabled'
    }
  end
end
