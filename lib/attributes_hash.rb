require 'attributes_hash/version'

require 'active_record'

require 'attributes_hash/active_record_base_extensions'
require 'attributes_hash/active_record_relation_extensions'
require 'attributes_hash/attributes_hash'

module AttributesHash
  # Your code goes here...
end

::ActiveRecord::Base.send(:include, AttributesHash::ActiveRecordBaseExtensions)
::ActiveRecord::Relation.send(:include, AttributesHash::ActiveRecordRelationExtensions)
::ActiveRecord::Base.send(:include, AttributesHash::AttributesHash)
::ActiveRecord::Relation.send(:include, AttributesHash::AttributesHash)