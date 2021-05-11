require "spec"
require "shaq"

struct Enum
  macro expose_values
    {% for c in @type.constants %}
      {{c}} = {{@type}}::{{c}}.value
    {% end %}
  end
end

def subject(obj, &block)
  with obj yield
end

include Shaq
Square.expose_values
