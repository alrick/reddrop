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
    name = params[:name] # get name
    name = check_name(name) # correct name

    if !check_exists(name)
      g = Generatedfolder.new(:name => name)
      if g.save
        flash[:notice] = "Folder successfully created."
        redirect_to :action => "index"
      else
        flash[:error] = "Error while creating folder, please retry."
        redirect_to :action => "index"
      end
    else
      flash[:error] = "This folder already exists."
      redirect_to :action => "index"
    end
  end

  def update
    g = Generatedfolder.find(params[:id])
    name = params[:name] # get name
    name = check_name(name) # correct name

    if !check_exists(name)
      g.name = name
      if g.save
        flash[:notice] = "Folder successfully updated."
        redirect_to :action => "index"
      else
        flash[:error] = "Error while updating folder, please retry."
        redirect_to :action => "edit"
      end
    else
      flash[:error] = "This folder already exists."
      redirect_to :action => "edit"
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

  def check_name(name)
    name = name.tr(' ', '_') # replace spaces
    name = name.gsub(/[^0-9A-Za-z_]/, '') # replace special chars but _
  end

  def check_exists(name)
    Generatedfolder.exists?(:name => name)
  end
end
