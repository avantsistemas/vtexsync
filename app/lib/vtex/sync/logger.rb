module Vtex
  module Sync
    class Logger
      class << self
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
          attributes = model.attributes.except('id', 'created_at', 'updated_at')
          message = colorful_message("#{model.model_name.singular} será cadastrado(a)", :green, true)
          logger.info "#{message} #{attributes.as_json}"
        end

        def log_model_will_be_updated(model)
          message = colorful_message("#{model.inspectid} será atualizado(a)", :yellow, true)
          logger.info "#{message} #{model.changes.as_json}"
        end

        def log_model_will_be_destroyed(model)
          attributes = model.attributes.except('id', 'created_at', 'updated_at')
          message = colorful_message("#{model.inspectid} será excluído(a)", :red, true)
          logger.info "#{message} #{attributes.as_json}"
        end

        def log_model_already_synced(model)
          logger.debug { colorful_message("#{model.inspectid} já está atualizado(a)", :black, true) }
        end

        def colorful_message(message, color, bold = false)
          ActiveSupport::LogSubscriber.new.send(:color, message, color, bold)
        end
      end
    end
  end
end
