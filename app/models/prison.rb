class Prison
  include NonPersistedModel

  MAX_VISITORS = 6
  MAX_ADULTS = 3
  MIN_ADULTS = 1

  attribute :id, String
  attribute :name, String
  attribute :address, String
  attribute :postcode, String
  attribute :email_address, String
  attribute :phone_no, String
  attribute :prison_finder_url, String
  attribute :adult_age, Integer, default: 18 # Varies for some prisons

  def self.find_by_id(id)
    result = Rails.configuration.api.get("/prisons/#{id}")
    Prison.new(result['prison'])
  end

  def self.all
    result = Rails.configuration.api.get('/prisons')
    result['prisons'].map { |params| Prison.new(params) }
  end

  def validate_visitor_ages_on(target, field, ages)
    adults, _children = ages.partition { |a| adult?(a) }.map(&:length)
    if adults > MAX_ADULTS
      target.errors.add field, :too_many_adults, max: MAX_ADULTS, age: adult_age
    elsif adults < MIN_ADULTS
      target.errors.add field, :too_few_adults, min: MIN_ADULTS, age: adult_age
    end
  end

  def last_bookable_date(_today = Time.zone.today)
    available_slots.sort.last.to_date
  end

  def bookable_date?(requested_date = Time.zone.today)
    available_slots.any? { |s| s.to_date == requested_date }
  end

  def available_slots(_today = Time.zone.today)
    @available_slots ||= begin
      api_response = Rails.configuration.api.get('/slots', prison_id: id)
      api_response['slots'].map { |s| ConcreteSlot.parse(s) }
    end
  end

private

  def adult?(age)
    age >= adult_age
  end
end
