class GeneratedfoldersController < ApplicationController
  unloadable

  before_filter :check_rights

  def index
    @generatedfolders = Generatedfolder.find(:all, :order => "name")
  end

  def edit
    @generatedfolder = Generatedfolder.find(params[:id])
  end

  def create
    g = Generatedfolder.new(:name => params[:name])
    if g.save
      flash[:notice] = "Folder successfully created."
      redirect_to :action => "index"
    else
      flash[:error] = "Error while creating folder, please retry."
      redirect_to :action => "index"
    end
  end

  def update
    g = Generatedfolder.find(params[:id])
    g.name = params[:name]
    if g.save
      flash[:notice] = "Folder successfully updated."
      redirect_to :action => "index"
    else
      flash[:error] = "Error while updating folder, please retry."
      redirect_to :action => "index"
    end
  end

  def destroy
    g = Generatedfolder.find(params[:id])
    if g.destroy
      flash[:notice] = "Folder successfully deleted."
      redirect_to :action => "index"
    else
      flash[:error] = "Error while deleting folder, please retry."
      redirect_to :action => "index"
    end
  end

  def check_rights
    if User.current.admin?
    else
      redirect_to :controller => "welcome", :action => "index"
    end
  end
end
