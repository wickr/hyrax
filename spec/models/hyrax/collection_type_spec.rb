RSpec.describe Hyrax::CollectionType, type: :model do
  let(:collection_type) { build(:user_collection_type) }

  it "has basic metadata" do
    expect(collection_type).to respond_to(:title)
    expect(collection_type.title).not_to be_empty
    expect(collection_type).to respond_to(:description)
    expect(collection_type.description).not_to be_empty
    expect(collection_type).to respond_to(:machine_id)
  end

  it "has configuration properties with defaults" do
    expect(collection_type.nestable?).to be_truthy
    expect(collection_type.discoverable?).to be_truthy
    expect(collection_type.sharable?).to be_truthy
    expect(collection_type.allow_multiple_membership?).to be_truthy
    expect(collection_type.require_membership?).to be_falsey
    expect(collection_type.assigns_workflow?).to be_falsey
    expect(collection_type.assigns_visibility?).to be_falsey
  end

  describe '#gid' do
    it 'returns the gid when id is not nil' do
      collection_type.id = 5
      expect(collection_type.gid.to_s).to eq 'gid://internal/hyrax-collectiontype/5'
    end

    it 'returns the gid when id is nil' do
      collection_type.id = nil
      expect(collection_type.gid).to be_nil
    end
  end

  describe "validations", :clean_repo do
    let(:collection_type) { create(:collection_type) }

    it "ensures the required fields have values" do
      collection_type.title = nil
      collection_type.machine_id = nil
      expect(collection_type).not_to be_valid
      expect(collection_type.errors.messages[:title]).not_to be_empty
      expect(collection_type.errors.messages[:machine_id]).not_to be_empty
    end
    it "ensures uniqueness" do
      is_expected.to validate_uniqueness_of(:title)
      is_expected.to validate_uniqueness_of(:machine_id)
    end
  end

  describe "collections", :clean_repo do
    let!(:collection) { create(:collection, collection_type_gid: collection_type.gid.to_s) }
    let(:collection_type) { create(:collection_type) }

    it 'returns collections of this collection type' do
      expect(collection_type.collections.to_a).to include collection
    end
  end

  describe "collections?", :clean_repo do
    it 'returns true if there are any collections of this collection type' do
      create(:collection, collection_type_gid: collection_type.gid.to_s)
      expect(collection_type.collections?).to be_truthy
    end
    it 'returns false if there are not any collections of this collection type' do
      expect(collection_type.collections?).to be_falsey
    end
  end

  describe "machine_id", :clean_repo do
    let(:collection_type) { build(:collection_type) }

    it 'assigns machine_id on create' do
      expect(collection_type.machine_id).to be_blank
      collection_type.save!
      collection_type.reload
      expect(collection_type.machine_id).not_to be_blank
    end
  end

  describe "destroy" do
    before do
      allow(collection_type).to receive(:collections?).and_return(true)
    end

    it "fails if collections exist of this type" do
      expect(collection_type.destroy).to be_falsey
      expect(collection_type.errors).not_to be_empty
    end
  end

  describe "save", :clean_repo do
    before do
      allow(collection_type).to receive(:collections?).and_return(true)
    end

    it "fails if collections exist of this type" do
      expect(collection_type.save).to be_falsey
      expect(collection_type.errors).not_to be_empty
    end
  end
end
