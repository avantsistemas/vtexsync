# Não salva versões para eventos do tipo `create` nem
# `touch` e não armazena alterações em `updated_at`.
# https://stackoverflow.com/a/59052879/2640073
# https://github.com/paper-trail-gem/paper_trail#2a-choosing-lifecycle-events-to-monitor
PAPER_TRAIL_DEFAULT_SKIP = %i[updated_at].freeze

PaperTrail.config.has_paper_trail_defaults = {
  on: %i[update destroy], skip: PAPER_TRAIL_DEFAULT_SKIP
}
