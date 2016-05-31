class Visitor
  include NonPersistedModel

  attribute :anonymized_name, String
  attribute :allowed, Boolean
end
