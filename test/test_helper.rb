require 'rubygems'
require 'test/unit'
require 'pp'
require 'bundler/setup'

require 'test_declarative'
require 'minimal'

alias :require_dependency :require

Minimal::Template.class_eval do
  include Minimal::Template::FormBuilderProxy
  include Minimal::Template::TranslatedTags
end
ActionView::Template.register_template_handler('rb', Minimal::Template::Handler)

ActionView::Base.class_eval { def protect_against_forgery?; false end } # HAX

VIEW_PATH = File.expand_path('../fixtures/views', __FILE__)
