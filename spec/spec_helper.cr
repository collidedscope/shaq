require "spec"
require "shaq"

struct Enum
  macro expose
    {% for c in @type.constants %}
      {{c}} = {{@type}}::{{c}}
    {% end %}
  end
end

macro subject(obj, &block)
  %obj = {{obj}}
  {% for line in block.body.stringify.lines %}
    %obj.{{line.id}}
  {% end %}
end

include Shaq
Square.expose
