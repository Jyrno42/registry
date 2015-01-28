class Nameserver < ActiveRecord::Base
  include Versions # version/nameserver_version.rb
  include EppErrors

  belongs_to :registrar
  belongs_to :domain

  # rubocop: disable Metrics/LineLength
  validates :hostname, format: { with: /\A(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\-]*[A-Za-z0-9])\z/ }
  validates :ipv4, format: { with: /\A(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\z/, allow_blank: true }
  validates :ipv6, format: { with: /(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]).){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))/, allow_blank: true }
  # rubocop: enable Metrics/LineLength

  # TODO: remove old
  # after_destroy :domain_version

  before_validation :normalize_attributes

  delegate :name, to: :domain, prefix: true

  def epp_code_map
    {
      '2302' => [
        [:hostname, :taken, { value: { obj: 'hostAttr', val: hostname } }]
      ],
      '2005' => [
        [:hostname, :invalid, { value: { obj: 'hostAttr', val: hostname } }],
        [:ipv4, :invalid, { value: { obj: 'hostAddr', val: ipv4 } }],
        [:ipv6, :invalid, { value: { obj: 'hostAddr', val: ipv6 } }]
      ],
      '2306' => [
        [:ipv4, :blank]
      ]
    }
  end

  # TODO: remove old
  # def snapshot
    # {
      # hostname: hostname,
      # ipv4: ipv4,
      # ipv6: ipv6
    # }
  # end

  def normalize_attributes
    self.hostname = hostname.try(:strip).try(:downcase)
    self.ipv4 = ipv4.try(:strip)
    self.ipv6 = ipv6.try(:strip).try(:upcase)
  end

  # TODO: remove old
  # def domain_version
    # domain.create_version if domain
  # end

  def to_s
    hostname
  end
end
