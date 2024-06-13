class Staff::VisitorsValidator
  ParameterError = Class.new(StandardError)

  class << self
    def validate(prison_id, lead_date_of_birth, dates_of_birth)
      lead_date_of_birth, dates_of_birth = validate_visitors_parameters(lead_date_of_birth, dates_of_birth)
      prison = Staff::Prison.find(prison_id)

      visitors_group = VisitorsValidation.new(
        prison:,
        lead_date_of_birth:,
        dates_of_birth:
      )

      {
        validation: visitors_response(visitors_group)
      }
    end

  private

    def visitors_response(visitors_group)
      if visitors_group.valid?
        { 'valid' => true }
      else
        { 'valid' => false, errors: visitors_group.error_keys }
      end
    end

    def validate_visitors_parameters(lead_date_of_birth, dates_of_birth)
      dates_of_birth = dates_of_birth.map { |date|
        validate_date(date, :dates_of_birth)
      }

      [lead_date_of_birth, dates_of_birth]
    end

    def validate_date(value, field_name)
      Date.parse(value.to_s)
    rescue ArgumentError
      raise ParameterError, field_name
    end
  end
end
