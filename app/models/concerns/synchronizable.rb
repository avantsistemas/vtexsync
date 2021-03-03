module Synchronizable
  extend ActiveSupport::Concern
  extend ActiveModel::Callbacks

  included do
    define_model_callbacks :sync_attributes
  end

  class_methods do
    def sync_attributes(*attributes)
      @synced_attributes = attributes
    end
    attr_reader :synced_attributes

    def remap_attributes(remaped_attributes)
      @remaped_attributes = remaped_attributes
    end
    attr_reader :remaped_attributes
  end

  def sync_attributes(attributes)
    run_callbacks(:sync_attributes) do
      attributes = attributes.with_indifferent_access
      slice_attributes!(attributes)
      remap_attributes!(attributes)
      underscore_attributes!(attributes)
      assign_attributes(attributes)
    end
  end

  private

  def slice_attributes!(attributes)
    attributes.slice!(*self.class.synced_attributes)
  end

  def remap_attributes!(attributes)
    return unless self.class.remaped_attributes

    self.class.remaped_attributes.each do |old_name, new_name|
      attributes[new_name] = attributes.delete(old_name) if attributes.key?(old_name)
    end
  end

  def underscore_attributes!(attributes)
    attributes.transform_keys!(&:underscore)
  end
end
