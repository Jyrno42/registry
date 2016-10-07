require 'rails_helper'

describe Pricelist do
  before :all do
  end

  context 'about class' do
  end

  context 'with invalid attribute' do
    before :all do
      @pricelist = Pricelist.new
    end

    it 'should not be valid' do
      @pricelist.valid?
      @pricelist.errors.full_messages.should match_array([
        "Category is missing",
        "Duration is missing",
        "Operation category is missing"
      ])
    end

    it 'should not have creator' do
      @pricelist.creator.should == nil
    end

    it 'should not have updater' do
      @pricelist.updator.should == nil
    end

    it 'should not have any versions' do
      @pricelist.versions.should == []
    end

    it 'should not have name' do
      @pricelist.name.should == ' '
    end
  end

  context 'with valid attributes' do
    before :all do
      @pricelist = Fabricate(:pricelist)
    end

    it 'should be valid' do
      @pricelist.valid?
      @pricelist.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @pricelist = Fabricate(:pricelist)
      @pricelist.valid?
      @pricelist.errors.full_messages.should match_array([])
    end

    it 'should have name' do
      @pricelist.name.should == 'create ee'
    end

    it 'should have one version' do
      with_versioning do
        @pricelist.versions.reload.should == []
        @pricelist.price = 11
        @pricelist.save
        @pricelist.errors.full_messages.should match_array([])
        @pricelist.versions.size.should == 1
      end
    end
  end

  it 'should return correct price' do
    Pricelist.pricelist_for('ee', 'create', '1year').should == nil

    Fabricate(:pricelist, {
      category: 'ee',
      operation_category: 'create',
      duration: '1year',
      price: 1.50,
      valid_from: Time.zone.parse('2198-01-01'),
      valid_to: Time.zone.parse('2199-01-01')
    })

    Pricelist.pricelist_for('ee', 'create', '1year').should == nil

    Fabricate(:pricelist, {
      category: 'ee',
      operation_category: 'create',
      duration: '1year',
      price: 1.50,
      valid_from: Time.zone.parse('2015-01-01'),
      valid_to: nil
    })

    Pricelist.pricelist_for('ee', 'create', '1year').price.amount.should == 1.50

    # To run this tes we need positioning
    # Fabricate(:pricelist, {
    #   category: 'ee',
    #   operation_category: 'create',
    #   duration: '1year',
    #   price: 1.30,
    #   valid_from: Time.zone.parse('2015-01-01'),
    #   valid_to: Time.zone.parse('2999-01-01')
    # })
    # Pricelist.pricelist_for('ee', 'create', '1year').price.amount.should == 1.30

    # Fabricate.create(:pricelist, {
    #   category: 'ee',
    #   operation_category: 'create',
    #   duration: '1year',
    #   price: 1.20,
    #   valid_from: Time.zone.parse('2015-06-01'),
    #   valid_to: Time.zone.parse('2999-01-01')
    # })
    # Pricelist.pricelist_for('ee', 'create', '1year').price.amount.should == 1.20

    # Fabricate.create(:pricelist, {
    #   category: 'ee',
    #   operation_category: 'create',
    #   duration: '1year',
    #   price: 1.10,
    #   valid_from: Time.zone.parse('2014-01-01'),
    #   valid_to: Time.zone.parse('2999-01-01')
    # })
    # Pricelist.pricelist_for('ee', 'create', '1year').price.amount.should == 1.20

    Fabricate.create(:pricelist, {
      category: 'ee',
      operation_category: 'create',
      duration: '1year',
      price: 1.10,
      valid_from: Time.zone.parse('2999-02-01'),
      valid_to: Time.zone.parse('2999-01-01')
    })

    Pricelist.pricelist_for('ee', 'create', '1year').price.amount.should == 1.50

    Fabricate.create(:pricelist, {
      category: 'ee',
      operation_category: 'create',
      duration: '1year',
      price: 1.10,
      valid_from: Time.zone.parse('2015-06-02'),
      valid_to: nil
    })

    Pricelist.pricelist_for('ee', 'create', '1year').price.amount.should == 1.10

    Fabricate.create(:pricelist, {
      category: 'ee',
      operation_category: 'create',
      duration: '1year',
      price: 1.10,
      valid_from: Time.zone.parse('2015-07-01'),
      valid_to: Time.zone.parse('2999-01-01')
    })

    Pricelist.pricelist_for('ee', 'create', '1year').price.amount.should == 1.10

    Fabricate.create(:pricelist, {
      category: 'ee',
      operation_category: 'create',
      duration: '1year',
      price: 2.10,
      valid_from: Time.zone.now.to_date,
      valid_to: Time.zone.now.to_date
    })

    Pricelist.pricelist_for('ee', 'create', '1year').price.amount.should == 2.10

    Fabricate.create(:pricelist, {
      category: 'ee',
      operation_category: 'create',
      duration: '2years',
      price: 1.20,
      valid_from: Time.zone.parse('2015-07-01'),
      valid_to: Time.zone.parse('2999-01-01')
    })

    Pricelist.pricelist_for('ee', 'create', '2years').price.amount.should == 1.20
  end
end
