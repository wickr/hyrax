RSpec.describe 'hyrax/collections/_form.html.erb', type: :view do
  let(:collection) { Collection.new }
  let(:collection_form) { Hyrax::Forms::CollectionForm.new(collection, double, double) }
  let(:persisted) { false }
  let(:relationships) { false }
  let(:sharing) { false }
  let(:visibility) { false }
  let(:discovery) { false }
  let(:workflow) { false }

  before do
    assign(:form, collection_form)
    allow(collection_form).to receive(:persisted?).and_return(persisted)
    allow(collection_form).to receive(:relationships?).and_return(relationships)
    allow(collection_form).to receive(:sharing?).and_return(sharing)
    allow(collection_form).to receive(:visibility?).and_return(visibility)
    allow(collection_form).to receive(:discovery?).and_return(discovery)
    allow(collection_form).to receive(:workflow?).and_return(workflow)
    assign(:collection, collection)
    # Stub route because view specs don't handle engine routes
    allow(view).to receive(:collections_path).and_return("/collections")
    allow(view).to receive(:t).with(anything) { |value| value }
    allow(controller).to receive(:current_user).and_return(stub_model(User))
    render
  end

  context 'new' do
    describe 'tabs' do
      it do
        expect(rendered).to have_link('.tabs.description')
        expect(rendered).not_to have_link('.tabs.branding')
        expect(rendered).not_to have_link('.tabs.relationships')
        expect(rendered).not_to have_link('.tabs.sharing')
        expect(rendered).not_to have_link('.tabs.visibility')
        expect(rendered).not_to have_link('.tabs.discovery')
        expect(rendered).not_to have_link('.tabs.workflow')
      end
      context 'relationships' do
        let(:relationships) { true }

        it { expect(rendered).not_to have_link('.tabs.relationships') }
      end
      context 'sharing' do
        let(:sharing) { true }

        it { expect(rendered).not_to have_link('.tabs.sharing') }
      end
      context 'visibility' do
        let(:visibility) { true }

        it { expect(rendered).not_to have_link('.tabs.visibility') }
      end
      context 'discovery' do
        let(:discovery) { true }

        it { expect(rendered).not_to have_link('.tabs.discovery') }
      end
      context 'workflow' do
        let(:workflow) { true }

        it { expect(rendered).not_to have_link('.tabs.workflow') }
      end
    end
    describe 'footer' do
      it do
        expect(rendered).to have_selector('input#create_submit')
        expect(rendered).to have_selector("input[value='hyrax.collection.select_form.create']")
        expect(rendered).not_to have_selector('input#update_submit')
        expect(rendered).not_to have_selector("input[value='hyrax.collection.select_form.update']")
        expect(rendered).to have_link('helpers.action.cancel')
      end
    end
  end

  context "edit" do
    let(:persisted) { true }

    describe 'tabs' do
      it do
        expect(rendered).to have_link('.tabs.description')
        expect(rendered).to have_link('.tabs.branding')
        expect(rendered).not_to have_link('.tabs.relationships')
        expect(rendered).not_to have_link('.tabs.sharing')
        expect(rendered).not_to have_link('.tabs.visibility')
        expect(rendered).not_to have_link('.tabs.discovery')
        expect(rendered).not_to have_link('.tabs.workflow')
      end
      context 'relationships' do
        let(:relationships) { true }

        it { expect(rendered).to have_link('.tabs.relationships') }
      end
      context 'sharing' do
        let(:sharing) { true }

        it { expect(rendered).to have_link('.tabs.sharing') }
      end
      context 'visibility' do
        let(:visibility) { true }

        it { expect(rendered).to have_link('.tabs.visibility') }
      end
      context 'discovery' do
        let(:discovery) { true }

        it { expect(rendered).to have_link('.tabs.discovery') }
      end
      context 'workflow' do
        let(:workflow) { true }

        it { expect(rendered).to have_link('.tabs.workflow') }
      end
    end
    describe 'footer' do
      it do
        expect(rendered).not_to have_selector('input#create_submit')
        expect(rendered).not_to have_selector("input[value='hyrax.collection.select_form.create']")
        expect(rendered).to have_selector('input#update_submit')
        expect(rendered).to have_selector("input[value='hyrax.collection.select_form.update']")
        expect(rendered).to have_link('helpers.action.cancel')
      end
    end
  end
end
