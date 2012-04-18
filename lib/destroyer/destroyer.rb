module Destroyer
  def self.included(target)
    target.extend Destroyer::ClassMethods
  end

  module ClassMethods
    attr_accessor :destroyer_block, :destroyer_options

    def destroyer(block, options = {})
      @destroyer_block = block
      @destroyer_default_block ||= @destroyer_block
      @destroyer_options = options
      @destroyer_default_options ||= @destroyer_options
    end

    def start_destroyer
      return unless @destroyer_default_block
      let_the_destroyer_starts((@destroyer_block || @destroyer_default_block).call)
      @destroyer_block = nil
      @destroyer_options = {}
    end

    def has_one_with_destroy
      @has_one_with_destroy ||= reflect_on_all_associations(:has_one).select {|a| a.options[:dependent] == :destroy && !a.options[:through] }.map(&:klass)
    end

    def has_many_with_destroy
      @has_many_with_destroy ||= reflect_on_all_associations(:has_many).select {|a| a.options[:dependent] == :destroy && !a.options[:through] }.map(&:klass)
    end

    def has_many_through_with_destroy
      @has_many_through_with_destroy ||= reflect_on_all_associations(:has_many).select {|a| a.options[:dependent] == :destroy && a.options[:through] }.map(&:through_reflection).map(&:klass)
    end

    def all_destroyables
      has_one_with_destroy + has_many_with_destroy + has_many_through_with_destroy
    end

  private
    def let_the_destroyer_starts(ids)
      destroy_associations(self, ids)
      ids.each_slice(destroyer_batch_size) {|group| delete_all(["#{primary_key} IN (?)", group])}
    end

    def destroy_associations(_class, ids)
      _class.all_destroyables.each do |association|
        _foreign_key = _class.reflect_on_association(association).try(:options).try(:[], :foreign_key) || "#{_class.table_name.singularize}_id"
        association.select("#{association.primary_key}").where(["#{_foreign_key} IN (?)", ids])
          .find_in_batches(:batch_size => destroyer_batch_size) do |association_ids|
            destroy_associations(association, association_ids.map(&association.primary_key.to_sym))
        end
        association.delete_all(["#{_foreign_key} IN (?)", ids])
      end
    end

    def destroyer_batch_size
      @destroyer_options[:batch_size] || @destroyer_default_options[:batch_size] || 1000
    end
  end
end