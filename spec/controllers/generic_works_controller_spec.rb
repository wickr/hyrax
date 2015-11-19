require 'spec_helper'

describe CurationConcerns::GenericWorksController do
  let(:user) { create(:user) }

  before { sign_in user }
  routes { Rails.application.routes }

  describe "#new" do
    it "is successful" do
      get :new
      expect(response).to be_successful
      expect(response).to render_template("layouts/sufia-one-column")
      expect(assigns[:curation_concern]).to be_kind_of GenericWork
    end
  end

  describe "#edit" do
    let(:work) { create(:work, user: user) }

    it "is successful" do
      get :edit, id: work
      expect(response).to be_successful
      expect(response).to render_template("layouts/sufia-one-column")
      expect(assigns[:form]).to be_kind_of CurationConcerns::GenericWorkForm
    end
  end
end
