require 'spec_helper'

describe ContactsController do
  before :each do
    @contact = create(:contact, firstname: 'Lawrence', lastname: 'Smith')
  end

  shared_examples("public access to contacts") do
    describe 'GET #index' do
      it "populates an array of contacts" do
        get :index
        expect(assigns(:contacts)).to match_array [@contact]
      end

      it "renders the :index view" do
        get :index
        expect(response).to render_template :index
      end
    end

    describe 'GET #show' do
      it "assigns the requested contact to @contact" do
        get :show, id: @contact
        expect(assigns(:contact)).to eq @contact
      end

      it "renders the :show template" do
        get :show, id: @contact
        expect(response).to render_template :show
      end
    end
  end

  shared_examples("full access to contacts") do
    describe 'GET #new' do
      it "assigns a new Contact to @contact" do
        get :new
        expect(assigns(:contact)).to be_a_new(Contact)
      end

      it "assigns a home, office, and mobile phone to the new contact" do
        get :new
        phones = assigns(:contact).phones.map do |p|
          p.phone_type
        end
        expect(phones).to match_array %w(home office mobile)
      end

      it "renders the :new template" do
        get :new
        expect(response).to render_template :new
      end
    end

    describe 'GET #edit' do
      it "assigns the requested contact to @contact" do
        get :edit, id: @contact
        expect(assigns(:contact)).to eq @contact
      end

      it "renders the :edit template" do
        get :edit, id: @contact
        expect(response).to render_template :edit
      end
    end

    describe "POST #create" do
      before :each do
        @phones = [
          attributes_for(:phone, phone_type: "home"),
          attributes_for(:phone, phone_type: "office"),
          attributes_for(:phone, phone_type: "mobile")
        ]
      end

      context "with valid attributes" do
        it "creates a new contact" do
          expect{
            post :create, contact: attributes_for(:contact,
              phones_attributes: @phones)
          }.to change(Contact,:count).by(1)
        end

        it "redirects to the new contact" do
          post :create, contact: attributes_for(:contact,
            phones_attributes: @phones)
          expect(response).to redirect_to Contact.last
        end
      end

      context "with invalid attributes" do
        it "does not save the new contact" do
          expect{
            post :create, contact: attributes_for(:invalid_contact)
          }.to_not change(Contact,:count)
        end

        it "re-renders the new method" do
          post :create, contact: attributes_for(:invalid_contact)
          expect(response).to render_template :new
        end
      end
    end

    describe 'PATCH #update' do
      context "valid attributes" do
        it "located the requested @contact" do
          patch :update, id: @contact, contact: attributes_for(:contact)
          expect(assigns(:contact)).to eq(@contact)
        end

        it "changes @contact's attributes" do
          patch :update, id: @contact,
            contact: attributes_for(:contact,
              firstname: "Larry", lastname: "Smith")
          @contact.reload
          expect(@contact.firstname).to eq("Larry")
          expect(@contact.lastname).to eq("Smith")
        end

        it "redirects to the updated contact" do
          patch :update, id: @contact, contact: attributes_for(:contact)
          expect(response).to redirect_to @contact
        end
      end

      context "invalid attributes" do
        it "locates the requested @contact" do
          patch :update, id: @contact, contact: attributes_for(:invalid_contact)
          expect(assigns(:contact)).to eq(@contact)
        end

        it "does not change @contact's attributes" do
          patch :update, id: @contact,
            contact: attributes_for(:contact,
              firstname: "Larry", lastname: nil)
          @contact.reload
          expect(@contact.firstname).to_not eq("Larry")
          expect(@contact.lastname).to eq("Smith")
        end

        it "re-renders the edit method" do
          patch :update, id: @contact, contact: attributes_for(:invalid_contact)
          expect(response).to render_template :edit
        end
      end
    end

    describe 'DELETE destroy' do
      it "deletes the contact" do
        expect{
          delete :destroy, id: @contact
        }.to change(Contact,:count).by(-1)
      end

      it "redirects to contacts#index" do
        delete :destroy, id: @contact
        expect(response).to redirect_to contacts_url
      end
    end
  end

  describe "admin access" do
    before :each do
      set_user_session(create(:admin))
    end

    it_behaves_like "public access to contacts"
    it_behaves_like "full access to contacts"
  end


  describe "user access" do
    before :each do
      set_user_session(create(:user))
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
        patch :update, id: @contact, contact: attributes_for(:contact)
        expect(response).to require_login
      end
    end

    describe 'DELETE #destroy' do
      it "requires login" do
        delete :destroy, id: @contact
        expect(response).to require_login
      end
    end
  end
end
