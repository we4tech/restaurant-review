class ResourceImportersController < ApplicationController

  def index
    @resource_importers = @topic.resource_importers.paginate :page => params[:page]
  end

  def new
    @resource_importer = ResourceImporter.new
  end

  def create
    @resource_importer = ResourceImporter.new params[:resource_importer]
    @resource_importer.topic_id = @topic.id
    @resource_importer.user_id = current_user.id
    if @resource_importer.import
      flash[:notice] = "Successfully imported - #{@resource_importer.imported_items.to_i} out of #{@resource_importer.total_items} items."
      redirect_to resource_importers_path
    else
      flash[:notice] = "Failed to import"
      render :action => :new
    end
  end
end
