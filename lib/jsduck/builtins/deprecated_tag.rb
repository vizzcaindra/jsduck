require "jsduck/builtins/tag"

module JsDuck::Builtins
  # Base class for both @deprecated and @removed.  Child classes only
  # need to define the @key attribute and call #super - all the
  # correct behavior will the fall out automatically.
  class DeprecatedTag < Tag
    def initialize
      if @key
        @pattern = @key.to_s
        @signature = {:long => @key.to_s, :short => @key.to_s[0..2].upcase}
        @html_position = :bottom
        @multiline = true
      end
    end

    def parse(p)
      p.add_tag(@key)
      p.skip_horiz_white
      p.current_tag[:version] = p.match(/[0-9.]+/) if p.look(/[0-9]/)
    end

    def process_doc(tags)
      v = {:text => tags[0][:doc] || ""}
      v[:version] = tags[0][:version] if tags[0][:version]
      v
    end

    def to_html(context)
      depr = context[@key]
      v = depr[:version] ? "since " + depr[:version] : ""
      <<-EOHTML
        <div class='signature-box #{@key}'>
        <p>This #{context[:tagname]} has been <strong>#{@key}</strong> #{v}</p>
        #{format(depr[:text])}
        </div>
      EOHTML
    end

  end
end