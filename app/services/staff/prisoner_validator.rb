class Staff::PrisonerValidator
  class << self
    def validate(noms_id, date)
      checker = Staff::ApiPrisonerChecker.new(noms_id:, date_of_birth: date)

      if checker.valid?
        { 'valid' => true }
      else
        { 'valid' => false, 'errors' => [checker.error] }
      end
    end
  end
end
