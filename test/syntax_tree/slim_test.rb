require "test_helper"
require "slim"

SOURCE = <<SLIM
div
  span.uschi Moin
  span#dubbi.murksi#dubbi dabbi = "pabbi"
    = 'string'
  span dabbi = "pabbi"
SLIM

class SyntaxTree::SlimTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::SyntaxTree::Slim::VERSION
  end

  def test_it_does_something_useful
    sexp = Slim::Parser.new.call(SOURCE)
    # extractor = RubyExtractor.new
    # extracted_source = extractor.extract(processed_sexp)
    buffer = consume(sexp, 0)
    puts buffer
  end

  private

  def consume(ast, level)
    puts "eating #{ast}"
    return if ast.empty?
    indent = "  " * level

    case ast
    in [:multi, *rest]
      rest.map { |a| consume(a, level) }.join("")
    in [:slim, :text, :inline, *rest]
      " #{rest.map { |a| consume(a, level) }.join("\n")}"
    in [:slim, :interpolate, text]
      text
    in [:slim, :output, _, code, *rest]
      "#{indent}#{eval(code)}#{rest.map { |a| consume(a, level + 1) }.join("\n")}"
    in [:html, :attrs, *attrs]
      attrs.map { |attr| consume(attr, level) }.join(" ")
    in [:html, :attr, "class", Array => values]
      ".#{consume(values, level)}"
    in [:html, :attr, "id", Array => values]
      "##{consume(values, level)}"
    in [:html, :attr, name, Array => values]
      "#{name}=\"#{consume(values, level)}\""
    in [:static, value]
      value
    in [:escape, _, Array => rest]
      consume(rest, level)
    in [:html, :tag, name, Array => attrs, *rest]
      "#{indent}#{name}#{consume(attrs, level)}#{rest.map { |a| consume(a, level + 1) }.join("\n")}"
    in [:newline, *rest]
      "\n#{consume(rest, level)}"
    else
      puts "EEEELSE"
      pp ast
      ""
    end
  end
end

# class RubyExtractor
#   include SexpVisitor
#   extend SexpVisitor::DSL

#   # Stores the extracted source and a map of lines of generated source to the
#   # original source that created them.
#   #
#   # @attr_reader source [String] generated source code
#   # @attr_reader source_map [Hash] map of line numbers from generated source
#   #   to original source line number
#   RubySource = Struct.new(:source, :source_map)

#   # Extracts Ruby code from Sexp representing a Slim document.
#   #
#   # @param sexp [SlimLint::Sexp]
#   # @return [SlimLint::RubyExtractor::RubySource]
#   def extract(sexp)
#     trigger_pattern_callbacks(sexp)
#     RubySource.new(@source_lines.join("\n"), @source_map)
#   end

#   on_start do |_sexp|
#     @source_lines = []
#     @source_map = {}
#     @line_count = 0
#     @dummy_puts_count = 0
#   end

#   on %i[html doctype] do |sexp|
#     append_dummy_puts(sexp)
#   end

#   on %i[html tag] do |sexp|
#     append_dummy_puts(sexp)
#   end

#   on [:static] do |sexp|
#     append_dummy_puts(sexp)
#   end

#   on [:dynamic] do |sexp|
#     _, ruby = sexp
#     append(ruby, sexp)
#   end

#   on [:code] do |sexp|
#     _, ruby = sexp
#     append(ruby, sexp)
#   end

#   private

#   # Append code to the buffer.
#   #
#   # @param code [String]
#   # @param sexp [SlimLint::Sexp]
#   def append(code, sexp)
#     return if code.empty?

#     original_line = sexp.line

#     # For code that spans multiple lines, the resulting code will span
#     # multiple lines, so we need to create a mapping for each line.
#     code
#       .split("\n")
#       .map_with_index do |line, index|
#         @source_lines << line
#         @line_count += 1
#         @source_map[@line_count] = original_line + index
#       end
#   end

#   def append_dummy_puts(sexp)
#     append("_slim_lint_puts_#{@dummy_puts_count}", sexp)
#     @dummy_puts_count += 1
#   end
# end
