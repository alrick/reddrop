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

  def show_db_entries
    @attachments = Attachment.where("container_id IS NULL")
  end

  def create_from_enum
    createdFolders = 0
    enumeration = Enumeration.where("type = 'DocumentCategory'")
    enumeration.each do |e|
      name = e.name
      name = check_name(name)

      if !check_exists(name)
        newFolder = Generatedfolder.new(:name => name)
        if newFolder.save
          createdFolders += 1
        else
          flash[:error] = "Error during folder save, please try again."
        end
      else
        next
      end
    end
    if createdFolders == 0
      flash[:notice] = "No folders were created, they already all exist."
    else
      flash[:notice] = createdFolders.to_s+" folders successfully created."
    end
    redirect_to :action => "index"
  end

  def delete_attachment
    attachmentsID = params[:attachment_checkbox] #get array of attachments id
    attachmentsID.each do |a|
      begin
        Attachment.find(a.to_i).destroy
      rescue Exception => deleteCheckbox
        flash[:error] = "An error occured during file suppression, please try again."
        redirect_to :action => "show_db_entries"
        return
      end
    end
    flash[:notice] = "Attachment(s) successfully deleted."
    redirect_to :action => "show_db_entries"
  end
end
