module Legacy
  class Domain < Db
    self.table_name = :domain

    belongs_to :object_registry, foreign_key: :id
    belongs_to :object, foreign_key: :id
    belongs_to :nsset, foreign_key: :nsset
    # belongs_to :registrant, foreign_key: :registrant, primary_key: :legacy_id, class_name: '::Contact'

    has_many :object_states, -> { where('valid_to IS NULL') }, foreign_key: :object_id
    has_many :dnskeys, foreign_key: :keysetid, primary_key: :keyset
    has_many :domain_contact_maps, foreign_key: :domainid
    has_many :nsset_contact_maps, foreign_key: :nssetid, primary_key: :nsset
    has_many :domain_histories, foreign_key: :id
  end
end
