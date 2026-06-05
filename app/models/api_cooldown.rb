# Cooldown compartilhado por API externa. Quando uma API responde 429,
# registramos até quando devemos parar de bater nela. Os clientes consultam esse
# "portão" antes de cada requisição, de modo que um único 429 evite que toda uma
# fila de jobs já enfileirados repita a chamada e leve o mesmo erro.
#
# Cada serviço é identificado por `name` (ex.: "vtex"), com uma única linha por
# serviço garantida pelo índice único.
class ApiCooldown < ApplicationRecord
  # Abre um cooldown de `seconds` segundos a partir de agora para o serviço.
  #
  # Tradeoff conhecido: esta chamada sobrescreve o cooldown atual. Em respostas
  # 429 concorrentes com Retry-After diferentes, uma resposta posterior com
  # espera menor pode encurtar uma janela maior já registrada. Aceitamos esse
  # risco por enquanto para manter a implementação simples.
  def self.cool_down!(name, seconds)
    singleton(name).update!(cooled_down_until: Time.current + seconds)
  end

  # O serviço está dentro de uma janela de cooldown ativa?
  def self.cooling_down?(name)
    retry_after_seconds(name).positive?
  end

  # Segundos restantes de cooldown (0 quando não há cooldown ativo).
  def self.retry_after_seconds(name)
    record = find_by(name: name)
    return 0 if record.nil? || record.cooled_down_until.nil?

    remaining = (record.cooled_down_until - Time.current).ceil
    remaining.positive? ? remaining : 0
  end

  # Recupera (ou cria, à prova de corrida via índice único) a linha do serviço.
  def self.singleton(name)
    create_or_find_by!(name: name)
  end
  private_class_method :singleton
end
