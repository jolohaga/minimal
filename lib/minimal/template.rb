class Minimal::Template
  autoload :BeautifyHtml,     'minimal/template/beautify_html'
  autoload :FormBuilderProxy, 'minimal/template/form_builder_proxy'
  autoload :Handler,          'minimal/template/handler'
  autoload :TranslatedTags,   'minimal/template/translated_tags'

  AUTO_BUFFER = %r(render|tag|error_message_|select|debug|_to|[^l]_for)
  TAG_NAMES   = %w(a body div em fieldset h1 h2 h3 h4 h5 h6 head html img input label li link
    ol option p pre script select span strong table thead tbody tfoot td title th tr ul)

  module Base
    attr_accessor :view, :locals, :block

    def initialize(view = nil)
      @view, @locals, @_auto_buffer = view, {}, {}
    end

    def _render(locals = nil, format = :html, &block)
      @locals = locals || {}
      self.block = lambda { |*args| self << block.call(*args) }
      send(:"to_#{format}", &self.block)
      view.output_buffer
    end

    TAG_NAMES.each do |name|
      define_method(name) { |*args, &block| content_tag(name, *args, &block) }
      define_method("#{name}_for") { |*args, &block| content_tag_for(name, *args, &block) }
    end

    def <<(output)
      view.output_buffer << output
    end

    def respond_to?(method)
      view.respond_to?(method) || locals.key?(method) || view.instance_variable_defined?("@#{method}")
    end

    protected

      def method_missing(method, *args, &block)
        locals.key?(method) ? locals[method] :
          view.instance_variable_defined?("@#{method}") ? view.instance_variable_get("@#{method}") :
          view.respond_to?(method) ? call_view(method, *args, &block) : super
      end

      def call_view(method, *args, &block)
        view.send(method, *args, &block).tap { |result| self << result if auto_buffer?(method) }
      end

      def auto_buffer?(method)
        @_auto_buffer.key?(method) ? @_auto_buffer[method] : @_auto_buffer[method] = AUTO_BUFFER =~ method.to_s
      end
  end
  include Base
end