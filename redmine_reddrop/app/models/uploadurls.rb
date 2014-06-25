# The first url is used to upload your file on Redmine, 
# the second to attach the file to the corresponding document with its ID.
#
# The host var is set in the projectusersController and will be passed as parameter, 
# so do the document ID for the second request.
#
# The first url MUST finish by "/uploads.json" and the second
# by "/documents/"+docID+"/add_attachment.html"
#
# 1st URL Example: <protocol>://<your_host>:port/path_if_needed/uploads.json
# 2nd URL Example: <protocol>://<your_host>:port/path_if_needed/documents/"+docID+"/add_attachment.html"
# where:
# <protocol>: either http or https (Was not test with another one)
# <your_host>: host retrieved with "request.host_with_port" in the main controller
# port: if 80, you don't have to precise it (eg. Webrick webserver run with the 3000 by default)
# path_if_needed: access path to your Redmine platform
#
# Full example: http://"+host+"/redmine/uploads.json AND http://"+host+"/redmine/documents/"+docID+"/add_attachment.html


class Uploadurls < ActiveRecord::Base
  def self.upload_url (host)
    "http://"+host+"/redmine/uploads.json"
  end

  def self.add_attachment_url (host, docID)
    "http://"+host+"/redmine/documents/"+docID+"/add_attachment.html"
  end
end
