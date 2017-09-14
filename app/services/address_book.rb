class AddressBook
  def initialize(domain)
    @domain = domain
  end

  def no_reply
    "no-reply@#{@domain}"
  end
end
