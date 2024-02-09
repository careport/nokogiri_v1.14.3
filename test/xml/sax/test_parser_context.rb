# -*- coding: utf-8 -*-
# frozen_string_literal: true

require "helper"

module Nokogiri
  module XML
    module SAX
      class TestParserContext < Nokogiri::SAX::TestCase
        def setup
          super
          @xml = <<~EOF
            <hello>

            world
            <inter>
                <net>
                </net>
            </inter>

            </hello>
          EOF
        end

        class Counter < Nokogiri::XML::SAX::Document
          attr_accessor :context, :lines, :columns

          def initialize
            super
            @context = nil
            @lines   = []
            @columns = []
          end

          def start_element(name, attrs = [])
            @lines << [name, context.line]
            @columns << [name, context.column]
          end
        end

        def test_line_numbers
          sax_handler = Counter.new

          parser = Nokogiri::XML::SAX::Parser.new(sax_handler)
          parser.parse(@xml) do |ctx|
            sax_handler.context = ctx
          end

          assert_equal([["hello", 1], ["inter", 4], ["net", 5]],
            sax_handler.lines)
        end

        def test_column_numbers
          sax_handler = Counter.new

          parser = Nokogiri::XML::SAX::Parser.new(sax_handler)
          parser.parse(@xml) do |ctx|
            sax_handler.context = ctx
          end

          assert_equal([["hello", 7], ["inter", 7], ["net", 9]],
            sax_handler.columns)
        end

        def test_replace_entities
          pc = ParserContext.new(StringIO.new("<root />"), "UTF-8")
          pc.replace_entities = false
          refute(pc.replace_entities)

          pc.replace_entities = true
          assert(pc.replace_entities)
        end

        def test_recovery
          pc = ParserContext.new(StringIO.new("<root />"), "UTF-8")
          pc.recovery = false
          refute(pc.recovery)

          pc.recovery = true
          assert(pc.recovery)
        end

        def test_graceful_handling_of_invalid_types
          assert_raises(TypeError) { ParserContext.new(0xcafecafe) }
          assert_raises(TypeError) { ParserContext.memory(0xcafecafe) }
          assert_raises(TypeError) { ParserContext.io(0xcafecafe, 1) }
          assert_raises(TypeError) { ParserContext.io(StringIO.new("asdf"), "should be an index into ENCODINGS") }
        end

        def test_from_io
          ctx = ParserContext.new(StringIO.new("fo"), "UTF-8")
          assert(ctx)
        end

        def test_from_string
          assert(ParserContext.new("blah blah"))
        end

        def test_parse_with
          ctx = ParserContext.new("blah")
          assert_raises(ArgumentError) do
            ctx.parse_with(nil)
          end
        end

        def test_parse_with_sax_parser
          xml = "<root />"
          ctx = ParserContext.new(xml)
          parser = Parser.new(Doc.new)
          assert_nil(ctx.parse_with(parser))
        end

        def test_from_file
          ctx = ParserContext.file(XML_FILE)
          parser = Parser.new(Doc.new)
          assert_nil(ctx.parse_with(parser))
        end

        def test_parse_with_returns_nil
          xml = "<root />"
          ctx = ParserContext.new(xml)
          parser = Parser.new(Doc.new)
          assert_nil(ctx.parse_with(parser))
        end
      end
    end
  end
end
