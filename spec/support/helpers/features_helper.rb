module FeaturesHelper
  def enter_prisoner_information(options = {})
    options = {
      first_name: 'Oscar',
      last_name: 'Wilde',
      date_of_birth: Date.new(1960, 6, 1),
      number: 'A1410AE',
      prison_name: 'Leicester'
    }.merge(options)

    fill_in 'Prisoner first name', with: options.fetch(:first_name)
    fill_in 'Prisoner last name', with: options.fetch(:last_name)
    fill_in 'Day', with: options.fetch(:date_of_birth).mday
    fill_in 'Month', with: options.fetch(:date_of_birth).month
    fill_in 'Year', with: options.fetch(:date_of_birth).year
    fill_in 'Prisoner number', with: options.fetch(:number)
    select_prison options.fetch(:prison_name)
  end

  def enter_visitor_information(options = {})
    options = {
      first_name: 'Ada',
      last_name: 'Lovelace',
      date_of_birth: Date.new(1970, 11, 30),
      prison_name: 'Reading Gaol',
      email_address: 'user@test.example.com',
      phone_no: '07771232323',
      index: 0
    }.merge(options)

    index = options.fetch(:index)

    within "#visitor-#{index}" do
      fill_in 'First name', with: options.fetch(:first_name)
      fill_in 'Last name', with: options.fetch(:last_name)

      if index.zero?
        fill_in 'Email address', with: options.fetch(:email_address)
        fill_in 'Phone number', with: options.fetch(:phone_no)
      end

      fill_in 'Day', with: options.fetch(:date_of_birth).mday
      fill_in 'Month', with: options.fetch(:date_of_birth).month
      fill_in 'Year', with: options.fetch(:date_of_birth).year
    end
  end

  def select_first_available_date
    first("table.booking-calendar td.available").click
  end

  def select_first_available_slot
    first('#js-slotAvailability input[type="radio"]', visible: false).click
  end

  def select_prison(name)
    field = find('#prisoner_step_prison_id')
    field.set(name)
    field.native.send_keys(:return)
  end

  def check_yes_i_want_to_cancel
    find("#confirmed", visible: false).click
  end
end
