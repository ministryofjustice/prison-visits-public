class PrisonerNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless value =~ /\A[a-z]\d{4}[a-z]{2}\z/i
      record.errors.add(
        attribute,
        I18n.t('activemodel.errors.models.prisoner_step.attributes.number.invalid')
      )
    end
  end
end
