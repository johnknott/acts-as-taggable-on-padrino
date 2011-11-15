module ActsAsTaggableOnPadrino
  module Taggable
    def taggable?
      false
    end

    ##
    # This is an alias for calling <tt>acts_as_taggable_on :tags</tt>.
    #
    # Example:
    #   class Book < ActiveRecord::Base
    #     acts_as_taggable
    #   end
    def acts_as_taggable
      acts_as_taggable_on :tags
    end

    ##
    # Make a model taggable on specified contexts.
    #
    # @param [Array] tag_types An array of taggable contexts
    #
    # Example:
    #   class User < ActiveRecord::Base
    #     acts_as_taggable_on :languages, :skills
    #   end
    def acts_as_taggable_on(*tag_types)
      tag_types = tag_types.to_a.flatten.compact.map {|type| type.to_sym }

      if taggable?
        # write_inheritable_attribute(:tag_types, (self.tag_types + tag_types).uniq)
        self.tag_types = (self.tag_types + tag_types).uniq
      else
        class_attribute :tag_types
        self.tag_types = tag_types
        class_attribute :tag_table_name
        self.tag_table_name = ActsAsTaggableOnPadrino::Tag.table_name
        class_attribute :tagging_table_name
        self.tagging_table_name = ActsAsTaggableOnPadrino::Tagging.table_name

        Tag.like_operator = 'ILIKE' if Tag.using_postgresql?

        class_eval do
          has_many :taggings, :as => :taggable, :dependent => :destroy, :include => :tag, :class_name => "ActsAsTaggableOnPadrino::Tagging"
          has_many :base_tags, :through => :taggings, :source => :tag, :class_name => "ActsAsTaggableOnPadrino::Tag"

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
