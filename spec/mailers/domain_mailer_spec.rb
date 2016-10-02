require 'rails_helper'

describe DomainMailer do
  before :all do
    Fabricate(:zonefile_setting, origin: 'ee')
  end

  describe 'pending update request for an old registrant when delivery turned off' do
    before :all do
      @registrant = Fabricate(:registrant, email: 'test@example.com')
      @domain = Fabricate(:domain, registrant: @registrant)
      # @mail = DomainMailer.pending_update_request_for_old_registrant(@domain.id, @registrant.id, @domain.deliver_emails).deliver!
      @mail = DomainMailer.pending_update_request_for_old_registrant(DomainMailModel.new(@domain).send(:pending_update_request_for_old_registrant)).deliver!
    end

    it 'should not render email subject' do
      @mail == nil
    end

    # it 'should not have sender email' do
    #   @mail.from.should == nil
    # end

    # it 'should not have reveiver email' do
    #   @mail.to.should == nil
    # end

    # it 'should not render body' do
    #   @mail.body.should == ''
    # end
  end

  describe 'pending update request for an old registrant' do
    before :all do
      @registrant = Fabricate(:registrant, email: 'test@example.com')
      @new_registrant = Fabricate(:registrant, email: 'test@example.org')
      @domain = Fabricate(:domain, registrant: @registrant)
      @domain.deliver_emails = true
      @domain.registrant_verification_token = '123'
      @domain.registrant_verification_asked_at = Time.zone.now
      @domain.registrant = @new_registrant
      # @mail = DomainMailer.pending_update_request_for_old_registrant(@domain.id, @registrant.id, @domain.deliver_emails).deliver!
      @mail = DomainMailer.pending_update_request_for_old_registrant(DomainMailModel.new(@domain).send(:pending_update_request_for_old_registrant)).deliver!
    end

    it 'should render email subject' do
      @mail.subject.should =~ /registreerija vahetuseks/
    end

    it 'should have sender email' do
      @mail.from.should == ["noreply@internet.ee"]
    end

    it 'should send confirm email to old registrant email' do
      @mail.to.should == ["test@example.com"]
    end

    it 'should render body' do
      @mail.body.encoded.should =~ /Registrisse laekus taotlus domeeni/
    end

    it 'should render verification url' do
      @mail.body.encoded.should =~ %r{registrant\/domain_update_confirms}
    end
  end

  # describe 'pending update notification for a new registrant' do
  #   before :all do
  #     @registrant = Fabricate(:registrant, email: 'old@example.com')
  #     @new_registrant = Fabricate(:registrant, email: 'new@example.org')
  #     @domain = Fabricate(:domain, registrant: @registrant)
  #     @domain.deliver_emails = true
  #     @domain.registrant_verification_token = '123'
  #     @domain.registrant_verification_asked_at = Time.zone.now
  #     @domain.registrant = @new_registrant
  #     @mail = DomainMailer.pending_update_notification_for_new_registrant(@domain.id, @registrant.id, @domain.deliver_emails).deliver!
  #   end

  #   it 'should render email subject' do
  #     @mail.subject.should =~ /protseduur on algatatud/
  #   end

  #   it 'should have sender email' do
  #     @mail.from.should == ["noreply@internet.ee"]
  #   end

  #   it 'should send confirm email to new registrant email' do
  #     @mail.to.should == ["new@example.org"]
  #   end

  #   it 'should render body' do
  #     @mail.body.encoded.should =~ /vahendusel on algatatud/
  #   end
  # end

  describe 'pending update notification for a new registrant' do
    before :all do
      @registrant = Fabricate(:registrant, email: 'old@example.com')
      @new_registrant = Fabricate(:registrant, email: 'new@example.org')
      @domain = Fabricate(:domain, registrant: @registrant)
      @domain.deliver_emails = true
      @domain.registrant_verification_token = '123'
      @domain.registrant_verification_asked_at = Time.zone.now
      @domain.registrant = @new_registrant
      # @mail = DomainMailer.pending_update_notification_for_new_registrant(@domain.id, @registrant.id, @domain.deliver_emails).deliver!
      @mail = DomainMailer.pending_update_notification_for_new_registrant(DomainMailModel.new(@domain).send(:pending_update_notification_for_new_registrant)).deliver!
    end

    it 'should render email subject' do
      @mail.subject.should =~ /protseduur on algatatud/
    end

    it 'should have sender email' do
      @mail.from.should == ["noreply@internet.ee"]
    end

    it 'should send confirm email to new registrant email' do
      @mail.to.should == ["new@example.org"]
    end

    it 'should render body' do
      @mail.body.encoded.should =~ /vahendusel on algatatud/
    end
  end

  describe 'pending update rejected notification for a new registrant' do
    before :all do
      @registrant = Fabricate(:registrant, email: 'old@example.com')
      @new_registrant = Fabricate(:registrant, email: 'new@example.org')
      @domain = Fabricate(:domain, registrant: @registrant)
      @domain.deliver_emails = true
      @domain.pending_json['new_registrant_email'] = 'new@example.org'
      @domain.pending_json['new_registrant_name']  = 'test name'
      @domain.save
      # @mail = DomainMailer.pending_update_rejected_notification_for_new_registrant(@domain.id).deliver!
      @mail = DomainMailer.pending_update_rejected_notification_for_new_registrant(DomainMailModel.new(@domain).send(:pending_update_rejected_notification_for_new_registrant)).deliver!
    end

    it 'should render email subject' do
      @mail.subject.should =~ /vahetuse taotlus tagasi lükatud/
    end

    it 'should have sender email' do
      @mail.from.should == ["noreply@internet.ee"]
    end

    it 'should send confirm email to new registrant email' do
      @mail.to.should == ["new@example.org"]
    end

    it 'should render body' do
      @mail.body.encoded.should =~ /Registrant change/
      @mail.body.encoded.should =~ /was rejected/
    end
  end

  describe 'registrant updated notification for a new registrant' do
    before :all do
      @registrant = Fabricate(:registrant, email: 'test@example.com')
      @domain = Fabricate(:domain, registrant: @registrant)
      @domain.deliver_emails = true
      @mail = DomainMailer.registrant_updated_notification_for_new_registrant(@domain.id, @registrant.id, @registrant.id, @domain.deliver_emails).deliver!
    end

    it 'should render email subject' do
      @mail.subject.should =~ /registreerija vahetus teostatud/
    end

    it 'should have sender email' do
      @mail.from.should == ["noreply@internet.ee"]
    end

    it 'should send to registrant email' do
      @mail.to.should == ["test@example.com"]
    end

    it 'should render body' do
      @mail.body.encoded.should =~ /registreerija vahetuse taotlus on kinnitatud/
    end
  end

  describe 'registrant updated notification for a old registrant' do
    before :all do
      @registrant = Fabricate(:registrant, email: 'test@example.com')
      @domain = Fabricate(:domain, registrant: @registrant)
      @domain.deliver_emails = true
      @mail = DomainMailer.registrant_updated_notification_for_old_registrant(@domain.id, @registrant.id, @registrant.id, @domain.deliver_emails).deliver!
    end

    it 'should render email subject' do
      @mail.subject.should =~ /registreerija vahetus teostatud/
    end

    it 'should have sender email' do
      @mail.from.should == ["noreply@internet.ee"]
    end

    it 'should send to registrant email' do
      @mail.to.should == ["test@example.com"]
    end

    it 'should render body' do
      @mail.body.encoded.should =~ /registreerija vahetuse taotlus on kinnitatud/
    end
  end

  describe 'domain pending delete notification when delivery turned off' do
    before :all do
      @registrant = Fabricate(:registrant, email: 'test@example.com')
      @domain = Fabricate(:domain, registrant: @registrant)
      @mail = DomainMailer.pending_deleted(@domain.id, @registrant.id, @domain.deliver_emails).deliver!
    end

    it 'should not send email' do
      @mail == nil
    end

    # it 'should not render email subject' do
    #   @mail.subject.should == nil
    # end

    # it 'should not have sender email' do
    #   @mail.from.should == nil
    # end

    # it 'should not have reveiver email' do
    #   @mail.to.should == nil
    # end

    # it 'should not render body' do
    #   binding.pry
    #   @mail.body.should == ''
    # end
  end

  describe 'email pending delete notification' do
    before :all do
      @registrant = Fabricate(:registrant, email: 'test@example.com')
      @domain = Fabricate(:domain, name: 'delete-pending.ee', registrant: @registrant)
      @domain.deliver_emails = true
      @domain.registrant_verification_token = '123'
      @domain.registrant_verification_asked_at = Time.zone.now
      @domain.save
      @mail = DomainMailer.pending_deleted(@domain.id, @registrant.id, @domain.deliver_emails).deliver!
    end

    it 'should render email subject' do
      @mail.subject.should =~ /kustutamiseks .ee registrist/
    end

    it 'should have sender email' do
      @mail.from.should == ["noreply@internet.ee"]
    end

    it 'should send confirm email to old registrant email' do
      @mail.to.should == ["test@example.com"]
    end

    it 'should render body' do
      @mail.body.encoded.should =~ /Registrisse laekus taotlus domeeni delete-pending.ee kustutamiseks/
    end

    it 'should render verification url' do
      @mail.body.encoded.should =~ %r{registrant\/domain_delete_con} # somehowe delete_confirms not matching
    end
  end

  describe 'pending delete rejected notification' do
    before :all do
      @registrant = Fabricate(:registrant, email: 'test@example.com')
      @domain = Fabricate(:domain, name: 'delete-pending-rejected.ee', registrant: @registrant)
      @domain.deliver_emails = true
      @domain.registrant_verification_token = '123'
      @domain.registrant_verification_asked_at = Time.zone.now
      @domain.save
      @mail = DomainMailer.pending_delete_rejected_notification(@domain.id, @domain.deliver_emails).deliver!
    end

    it 'should render email subject' do
      @mail.subject.should =~ /kustutamise taotlus tagasi lükatud/
    end

    it 'should have sender email' do
      @mail.from.should == ["noreply@internet.ee"]
    end

    it 'should send confirm email to old registrant email' do
      @mail.to.should == ["test@example.com"]
    end

    it 'should render body' do
      @mail.body.encoded.should =~ /deletion was rejected/
    end
  end

  describe 'pending delete expired notification' do
    before :all do
      @registrant = Fabricate(:registrant, email: 'test@example.com')
      @domain = Fabricate(:domain, name: 'pending-delete-expired.ee', registrant: @registrant)
      @domain.deliver_emails = true
      @domain.registrant_verification_token = '123'
      @domain.registrant_verification_asked_at = Time.zone.now
      @mail = DomainMailer.pending_delete_expired_notification(@domain.id, @domain.deliver_emails).deliver!
    end

    it 'should render email subject' do
      @mail.subject.should =~ /deletion cancelled/
    end

    it 'should have sender email' do
      @mail.from.should == ["noreply@internet.ee"]
    end

    it 'should send confirm email to old registrant email' do
      @mail.to.should == ["test@example.com"]
    end

    it 'should render body' do
      @mail.body.encoded.should =~ /deletion was not approved in time/
    end
  end

  describe 'pending delete rejected notification' do
    before :all do
      @registrant = Fabricate(:registrant, email: 'test@example.com')
      @domain = Fabricate(:domain, name: 'delete-confirmed.ee', registrant: @registrant)
      @domain.deliver_emails = true
      @domain.registrant_verification_token = '123'
      @domain.registrant_verification_asked_at = Time.zone.now
      @mail = DomainMailer.delete_confirmation(@domain.id, @domain.deliver_emails).deliver!
    end

    it 'should render email subject' do
      @mail.subject.should =~ /deleted/
    end

    it 'should have sender email' do
      @mail.from.should == ["noreply@internet.ee"]
    end

    it 'should send confirm email to old registrant email' do
      @mail.to.should == ["test@example.com"]
    end

    it 'should render body' do
      @mail.body.encoded.should =~ /suspended and will be deleted/
    end
  end
end

RSpec.describe DomainMailer do
  describe '#expiration' do
    let(:domain) { instance_double(Domain, on_hold_date: Time.zone.parse('05.07.2010'), delete_date: Time.zone.parse('05.07.2010')) }
    subject(:message) { DomainMailer.expiration(domain) }

    it 'has valid sender' do
      message.deliver_now
      expect(message.from).to eq(['noreply@internet.ee'])
    end

    it 'has valid recipient' do
      expect(domain).to receive(:registrant_email).and_return('test@test.com')
      message.deliver_now
      expect(message.to).to eq(['test@test.com'])
    end

    it 'has valid subject' do
      expect(domain).to receive(:name).and_return('test.com')
      message.deliver_now
      expect(message.subject).to eq('The test.com domain has expired')
    end

    it 'sends message' do
      expect { message.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
