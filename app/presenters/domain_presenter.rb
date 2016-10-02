class DomainPresenter
  def initialize(domain:, view:)
    @domain = domain
    @view = view
  end

  def on_hold_date
    view.l(domain.on_hold_time, format: :date) if domain.on_hold_time
  end

  def delete_date
    view.l(domain.delete_time, format: :date) if domain.delete_time
  end

  def admin_contact_names
    domain.admin_contact_names.join(', ')
  end

  def tech_contact_names
    domain.tech_contact_names.join(', ')
  end

  def nameserver_names
    domain.nameserver_hostnames.join(', ')
  end

  def to_s
    domain.name
  end

  private

  attr_reader :domain
  attr_reader :view
end
