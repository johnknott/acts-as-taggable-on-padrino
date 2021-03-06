module ActsAsTaggableOnPadrino::Taggable
  module Collection
    def self.included(base)
      base.send :include, ActsAsTaggableOnPadrino::Taggable::Collection::InstanceMethods
      base.extend ActsAsTaggableOnPadrino::Taggable::Collection::ClassMethods
      base.initialize_acts_as_taggable_on_collection
    end

    module ClassMethods
      def initialize_acts_as_taggable_on_collection
        tag_types.each do |tag_type|
          singular_tag_type = tag_type.to_s.singularize
          class_eval %(
            def self.#{singular_tag_type}_counts(options={})
              tag_counts_on('#{tag_type}', options)
            end

            def #{singular_tag_type}_counts(options = {})
              tag_counts_on('#{tag_type}', options)
            end

            def top_#{tag_type}(limit = 10)
              tag_counts_on('#{tag_type}', :order => 'count desc', :limit => limit.to_i)
            end

            def self.top_#{tag_type}(limit = 10)
              tag_counts_on('#{tag_type}', :order => 'count desc', :limit => limit.to_i)
            end
          )
        end
      end

      def acts_as_taggable_on(*args)
        super
        initialize_acts_as_taggable_on_collection
      end

      def tag_counts_on(context, options = {})
        all_tag_counts(options.merge({:on => context.to_s}))
      end

      ##
      # Calculate the tag counts for all tags.
      #
      # @param [Hash] options Options:
      #                       * :start_at   - Restrict the tags to those created after a certain time
      #                       * :end_at     - Restrict the tags to those created before a certain time
      #                       * :conditions - A piece of SQL conditions to add to the query
      #                       * :limit      - The maximum number of tags to return
      #                       * :order      - A piece of SQL to order by. Eg 'tags.count desc' or 'taggings.created_at desc'
      #                       * :at_least   - Exclude tags with a frequency less than the given value
      #                       * :at_most    - Exclude tags with a frequency greater than the given value
      #                       * :on         - Scope the find to only include a certain context
      def all_tag_counts(options = {})
        options.assert_valid_keys :start_at, :end_at, :conditions, :at_least, :at_most, :order, :limit, :on, :id

        ## Generate scope:
        tagging_scope = ActsAsTaggableOnPadrino::Tagging.select("#{tagging_table_name}.tag_id, COUNT(#{tagging_table_name}.tag_id) AS tags_count").
            joins("INNER JOIN #{table_name} ON #{table_name}.#{primary_key} = #{tagging_table_name}.taggable_id").
            where(:taggable_type => base_class.name)
        tagging_scope = tagging_scope.where(table_name => {inheritance_column => name}) unless descends_from_active_record? # Current model is STI descendant, so add type checking to the join condition
        tagging_scope = tagging_scope.where(:taggable_id => options.delete(:id)) if options[:id]
        tagging_scope = tagging_scope.where(:context => options.delete(:on).to_s) if options[:on]
        tagging_scope = tagging_scope.where(["#{tagging_table_name}.created_at >= ?", options.delete(:start_at)]) if options[:start_at]
        tagging_scope = tagging_scope.where(["#{tagging_table_name}.created_at <= ?", options.delete(:end_at)]) if options[:end_at]

        tag_scope = ActsAsTaggableOnPadrino::Tag.select("#{tag_table_name}.*, #{tagging_table_name}.tags_count AS count").order(options[:order]).limit(options[:limit])
        tag_scope.where(options[:conditions]) if options[:conditions]

        # GROUP BY and HAVING clauses:
        at_least  = sanitize_sql(['tags_count >= ?', options.delete(:at_least)]) if options[:at_least]
        at_most   = sanitize_sql(['tags_count <= ?', options.delete(:at_most)]) if options[:at_most]
        having    = ["COUNT(#{tagging_table_name}.tag_id) > 0", at_least, at_most].compact.join(' AND ')

        # Append the current scope to the scope, because we can't use scope(:find) in RoR 3.0 anymore:
        tagging_scope = tagging_scope.where(:taggable_id => select("#{table_name}.#{primary_key}")).
                                      group("#{tagging_table_name}.tag_id").
                                      having(having)

        tag_scope = tag_scope.joins("JOIN (#{tagging_scope.to_sql}) AS taggings ON taggings.tag_id = tags.id")
        tag_scope
      end
    end

    module InstanceMethods
      def tag_counts_on(context, options={})
        self.class.tag_counts_on(context, options.merge(:id => id))
      end
    end
  end
end