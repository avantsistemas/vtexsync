module Vtex
  module Sync
    module Logger
      delegate :logger, to: Rails

      def log_what_will_be_synced(model)
        if model.new_record?
          log_model_will_be_created(model)
        elsif model.changed?
          log_model_will_be_updated(model)
        else
          log_model_already_synced(model)
        end
      end

      def log_model_will_be_created(model)
        model_name = model.model_name.human.downcase
        attributes = model.attributes.except('id', 'created_at', 'updated_at')
        logger.info "#{model_name} será cadastrado(a) #{attributes.as_json}"
      end

      def log_model_will_be_updated(model)
        model_name = model.model_name.human.downcase
        logger.info "#{model_name} será atualizado(a) #{model.changes.as_json}"
      end

      def log_model_already_synced(model)
        model_name = model.model_name.human.downcase
        logger.debug "#{model_name} já está atualizado(a)"
      end
    end
  end
end
