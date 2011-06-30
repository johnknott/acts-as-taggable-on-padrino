module ActsAsTaggableOnPadrino
  module Taggable
    def taggable?
      false
    end

    ##
    # This is an alias for calling <tt>acts_as_taggable_on_padrino :tags</tt>.
    #
    # Example:
    #   class Book < ActiveRecord::Base
    #     acts_as_taggable
    #   end
    def acts_as_taggable(opts = {})
      acts_as_taggable_on :tags, opts
    end

    ##
    # Make a model taggable on specified contexts.
    #
    # @param [Array] tag_types An array of taggable contexts
    #
    # Example:
    #   class User < ActiveRecord::Base
    #     acts_as_taggable_on_padrino :languages, :skills
    #   end
    def acts_as_taggable_on(*tag_types)
      opts = tag_types.extract_options!
      opts.assert_valid_keys :tag, :tagging

      tag_types = tag_types.to_a.flatten.compact.map {|type| type.to_sym }

      if taggable?
        write_inheritable_attribute(:tag_types, (self.tag_types + tag_types).uniq)
      else
        opts.reverse_merge!(:tag => 'Tag', :tagging => 'Tagging')
        tag_class_name = opts[:tag]
        tagging_class_name = opts[:tagging]
        tag = tag_class_name.constantize
        tagging = tagging_class_name.constantize

        write_inheritable_attribute(:tag_types, tag_types)
        write_inheritable_attribute(:acts_as_taggable_on_tag_model, tag)
        write_inheritable_attribute(:acts_as_taggable_on_tagging_model, tagging)
        class_inheritable_reader(:tag_types, :acts_as_taggable_on_tagging_model, :acts_as_taggable_on_tag_model)

        class_eval do
          has_many :taggings, :as => :taggable, :dependent => :destroy, :include => :tag, :class_name => tagging_class_name
          has_many :base_tags, :through => :taggings, :source => :tag, :class_name => tag_class_name

          def self.taggable?
            true
          end

          include ActsAsTaggableOnPadrino::Taggable::Core
          include ActsAsTaggableOnPadrino::Taggable::Collection
          include ActsAsTaggableOnPadrino::Taggable::Cache
          include ActsAsTaggableOnPadrino::Taggable::Ownership
          include ActsAsTaggableOnPadrino::Taggable::Related
        end
      end
    end
  end
end
