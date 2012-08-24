#### configuration ####
require 'dropbox_sdk' # SDK needed to use Dropbox's API
#### end of configuration ####

class AccesstokensController < ApplicationController
  unloadable

  before_filter :check_anonymous

  def index
    if(check_exists)
      cat = Accesstoken.where(:user => User.current.id).first
      #cat = Accesstoken.first(:conditions => ["user = ?", User.current.id])
      @currentDbUser = cat.email
    else
      @currentDbUser = "No account linked"
    end
  end

  def check_exists
    if(Accesstoken.exists?(:user => User.current.id))
      return true
    else
      return false
    end
  end

  def dauthorize
    if not(check_exists) then
      if not params[:oauth_token] then
        dbsession = DropboxSession.new(Daccess.appkey, Daccess.appsecret)

        session[:request_db_session] = dbsession.serialize #serialize and save this DropboxSession

        #pass to get_authorize_url a callback url that will return the user here
        redirect_to dbsession.get_authorize_url url_for(:action => 'dauthorize')
      else
        # the user has returned from Dropbox
        dbsession = DropboxSession.deserialize(session[:request_db_session])
        dbsession.get_access_token  #we've been authorized, so now request an access_token
        
        session.delete(:request_db_session) #we delete the session because we will store it in DB
        
        begin
          client = DropboxClient.new(dbsession, Daccess.accesstype) #raise an exception if session not authorized
        rescue Exception => e
          flash[:error] = "We've failed linking your account, please try again."
          redirect_to :action => "index"
          return
        end

        info = client.account_info #look up account information
        email = info['email'] #look up account email
        curruser = User.current.id #get the current user to bind to Dropbox account
        
        if(Accesstoken.exists?(:email => email)) #we check if account is already present in DB
          Accesstoken.update_all({:value => dbsession.serialize, :user => curruser}, ['email like ?', "#{email}"])
          flash[:warning] = "Your Dropbox account was already linked. Your informations have been successfully updated. Note that if you used another Redmine account with this Dropbox account, it has been replaced by the one you're currently logged in."
          redirect_to :action => "index"
        else
          a = Accesstoken.new(:email => email, :value => dbsession.serialize, :user => curruser)
          if a.save
            begin
              client.file_create_folder("/Reddrop") #create main reddrop folder
            rescue Exception => e #if folder already exist, do nothing
            end
            flash[:notice] = "Your account has been successfully linked."
            redirect_to :action => "index"
          else
            flash[:error] = "We've failed linking your account, please try again."
            redirect_to :action => "index"
          end
        end
      end
    else
      flash[:error] = "You've already a Dropbox account linked to your Redmine account, please unlink before proceeding."
      redirect_to :action => "index"
    end
  end

  def remove
    if(check_exists)
      atokentoremove = Accesstoken.first(:conditions => ["user = ?", User.current.id])
      atokentoremove.destroy
      flash[:notice] = "Your Dropbox account has been successfully unlink from your Redmine account."
      redirect_to :action => "index"
    else
      flash[:error] = "No Dropbox account linked to this Redmine account."
      redirect_to :action => "index"
    end
  end

  def check_anonymous
    if(User.current.anonymous?)
      flash[:error] = "You must be logged in to link an account."
      redirect_to :controller => "welcome"
    end
  end

end
