class DomainExpirationEmailJob < ActiveJob::Base
  queue_as :default

  def perform(domain_id)
    domain = Domain.find(domain_id)
  end
end
