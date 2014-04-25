require 'spec_helper'

describe Phone do
  it { should validate_uniqueness_of(:phone).scoped_to(:contact_id) }

  it "does not allow duplicate phone numbers per contact" do
    contact = create(:contact)
    create(:home_phone,
      contact: contact,
      phone: '785-555-1234')
    mobile_phone = build(:mobile_phone,
      contact: contact,
      phone: '785-555-1234')
    expect(mobile_phone.errors_on(:phone).size).to eq(1)
  end

  it "does not allow duplicate phone numbers per contact (collection_matcher)" do
    contact = create(:contact)
    create(:home_phone,
      contact: contact,
      phone: '785-555-1234')
    mobile_phone = build(:mobile_phone,
      contact: contact,
      phone: '785-555-1234')
      expect(mobile_phone).to have(1).errors_on(:phone)
  end

  it "allows two contacts to share a phone number" do
    create(:home_phone,
      phone: "785-555-1234")
    expect(build_stubbed(:home_phone, phone: "785-555-1234")).to be_valid
  end
end