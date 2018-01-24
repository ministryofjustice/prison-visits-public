module NonPersistedModel
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Model
    # include ActiveModel::Attributes RAILS 5.2
    include ActiveModelAttributes
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks
  end
end
