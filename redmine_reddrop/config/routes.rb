match 'accesstokens', :to => 'accesstokens#index'
match 'accesstokens/index', :to => 'accesstokens#index'
match 'accesstokens/dauthorize', :to => 'accesstokens#dauthorize'
match 'accesstokens/remove', :to => 'accesstokens#remove'

match 'projectusers', :to => 'projectusers#index'
match 'projectusers/index', :to => 'projectusers#index'
match 'projectusers/show/:id', :to => 'projectusers#show'
match 'projectusers/destroy/:id', :to => 'projectusers#destroy'
match 'projectusers/add/:id', :to => 'projectusers#add'
match 'projectusers/download/:id', :to => 'projectusers#download'
match 'projectusers/reddropproject', :to => 'projectusers#reddropproject'
match 'projectusers/unreddropproject', :to => 'projectusers#unreddropproject'
match 'projectusers/find_project', :to => 'projectusers#find_project'

## Kev ##

match 'projectusers/synchronise', :to => 'projectusers#synchronise'
match 'projectusers/dropbox_sync', :to => 'projectusers#dropbox_sync'
match 'projectusers/addFile', :to => 'projectusers#addFile'
match 'projectusers/deleteAttach', :to => 'projectusers#deleteAttach'
match 'projectusers/force_sync', :to => 'projectusers#force_sync'
## end of ##

match 'generatedfolders', :to => 'generatedfolders#index'
match 'generatedfolders/index', :to => 'generatedfolders#index'
match 'generatedfolders/edit/:id', :to => 'generatedfolders#edit'
match 'generatedfolders/create', :to => 'generatedfolders#create'
match 'generatedfolders/update/:id', :to => 'generatedfolders#update'
match 'generatedfolders/destroy/:id', :to => 'generatedfolders#destroy'
match 'generatedfolders/create_from_enum/', :to => 'generatedfolders#create_from_enum'
match 'generatedfolders/show_db_entries', :to => 'generatedfolders#show_db_entries'
match 'generatedfolders/delete_attachment', :to => 'generatedfolders#delete_attachment'
