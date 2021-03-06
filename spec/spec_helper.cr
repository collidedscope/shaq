require "spec"
require "shaq"
require "shaq/core_ext/spec"

struct Enum
  macro expose_values
    {% for c in @type.constants %}
      {{c}} = {{@type}}::{{c}}.value
    {% end %}
  end
end

def subject(obj)
  with obj yield
end

def new_game
  with Game.new yield
end

include Shaq
Square.expose_values
Promotion.expose_values
