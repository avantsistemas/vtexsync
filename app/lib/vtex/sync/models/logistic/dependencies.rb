module Vtex
  module Sync
    module Models
      class Logistic
        module Dependencies
          private

          def sync_dependencies
            sync_sla
          end

          def sync_sla
            sla_attributes = find_sla_attributes
            vtex_sla = Sla.new(sla_attributes).sync
            vtex_logistic.sla = vtex_sla
          end

          def find_sla_attributes
            selected_sla = logistic_attributes['selectedSla']
            logistic_attributes['slas'].find { |sla| sla['id'] == selected_sla }
          end
        end
      end
    end
  end
end
