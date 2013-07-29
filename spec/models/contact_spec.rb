require 'spec_helper'

describe Contact do
  it "has a valid factory" do
    expect(build(:contact)).to be_valid
  end

  it { should validate_presence_of :firstname }
  it { should validate_presence_of :lastname }
  it { should validate_presence_of :email }
  it { should validate_uniqueness_of(:email) }

  it "has three phone numbers" do
    expect(create(:contact).phones.count).to eq 3
  end

  it "returns a contact's full name as a string" do
    contact = build_stubbed(:contact,
      firstname: "Jane", lastname: "Doe")
    expect(contact.name).to eq "Jane Doe"
  end

  describe "filter last name by letter" do
    let(:smith) { create(:contact,
      lastname: 'Smith', email: 'jsmith@example.com') }
    let(:jones) { create(:contact,
      lastname: 'Jones', email: 'tjones@example.com') }
    let(:johnson) { create(:contact,
      lastname: 'Johnson', email: 'jjohnson@example.com') }

    context "matching letters" do
      it "returns a sorted array of results that match" do
        expect(Contact.by_letter("J")).to eq [johnson, jones]
      end
    end

    context "non-matching letters" do
      it "returns a sorted array of results that match" do
        expect(Contact.by_letter("J")).to_not include smith
      end
    end
  end
end