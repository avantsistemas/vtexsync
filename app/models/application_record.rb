class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Obtém uma identificação simples do objeto para ser
  # usada em mensagens de log. Ex: user=68, business=17.
  def inspectid
    "#{model_name.singular}=#{id}"
  end
end
