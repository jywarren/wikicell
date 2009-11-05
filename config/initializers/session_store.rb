# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_wikicell_session',
  :secret      => '34ef140c8aa3b47e51688f662f3f0f074c65ca40580210a50c222512aad842491f937bbc64e615664e532ec1f29f76e108a2af49ebb5a1062ae5b00a03da0c6e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
