require "active_record"
require 'active_support/core_ext/class/attribute_accessors'

$LOAD_PATH.unshift(File.dirname(__FILE__))

require "acts_as_taggable_on_padrino/taggable"
require "acts_as_taggable_on_padrino/taggable/core"
require "acts_as_taggable_on_padrino/taggable/collection"
require "acts_as_taggable_on_padrino/taggable/cache"
require "acts_as_taggable_on_padrino/taggable/ownership"
require "acts_as_taggable_on_padrino/taggable/related"
require "acts_as_taggable_on_padrino/taggable/tag_list"

require "acts_as_taggable_on_padrino/tagger"
require "acts_as_taggable_on_padrino/tag"
require "acts_as_taggable_on_padrino/tags_helper"
require "acts_as_taggable_on_padrino/tagging"

$LOAD_PATH.shift

ActiveRecord::Base.extend ActsAsTaggableOnPadrino::Taggable
ActiveRecord::Base.extend ActsAsTaggableOnPadrino::Tagger
ActiveRecord::Base.extend ActsAsTaggableOnPadrino::Tag
ActiveRecord::Base.extend ActsAsTaggableOnPadrino::Tagging

if defined?(Padrino::Helpers::TagHelpers)
  Padrino::Helpers::TagHelpers.send :include, ActsAsTaggableOnPadrino::TagsHelper
end

module ActsAsTaggableOnPadrino
  def like_operator
    @like_operator ||= (ActiveRecord::Base.connection.adapter_name == 'PostgreSQL' ? 'ILIKE' : 'LIKE')
  end
  module_function :like_operator
end

begin
  require 'padrino-gen'
  Padrino::Tasks.files << Dir[File.dirname(__FILE__) + "/tasks/**/*.rb"]
rescue LoadError
end