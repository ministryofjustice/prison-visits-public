class Visitor
  include MemoryModel
  include Person

  attribute :anonymized_name, :string
  attribute :allowed, :boolean
  attribute :first_name, :string
  attribute :last_name, :string
  attribute :date_of_birth, :uncoerced_date

  def attributes
    {
      first_name: first_name,
      last_name: last_name,
      date_of_birth: date_of_birth&.to_date
    }
  end
end
