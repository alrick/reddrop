#### configuration ####
require 'dropbox_sdk' # SDK needed to use Dropbox's API
require 'net/http'
require 'uri'
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
  
  def dropbox_sync(forcedSync = nil)
    # We check if the user is allowed to do the sync, if not he is redirected to the index page
    unless check_project_members 
      redirect_to :action => "index", :project_id => params[:project_id]
      flash[:error] = "Synchronisation not allowed: You must be a project member in order to perform a synchronisation."
      return
    end

    #get the user with the id sent from the index view
    @projectuser = Projectuser.find(params[:id])
 
    #create Dropbox client
    begin
      dbSession = DropboxSession.deserialize(@projectuser.accesstoken.value)
      client = DropboxClient.new(dbSession, Daccess.accesstype)
    rescue Exception => e
      @projectuser.accesstoken.destroy
      flash[:error] = "Error with Dropbox authentification"
      redirect_to :action => "index", :project_id => params[:project_id]
      return
    end  
    
    oversizedFiles = 0 #this var will be incremented every time a file is too big to upload
    warnings = Array.new #array with warnings that may occurs during sync
    @errors = Array.new #same, but with errors

    projectDocuments = @project.documents #documents of the current project
    enumeration = Enumeration.where("type = 'DocumentCategory'")
    path = "/Reddrop/"+params[:project_id]
    dropboxData = client.metadata(path) #content inside the project folder

    # This loop run through the content of each folder in the project folder
    dropboxData['contents'].each do |data|
      match = nil
      folderPath = data['path'] #path to the folders in the project folder
      @folderName = File.basename(folderPath) #basename return the name of the child path (therefore the folder name)      
      @document = @project.documents.build
      @document['category_id'] = nil #category_id is going to be set in the following loop
 
      # we check the enumerations in order to get the category id for the document (enum and docs in Dropbox have the same name)
      enumeration.each do |enum|
        if @folderName == enum.name.tr(' ', '_')
          @document['category_id'] = enum.id
          break #if an enum matches the folder name, the loop is no longer useful
        end
      end
 
      if @document['category_id'].nil?
        @errorOccured = true
        warnings << "Warning: A document could not be created. Folder names CANNOT be changed in Dropbox, their names must match the Redmine document categories."
        next #if nothing has been found, we go to the next do iteration
      end

      #we look if the document already exists in this project, if yes match becomes true and we can skip the next unless condition
      projectDocuments.each do |p|
        if p.title == @folderName && p.category_id == @document['category_id']
          match = true
          @documentID = p.id.to_s
        end
      end
 
      unless match #if match is not true, that means the document was not found, so we create one
        @document['title'] = @folderName
        @document['description'] = "Document created by Dropbox -> Redmine synchronisation"
        @document['created_on'] = Time.now #return system actual time
        if !@document.save #if an error occurs during creating the document
          flash[:error] = "Error during document creation, please try again to synchronise your Dropbox"
          redirect_to :action => "index", :project_id => @project.identifier
          return
        end
        projectDocuments = @project.documents #now that we created a new doc in the DB, we need to re-affect the var because project document have changed
        #this loop is done in order to get the document ID
        projectDocuments.each do |p|
          if p.title == @folderName && p.category_id == @document['category_id']
            @documentID = p.id.to_s
          end
        end
      end

      @folderMetadata = client.metadata(path+"/"+@folderName) #retrieve files's metadata in the Dropbox folder
      if @folderMetadata['contents'].empty?
        next
      end

      # loop looking for files in the current folder, this will be executed for each folder
      @folderMetadata['contents'].each do |fm| 
        @uploadError = nil
        #condition checking if there is a folder instead of a file in the Dropbox folder
        if fm['is_dir']
          @errorOccured = true
          warnings << "Warning: A problem has been detected during synchronisation, probably because a subfolder was created in a folder generated by Reddrop. Subfolders WILL NOT be stored on Redmine."
          next
        end
        completePath = fm['path'] #complete path to file
        @fileName = File.basename(completePath) #file name
        if fm['bytes'].to_i > Setting.attachment_max_size.to_i.kilobytes
          @errorOccured = true
          oversizedFiles += 1 #var used to know how many files are over the size limit, it will be displayed to the user if needed
          next
        elsif fm['bytes'].to_i == 0 #empty file cannot be uploaded because in this case the token will be incomplete
          @errorOccured = true
          warnings << "Warning: You have uploaded an empty file, empty files CANNOT be stored on Redmine."
          next
        end
        ## find attachment with the same name as the file in dropbox in the correct document (thanks to the id)
        attachment = Attachment.where("filename = ? AND container_id = ? AND description LIKE 'Reddrop|Last modification%'", @fileName, @documentID)
        if attachment.exists? && forcedSync.nil?
          @dbMtime = client.metadata(completePath)['modified'] #retrieve mtime of the file in Dropbox
          attachmentMtime = attachment.first.description.to_datetime #the mtime is present in the description, here, only the date is extracted and converted to a datetime object
          if DateTime.parse(@dbMtime) > attachmentMtime #date comparison, if the file in Dropbox has changed since, we re-upload it...
            ## We get the file content on Dropbox servers, if something wrong occurs we go to the next iteration
            begin
              @fileContent = client.get_file(completePath)
            rescue Exception => getContentError
              @errorOccured = true
              @errors << "Error: The file '"+@fileName+"' could not be uploaded."
              error_log_message("File content could not be retrieved. Error: >> "+getContentError.to_s+" <<")
              next
            end
            begin
              upload_request
            rescue Exception => uprequestError
              @uploadError = true
              @errorOccured = true
              @errors << "Error: The file '"+@fileName+"' could not be uploaded."
              error_log_message("The file upload failed, error handling for upload_request returned: "+uprequestError.to_s)
              delete_attachment_if_error
              next
            end
            unless @uploadError
              if @secondResponse.code == "302" #status returned if the upload went well
                begin
                  Attachment.find(attachment.first.id.to_i).destroy #... then destroy the old one
                rescue Exception => destroyError
                  error_log_message("Unable to delete attachment after uploading a new version of the file. Error Info: "+destroyError.to_s)
                end
              elsif @secondResponse.code == "403"
                delete_attachment_if_error
                flash[:error] = "You do not have the rights to add files to a document. Please check your role in the project."
                redirect_to :action => "index", :project_id => @project.identifier
                return
              else
                delete_attachment_if_error
                flash[:error] = "Synchronisation failed, please try again. If the problem persists, try to relog your account to Redmine."
                redirect_to :action => "index", :project_id => @project.identifier
                return
              end
            end
          else
            next #if the file mtime did not change since the last sync, go to the next do iteration
          end
        else #if the attachment does not exist, it is not necessary to check the mtime
          @dbMtime = client.metadata(completePath)['modified']
          #logger.info("#### Getting file content at ["+"#{Time.now}"+"]")
          begin
            @fileContent = client.get_file(completePath)
          rescue Exception => getContentError
            @errorOccured = true
            @errors << "Error: The file '"+@fileName+"' could not be uploaded."
            error_log_message("File content could not be retrieved. Error: >> "+getContentError.to_s+" <<")
            next
          end
          #logger.info("#### File content retrieved at ["+"#{Time.now}"+"]")
          begin
            upload_request
          rescue Exception => uprequestError
            @uploadError = true
            @errorOccured = true
            @errors << "Error: The file '"+@fileName+"' could not be uploaded."
            error_log_message("The file upload failed, error handling for upload_request returned: "+uprequestError.to_s)
            delete_attachment_if_error
            next
          end
          unless @uploadError #if the upload failed, it is not necessary to inspect the second response
            if @secondResponse.code == "302" #if the status is 302, we do nothing, else we delete the attachment
              #do Nothing
            elsif @secondResponse.code == "403"
              delete_attachment_if_error
              flash[:error] = "You do not have the rights to add files to a document. Please check your role in the project."
              redirect_to :action => "index", :project_id => @project.identifier
              return  
            else
              delete_attachment_if_error
              flash[:error] = "Synchronisation failed, please try again. If the problem persists, try to relog your account to Redmine."
              redirect_to :action => "index", :project_id => @project.identifier
              return
            end  
          end
          if forcedSync
            if attachment.exists?
              begin
                Attachment.find(attachment.first.id.to_i).destroy
              rescue Exception => destroyError
                error_log_message("Unable to delete attachment after uploading a new version of the file during force Sync. Error Info: "+destroyError.to_s)
              end 
            end
          end
        end
      end #end of next file in Dropbox folder loop
    end #end of first do statement (next Dropbox folder loop)
    unless @errorOccured.nil?
      if oversizedFiles > 0
        warnings << "Warning: "+oversizedFiles.to_s+" file(s) could not be uploaded, the file size is over the limit."
      end
      unless warnings.empty?
        flash[:warning] = warnings.join("<br/>").html_safe
      end
      unless @errors.empty?
        flash[:error] = @errors.join("<br/>").html_safe
      end
      flash[:alert] = "Synchronisation finished."
      redirect_to :action => "index", :project_id => @project.identifier
      return
    end
    flash[:notice] = "Synchronisation has been successfully executed."
    redirect_to :action => "index", :project_id => @project.identifier
    return
  end
  
  def upload_request
    @host = request.host_with_port
    uri = URI.parse(Uploadurls.upload_url(@host))
    http = Net::HTTP.new(uri.host, uri.port)

    if request.protocol == "https://"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    
    http.read_timeout = 300 #according more time for the request in case of longer upload
    @csrfToken = session[:_csrf_token] #token used for forgery protection
    @apiKey = User.current.api_key #redmine api key used for requests to the API
    request = Net::HTTP::Post.new(uri.path+"?attachment_id=1&filename="+URI.encode(@fileName), initheader = {'Content-Type' => "application/octet-stream", 'X-CSRF-Token' => @csrfToken, 'X-Redmine-API-Key' => @apiKey}) #see Redmine API for more details
    request.body = @fileContent

    @response = http.request(request) #sending request
    
    begin
      @upToken = ActiveSupport::JSON.decode(@response.body)['upload']['token'] #upload token in the response body
    rescue Exception => uploadError
      @errorOccured = true
      @uploadError = true
      @errors << "An error occured during '"+@fileName+"' upload, please try again."
      error_log_message("The upload Token for file '"+@fileName+"' could not be retrieved. Check the first upload request's params")
      return
    end

    second_request   
  end

  def second_request
    secondUri = URI.parse(Uploadurls.add_attachment_url(@host, @documentID))
    secondHttp = Net::HTTP.new(secondUri.host, secondUri.port)

    if request.protocol == "https://"
      secondHttp.use_ssl = true
      secondHttp.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    secondRequest = Net::HTTP::Post.new(secondUri.path, initheader = {'Content-Type' => "multipart/form-data", 'X-CSRF-Token' => @csrfToken, 'Cookie' => "_redmine_session="+cookies[:_redmine_session]})
    secondRequest.body = {:utf8 => "\u2713", :authenticity_token => @csrfToken, :attachments => {"1" => {:filename => @fileName, :description => "Reddrop|Last modification: "+@dbMtime, :token => @upToken}}, :commit => "Add"}.to_query #here, the attachment id does not matter, it's going to be generated automatically

    @secondResponse = secondHttp.request(secondRequest) #sending second request
  end

  def delete_attachment_if_error
    error_log_message("First Request Response inspection: >>' "+@response.inspect+" '<< | Second Request Response object inspection: >>' "+@secondResponse.inspect+" '<<. If nil, something wrong happened during the first request, please check the params in the Redmine error log. This may happen if a Timeout error occured, check your file size.")
    attToDestroy = Attachment.where("filename = ? AND container_id IS NULL", @fileName)
    if attToDestroy.exists?
      Attachment.find(attToDestroy.first.id.to_i).destroy
      error_log_message("Attachment successfully deleted!")
    else
      error_log_message("The file '"+@fileName+"' has been uploaded but could not be removed from the database (because it could not be found). Please check if an attachment with this name and a container_id = nil exists in database and remove it.")
    end
  end

  def force_sync
    forceSync = true
    dropbox_sync(forceSync)
  end

  def error_log_message(message)
    ## Default message displayed for the admin if a "serious" problem occurs
    logger.info("REDDROP ERROR: ["+"#{DateTime.now}"+"] [Project: "+"#{@project.identifier}"+"] "+"#{message}")    
  end

  def check_project_members
    if User.current.admin?
      return true
    end
    projectMembers = @project.members
    projectMembers.each do |p|
      if User.current.id == p.user_id
        return true
      end
    end
    false
  end
end
