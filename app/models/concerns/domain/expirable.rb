module Concerns::Domain::Expirable
  extend ActiveSupport::Concern

  def expired?
    statuses.include?(DomainStatus::EXPIRED)
  end

  def expirable?
    return false if valid_to > Time.zone.now

    if expired? && outzone_at.present? && delete_at.present?
      return false
    end

    true
  end
end
