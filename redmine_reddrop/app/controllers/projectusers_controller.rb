#### configuration ####
require 'dropbox_sdk' # SDK needed to use Dropbox's API
#### end of configuration ####

class ProjectusersController < ApplicationController
  unloadable

  before_filter :find_project, :authorize

  def index
    @projectusers = Projectuser.find(:all, :conditions => ["project = ?", @project.id])
    
    # check if user has reddroped project, to allow him to reddrop or unreddrop accordingly
    @has_reddroped = false
    if(Accesstoken.exists?(:user => User.current.id))
      cat = Accesstoken.where(:user => User.current.id).first
      if(Projectuser.count(:conditions => ["accesstoken_id = ? AND project = ?", cat.id, @project.id]) > 0)
        @has_reddroped = true
      end
    end
  end

  def show
    #get user
    @projectuser = Projectuser.find(params[:id])

    #get client to access dropbox
    begin
      dbsession = DropboxSession.deserialize(@projectuser.accesstoken.value) #get accesstoken for the current user
      client = DropboxClient.new(dbsession, Daccess.accesstype) #raise an exception if session not authorized
    rescue Exception => e
      @projectuser.accesstoken.destroy
      flash[:error] = "Error with your Dropbox authentification, please try to relink your Dropbox account."
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end
    
    #display files/folders
    if(params[:path].to_s.starts_with? "/Reddrop/"+params[:project_id])
      path = params[:path] || "/Reddrop/"+params[:project_id]
    else
      path = "/Reddrop/"+params[:project_id]
    end
    if path != "/Reddrop/"+params[:project_id]
      @parentpath = File.dirname(path)
    end

    #get the entry with default path or specified one
    begin
      @entry = client.metadata(path) #get current file/folder metadata
    rescue Exception => e
      @projectuser.accesstoken.destroy
      flash[:error] = "Error with your Dropbox authentification, please try to relink your Dropbox account."
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end
  end

  def destroy
    #get user
    p = Projectuser.find(params[:id])

    #get client to access dropbox
    dbsession = DropboxSession.deserialize(p.accesstoken.value) #get accesstoken for the current user
    begin
      client = DropboxClient.new(dbsession, Daccess.accesstype) #raise an exception if session not authorized
    rescue Exception => e
      p.accesstoken.destroy
      flash[:error] = "Error with your Dropbox authentification, please try to relink your Dropbox account."
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end

    begin
      client.file_delete(params[:path])
      flash[:notice] = "File ("+params[:name]+") successfully deleted."
      redirect_to :action => "show", :id => p, :path => params[:parent], :project_id => params[:project_id]
    rescue Exception => e #something wrong append when deleting
      flash[:error] = "An error occurred when deleting, please try again."
      redirect_to :action => "show", :id => p, :path => params[:parent], :project_id => params[:project_id]
      return
    end
  end

  def add
    #get user
    p = Projectuser.find(params[:id])
    parent = params[:parent]
    name = (params[:file]).original_filename
    destination = "#{parent}/#{name}"

    #get client to access dropbox
    dbsession = DropboxSession.deserialize(p.accesstoken.value) #get accesstoken for the current user
    begin
      client = DropboxClient.new(dbsession, Daccess.accesstype) #raise an exception if session not authorized
    rescue Exception => e
      p.accesstoken.destroy
      flash[:error] = "Error with your Dropbox authentification, please try to relink your Dropbox account."
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end

    begin
      client.put_file(destination, params[:file].read)
      flash[:notice] = "File ("+name+") successfully added."
      redirect_to :action => "show", :id => p, :path => params[:parent], :project_id => params[:project_id]
    rescue Exception => e #something wrong append when deleting
      flash[:error] = "An error occurred when adding, please try again."
      redirect_to :action => "show", :id => p, :path => params[:parent], :project_id => params[:project_id]
    end
  end

  def download
    #get user
    p = Projectuser.find(params[:id])

    #get client to access dropbox
    dbsession = DropboxSession.deserialize(p.accesstoken.value) #get accesstoken for the current user
    begin
      client = DropboxClient.new(dbsession, Daccess.accesstype) #raise an exception if session not authorized
    rescue Exception => e
      p.accesstoken.destroy
      flash[:error] = "Error with your Dropbox authentification, please try to relink your Dropbox account."
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end

    begin
      path = client.media(params[:path])
      redirect_to path['url']
    rescue Exception => e #something wrong append when deleting
      flash[:error] = "An error occurred when redirecting to file, please try again."
      redirect_to :action => "show", :id => p, :path => params[:parent], :project_id => params[:project_id]
    end
  end

  def reddropproject
    if(Accesstoken.exists?(:user => User.current.id))
      cat = Accesstoken.where(:user => User.current.id).first
      p = Projectuser.new(:project => params[:project], :accesstoken_id => cat.id)
      
      #get client to access dropbox
      dbsession = DropboxSession.deserialize(cat.value) #get accesstoken for the current user
      begin
        client = DropboxClient.new(dbsession, Daccess.accesstype) #raise an exception if session not authorized
      rescue Exception => e
        cat.destroy
        flash[:error] = "Error with your Dropbox authentification, please try to relink your Dropbox account."
        redirect_to :action => "index", :project_id => params[:project_id]
        return
      end

      # create the project folder as starting point
      begin
        client.file_create_folder("/Reddrop/"+params[:project_id])
      rescue Exception => e
      end

      # get folder structure to generated
      @generatedfolders = Generatedfolder.find(:all, :order => "name")

      begin
        @generatedfolders.each do |g|
          client.file_create_folder("/Reddrop/"+params[:project_id]+"/"+g.name) #create subfolders for project
        end
      rescue Exception => e #subfolders probably already in the main folder, do nothing
      end

      # save projectuser record
      if p.save
        flash[:notice] = "Project successfully Reddroped."
        redirect_to :action => "index", :project_id => params[:project_id]
      else
        flash[:error] = "Error while Reddroping project, please retry."
        redirect_to :action => "index", :project_id => params[:project_id]
      end
    else
      flash[:error] = "You must link a Dropbox account before you can Reddrop a project. Go to \"Reddrop linking\" on top menu."
      redirect_to :action => "index", :project_id => params[:project_id]
    end
  end

  def unreddropproject
    if(Accesstoken.exists?(:user => User.current.id))
      cat = Accesstoken.where(:user => User.current.id).first
      p = Projectuser.first(:conditions => ["accesstoken_id = ? AND project = ?", cat.id, params[:project]])
      if p.destroy
        flash[:notice] = "Project successfully unReddroped."
        redirect_to :action => "index", :project_id => params[:project_id]
      else
        flash[:error] = "Error while unReddroping project, please retry."
        redirect_to :action => "index", :project_id => params[:project_id]
      end
    else
      flash[:error] = "Error occured when unReddroping, please check your Reddrop linking and try again."
      redirect_to :action => "index", :project_id => params[:project_id]
    end
  end

  def find_project
    # @project variable must be set before calling the authorize filter
    @project = Project.find(params[:project_id])
  end

end
