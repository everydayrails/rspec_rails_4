require 'spec_helper'

describe ContactsController do
  let(:admin) { build_stubbed(:admin) }
  let(:user) { build_stubbed(:user) }

  let(:contact) { build_stubbed(:contact, firstname: 'Lawrence', lastname: 'Smith') }
  let(:phones) {
    [
      attributes_for(:phone, phone_type: "home"),
      attributes_for(:phone, phone_type: "office"),
      attributes_for(:phone, phone_type: "mobile")
    ]
  }
  let(:valid_attributes) { attributes_for(:contact) }
  let(:invalid_attributes) { attributes_for(:invalid_contact) }

  before :each do
    Contact.stub(:persisted?).and_return(true)
    Contact.stub(:order).with('lastname, firstname').and_return([contact])
    Contact.stub(:find).with(contact.id.to_s).and_return(contact)
    contact.stub(:save).and_return(true)
  end

  shared_examples("public access to contacts") do
    describe 'GET #index' do
      before :each do
        get :index
      end

      it "populates an array of contacts" do
        expect(assigns(:contacts)).to match_array [contact]
      end

      it "renders the :index view" do
        expect(response).to render_template :index
      end
    end

    describe 'GET #show' do
      before :each do
        Contact.stub(:find).with(contact.id.to_s).and_return(contact)
        get :show, id: contact
      end

      it "assigns the requested contact to @contact" do
        expect(assigns(:contact)).to eq contact
      end

      it "renders the :show template" do
        expect(response).to render_template :show
      end
    end
  end

  shared_examples("full access to contacts") do
    describe 'GET #new' do
      before :each do
        get :new
      end

      it "assigns a new Contact to @contact" do
        expect(assigns(:contact)).to be_a_new(Contact)
      end

      it "assigns a home, office, and mobile phone to the new contact" do
        phones = assigns(:contact).phones.map do |p|
          p.phone_type
        end
        expect(phones).to match_array %w(home office mobile)
      end

      it "renders the :new template" do
        expect(response).to render_template :new
      end
    end

    describe 'GET #edit' do
      it "assigns the requested contact to @contact" do
        get :edit, id: contact
        expect(assigns(:contact)).to eq contact
      end

      it "renders the :edit template" do
        get :edit, id: contact
        expect(response).to render_template :edit
      end
    end

    describe "POST #create" do
      context "with valid attributes" do
        before :each do
          post :create, contact: attributes_for(:contact,
            phones_attributes: phones)
        end

        it "creates a new contact" do
          expect(Contact.exists?(assigns[:contact])).to be_true
        end

        it "redirects to the new contact" do
          expect(response).to redirect_to Contact.last
        end
      end

      context "with invalid attributes" do
        before :each do
          post :create, contact: attributes_for(:invalid_contact)
        end

        it "does not save the new contact" do
          expect(Contact.exists?(contact)).to be_false
        end

        it "re-renders the new method" do
          expect(response).to render_template :new
        end
      end
    end

    describe 'PATCH #update' do
      context "valid attributes" do
        it "located the requested @contact" do
          contact.stub(:update).with(valid_attributes.stringify_keys) { true }
          patch :update, id: contact, contact: valid_attributes
          expect(assigns(:contact)).to eq(contact)
        end

        it "redirects to the updated contact" do
          patch :update, id: contact, contact: attributes_for(:contact)
          expect(response).to redirect_to contact
        end
      end

      context "invalid attributes" do
        before :each do
          contact.stub(:update).with(invalid_attributes.stringify_keys) { false }
          patch :update, id: contact, contact: invalid_attributes
        end

        it "locates the requested @contact" do
          expect(assigns(:contact)).to eq(contact)
        end

        it "does not change @contact's attributes" do
          expect(assigns[:contact]).to_not be_valid
        end

        it "re-renders the edit method" do
          expect(response).to render_template :edit
        end
      end
    end

    describe 'DELETE destroy' do
      before :each do
        contact.stub(:destroy).and_return(true)
        delete :destroy, id: contact
      end

      it "deletes the contact" do
        expect(Contact.exists?(contact)).to be_false
      end

      it "redirects to contacts#index" do
        expect(response).to redirect_to contacts_url
      end
    end
  end

  describe "admin access" do
    before :each do
      controller.stub(:current_user).and_return(admin)
    end

    it_behaves_like "public access to contacts"
    it_behaves_like "full access to contacts"
  end


  describe "user access" do
    before :each do
      controller.stub(:current_user).and_return(user)
    end

    it_behaves_like "public access to contacts"
    it_behaves_like "full access to contacts"
  end


  describe "guest access" do
    it_behaves_like "public access to contacts"

    describe 'GET #new' do
      it "requires login" do
        get :new
        expect(response).to require_login
      end
    end

    describe "POST #create" do
      it "requires login" do
        post :create, contact: attributes_for(:contact)
        expect(response).to require_login
      end
    end

    describe 'PATCH #update' do
      it "requires login" do
        patch :update, id: contact, contact: attributes_for(:contact)
        expect(response).to require_login
      end
    end

    describe 'DELETE #destroy' do
      it "requires login" do
        delete :destroy, id: contact
        expect(response).to require_login
      end
    end
  end
end
