$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "attributes_hash"

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

load File::expand_path('spec/support/schema.rb')
require 'support/models'
require 'attributes_hash_spec_helpers'