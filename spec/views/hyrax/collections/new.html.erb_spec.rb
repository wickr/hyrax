RSpec.describe 'hyrax/collections/new.html.erb', type: :view do
  let(:collection) { stub_model(Collection) }
  let(:collection_type) { stub_model(Hyrax::CollectionType, title: 'Branded Collection') }
  let(:form) { Hyrax::Forms::CollectionForm.new(collection, double, double) }

  before do
    allow(collection).to receive(:collection_type).and_return(collection_type)
    allow(view).to receive(:has_collection_search_parameters?).and_return(false)
    allow(controller).to receive(:current_user).and_return(stub_model(User))
    assign(:collection, collection)
    assign(:form, form)
    stub_template 'hyrax/collections/_form.html.erb' => 'form'

    render
  end

  # it 'displays the page' do
  #   expect(rendered).to have_content 'Actions'
  #   expect(rendered).to have_link 'Add works'
  # end

  it 'page_header should reference collection type' do
    expect(view.content_for(:page_header)).to match(collection_type.title)
  end

  it 'page_title should reference collection type' do
    expect(view.content_for(:page_title)).to match(collection_type.title)
  end
end
