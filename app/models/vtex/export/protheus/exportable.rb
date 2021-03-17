module Vtex
  module Export
    module Protheus
      class Exportable
        COL_SEP = ';'.freeze
        SEP_REP = ','.freeze

        def to_txt
          prepared_data.join(COL_SEP)
        end

        private

        def prepared_data
          data_array.map do |data|
            I18n.transliterate data.to_s.upcase.tr(COL_SEP, SEP_REP)
          end
        end

        def data_array
          raise NotImplementedError, "implementar #data_array em #{self.class}"
        end
      end
    end
  end
end
