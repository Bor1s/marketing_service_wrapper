require 'spec_helper'

describe MarketingServiceWrapper::Base do
  before :all do
    MarketingServiceWrapper::Base.site = "http://localhost:8080"
  end

  before :each do
  end

  it 'should get companies from mother site' do
    expect { subject }.to_not raise_error
  end

  it 'should get companies from mother site' do
    subject.companies.should_not be_empty
  end

  it 'should get channels for company' do
    company = subject.companies.first
    company.channels.should_not be_empty
  end

  it 'should get opt_ins for company' do
    company = subject.companies.first
    company.opt_ins.should_not be_empty
  end

  it 'should destroy opt_in' do
    MarketingServiceWrapper::Base.restore_test_data
    company = subject.companies.first
    company.opt_ins.first.destroy
    company.opt_ins.count.should eq 2
  end

  it 'should create opt_in for channel' do
    MarketingServiceWrapper::Base.restore_test_data
    company = subject.companies.first
    channel = company.channels.first
    company.opt_ins.first.destroy
    channel.create_opt_in('Frodo', 'Baggins', 'frodo@gmail.com', 12334)
    company.opt_ins.count.should eq 3
  end

  it 'should edit opt_in' do
    company = subject.companies.first
    opt_in = company.opt_ins.first
    opt_in.update('Gandalf', '', 'frodo@gmail.com', 12334)
    company.opt_ins.first.first_name.should eq 'Gandalf'
  end
end
