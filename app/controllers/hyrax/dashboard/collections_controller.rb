module Hyrax
  module Dashboard
    ## Shows a list of all collections to the admins
    class CollectionsController < Hyrax::My::CollectionsController
      include Blacklight::AccessControls::Catalog
      include Blacklight::Base
      include BreadcrumbsForCollections
      layout 'dashboard'

      before_action :filter_docs_with_read_access!, except: :show
      before_action :remove_select_something_first_flash, except: :show

      include Hyrax::Collections::AcceptsBatches

      # include the render_check_all view helper method
      helper Hyrax::BatchEditsHelper
      # include the display_trophy_link view helper method
      helper Hyrax::TrophyHelper

      # This is needed as of BL 3.7
      copy_blacklight_config_from(::CatalogController)

      # Catch permission errors
      rescue_from Hydra::AccessDenied, CanCan::AccessDenied, with: :deny_collection_access

      # actions: index, create, new, edit, show, update, destroy, permissions, citation
      before_action :authenticate_user!, except: [:index]

      class_attribute :presenter_class,
                      :form_class,
                      :single_item_search_builder_class,
                      :member_search_builder_class

      alias collection_search_builder_class single_item_search_builder_class
      deprecation_deprecate collection_search_builder_class: "use single_item_search_builder_class instead"

      alias collection_member_search_builder_class member_search_builder_class
      deprecation_deprecate collection_member_search_builder_class: "use member_search_builder_class instead"

      self.presenter_class = Hyrax::CollectionPresenter

      self.form_class = Hyrax::Forms::CollectionForm

      # The search builder to find the collection
      self.single_item_search_builder_class = SingleCollectionSearchBuilder
      # The search builder to find the collections' members
      self.member_search_builder_class = Hyrax::CollectionMemberSearchBuilder

      load_and_authorize_resource except: [:index, :create], instance_name: :collection

      before_action :ensure_admin!, only: :index # index for All Collections; see also Hyrax::My::CollectionsController #index for My Collections

      def deny_collection_access(exception)
        if exception.action == :edit
          redirect_to(url_for(action: 'show'), alert: 'You do not have sufficient privileges to edit this document')
        elsif current_user && current_user.persisted?
          redirect_to root_url, alert: exception.message
        else
          session['user_return_to'] = request.url
          redirect_to main_app.new_user_session_url, alert: exception.message
        end
      end

      def new
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.collections.new.header'), hyrax.new_dashboard_collection_path
        @collection.apply_depositor_metadata(current_user.user_key)
        form
      end

      def show
        ci = CollectionBrandingInfo.where(collection_id: @collection.id.to_s).where(role: "banner")
        @banner_file = "/" + ci[0].local_path.split("/")[-4..-1].join("/") unless ci.empty?

        presenter
        query_collection_members
      end

      def edit
        # Get banner and logo data ready for display
        determine_banner_data
        determine_logo_data

        query_collection_members
        # this is used to populate the "add to a collection" action for the members
        @user_collections = find_collections_for_form
        form
      end

      def after_create
        form
        respond_to do |format|
          ActiveFedora::SolrService.instance.conn.commit
          format.html { redirect_to dashboard_collection_path(@collection), notice: 'Collection was successfully created.' }
          format.json { render json: @collection, status: :created, location: dashboard_collection_path(@collection) }
        end
      end

      def after_create_error
        form
        respond_to do |format|
          format.html { render action: 'new' }
          format.json { render json: @collection.errors, status: :unprocessable_entity }
        end
      end

      def create
        # Manual load and authorize necessary because Cancan will pass in all
        # form attributes. When `permissions_attributes` are present the
        # collection is saved without a value for `has_model.`
        @collection = ::Collection.new
        authorize! :create, @collection

        @collection.attributes = collection_params.except(:members)
        @collection.apply_depositor_metadata(current_user.user_key)
        add_members_to_collection unless batch.empty?
        # TODO: There has to be a better way to handle a missing gid than setting to User Collection.
        # TODO: Via UI, there should always be one defined.  It is missing right now because the modal isn't implemented yet
        # TODO: But perhaps this is needed for the case when it gets called outside the context of the UI?
        @collection.collection_type_gid ||= default_collection_type_gid
        @collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE unless @collection.discoverable?
        if @collection.save
          after_create
        else
          after_create_error
        end
      end

      def default_collection_type_gid
        Hyrax::CollectionType.find_or_create_default_collection_type.gid
      end

      def after_update
        if flash[:notice].nil?
          flash[:notice] = 'Collection was successfully updated.'
        end
        respond_to do |format|
          format.html { redirect_to dashboard_collection_path(@collection) }
          format.json { render json: @collection, status: :updated, location: dashboard_collection_path(@collection) }
        end
      end

      def after_update_error
        form
        query_collection_members
        respond_to do |format|
          format.html { render action: 'edit' }
          format.json { render json: @collection.errors, status: :unprocessable_entity }
        end
      end

      def update
        process_banner_input
        process_logo_input

        process_member_changes
        @collection.visibility = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE unless @collection.discoverable?
        if @collection.update(collection_params.except(:members))
          after_update
        else
          after_update_error
        end
      end

      def after_destroy(id)
        respond_to do |format|
          format.html do
            redirect_to my_collections_path,
                        notice: "Collection #{id} was successfully deleted"
          end
          format.json { head :no_content, location: my_collections_path }
        end
      end

      def after_destroy_error(id)
        respond_to do |format|
          format.html do
            flash[:notice] = "Collection #{id} could not be deleted"
            render :edit, status: :unprocessable_entity
          end
          format.json { render json: { id: id }, status: :unprocessable_entity, location: dashboard_collection_path(@collection) }
        end
      end

      def destroy
        if @collection.destroy
          after_destroy(params[:id])
        else
          after_destroy_error(params[:id])
        end
      end

      def collection
        action_name == 'show' ? @presenter : @collection
      end

      # Renders a JSON response with a list of files in this collection
      # This is used by the edit form to populate the thumbnail_id dropdown
      def files
        result = form.select_files.map do |label, id|
          { id: id, text: label }
        end
        render json: result
      end

      def search_builder_class
        Hyrax::CollectionSearchBuilder
      end

      private

        def uploaded_files(uploaded_file_ids)
          return [] if uploaded_file_ids.empty?
          UploadedFile.find(uploaded_file_ids)
        end

        def determine_banner_data
          # Find Banner filename
          ci = CollectionBrandingInfo.where(collection_id: @collection.id.to_s).where(role: "banner")
          @banner_file = File.split(ci[0].local_path).last unless ci.empty?
          @banner_file_location = ci[0].local_path unless ci.empty?
          @banner_file_for_display = "/" + ci[0].local_path.split("/")[-4..-1].join("/") unless ci.empty?
        end

        def determine_logo_data
          @logo_info = []
          # FInd Logo filename, alttext, linktext
          cis = CollectionBrandingInfo.where(collection_id: @collection.id.to_s).where(role: "logo")
          return if cis.empty?
          cis.each do |coll_info|
            logo_file = File.split(coll_info.local_path).last
            alttext = coll_info.alt_text
            linkurl = coll_info.target_url
            @logo_info << { file: logo_file, file_location: coll_info.local_path, alttext: alttext, linkurl: linkurl }
          end
        end

        def process_banner_input
          uploaded_file_ids = params["banner_files"]
          return if uploaded_file_ids.nil?
          ci = CollectionBrandingInfo.where(collection_id: @collection.id.to_s).where(role: "banner")
          ci.delete_all unless ci.nil?
          f = uploaded_files(uploaded_file_ids).first
          ci = CollectionBrandingInfo.new(
            collection_id: @collection.id,
            filename: File.split(f.file_url).last,
            role: "banner",
            alt_txt: "",
            target_url: ""
          )
          ci.save f.file_url
        end

        def update_logo_info(uploaded_file_id, alttext, linkurl)
          ci = CollectionBrandingInfo.where(collection_id: @collection.id.to_s).where(role: "logo").where(local_path: uploaded_file_id.to_s)
          ci.first.alt_text = alttext
          ci.first.target_url = linkurl
          ci.first.local_path = uploaded_file_id
          ci.first.save uploaded_file_id
        end

        def create_logo_info(uploaded_file_id, alttext, linkurl)
          file = uploaded_files(uploaded_file_id)
          ci = CollectionBrandingInfo.new(
            collection_id: @collection.id,
            filename: File.split(file.file_url).last,
            role: "logo",
            alt_txt: alttext,
            target_url: linkurl
          )
          ci.save file.file_url
          ci
        end

        def remove_redundant_files(public_files)
          # remove any public ones that were not included in the selection.
          cis = CollectionBrandingInfo.where(collection_id: @collection.id.to_s).where(role: "logo")
          cis.each do |coll_info|
            coll_info.delete(coll_info.local_path) unless public_files.include? coll_info.local_path
            coll_info.destroy unless public_files.include? coll_info.local_path
          end
        end

        def process_logo_records(uploaded_file_ids)
          public_files = []
          uploaded_file_ids.each_with_index do |ufi, i|
            if ufi.include?('public')
              update_logo_info(ufi, params["alttext"][i], params["linkurl"][i])
              public_files << ufi
            else # brand new one, insert in the database
              ci = create_logo_info(ufi, params["alttext"][i], params["linkurl"][i])
              public_files << ci.local_path
            end
          end
          public_files
        end

        def process_logo_input
          uploaded_file_ids = params["logo_files"]
          public_files = []

          if uploaded_file_ids.nil?
            remove_redundant_files public_files
            return
          end

          public_files = process_logo_records uploaded_file_ids
          remove_redundant_files public_files
        end

        # run a solr query to get the collections the user has access to edit
        # @return [Array] a list of the user's collections
        def find_collections_for_form
          Hyrax::CollectionsService.new(self).search_results(:edit)
        end

        def remove_select_something_first_flash
          flash.delete(:notice) if flash.notice == 'Select something first'
        end

        def presenter
          @presenter ||= begin
            # Query Solr for the collection.
            # run the solr query to find the collection members
            response = repository.search(single_item_search_builder.query)
            curation_concern = response.documents.first
            raise CanCan::AccessDenied unless curation_concern
            presenter_class.new(curation_concern, current_ability)
          end
        end

        # Instantiates the search builder that builds a query for a single item
        # this is useful in the show view.
        def single_item_search_builder
          single_item_search_builder_class.new(self).with(params.except(:q, :page))
        end

        alias collection_search_builder single_item_search_builder
        deprecation_deprecate collection_search_builder: "use single_item_search_builder instead"

        # Instantiates the search builder that builds a query for items that are
        # members of the current collection. This is used in the show view.
        def member_search_builder
          @member_search_builder ||= member_search_builder_class.new(self)
        end

        alias collection_member_search_builder member_search_builder
        deprecation_deprecate collection_member_search_builder: "use member_search_builder instead"

        def collection_params
          form_class.model_attributes(params[:collection])
        end

        # Queries Solr for members of the collection.
        # Populates @response and @member_docs similar to Blacklight Catalog#index populating @response and @documents
        def query_collection_members
          params[:q] = params[:cq]
          @response = repository.search(query_for_collection_members)
          @member_docs = @response.documents
        end

        # @return <Hash> a representation of the solr query that find the collection members
        def query_for_collection_members
          member_search_builder.with(params_for_members_query).query
        end

        # You can override this method if you need to provide additional inputs to the search
        # builder. For example:
        #   search_field: 'all_fields'
        # @return <Hash> the inputs required for the collection member search builder
        def params_for_members_query
          params.merge(q: params[:cq])
        end

        def process_member_changes
          case params[:collection][:members]
          when 'add' then add_members_to_collection
          when 'remove' then remove_members_from_collection
          when 'move' then move_members_between_collections
          end
        end

        def add_members_to_collection(collection = nil)
          collection ||= @collection
          collection.add_member_objects batch
        end

        def remove_members_from_collection
          batch.each do |pid|
            work = ActiveFedora::Base.find(pid)
            work.member_of_collections.delete @collection
            work.save!
          end
        end

        def move_members_between_collections
          destination_collection = ::Collection.find(params[:destination_collection_id])
          remove_members_from_collection
          add_members_to_collection(destination_collection)
          if destination_collection.save
            flash[:notice] = "Successfully moved #{batch.count} files to #{destination_collection.title} Collection."
          else
            flash[:error] = "An error occured. Files were not moved to #{destination_collection.title} Collection."
          end
        end

        # Include 'catalog' and 'hyrax/base' in the search path for views, while prefering
        # our local paths. Thus we are unable to just override `self.local_prefixes`
        def _prefixes
          @_prefixes ||= super + ['catalog', 'hyrax/base']
        end

        def ensure_admin!
          # Even though the user can view this collection, they may not be able to view
          # it on the admin page.
          authorize! :read, :admin_dashboard
        end

        def search_action_url(*args)
          hyrax.dashboard_collections_url(*args)
        end

        def form
          @form ||= form_class.new(@collection, current_ability, repository)
        end
    end
  end
end
