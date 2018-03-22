require 'ffi'
require 'nameko/node.rb'

module Nameko
  #  This class is providing a parse method.
  #    require 'nameko'
  #
  #    mecab = Nameko::Mecab.new
  #    mecab.parse("私以外私じゃないの")
  #   # =>
  #   [
  #     #<MecabNode:0x00007f8f51117348>,
  #     #<MecabNode:0x00007f8f51116d30>,
  #     #<MecabNode:0x00007f8f51115610>,
  #     #<MecabNode:0x00007f8f51115138>,
  #     #<MecabNode:0x00007f8f51123fa8>,
  #     #<MecabNode:0x00007f8f51123be8>
  #   ]
  #

  class Mecab
    extend FFI::Library
    ffi_lib 'mecab'

    attach_function :mecab_new2, [:string], :pointer
    attach_function :mecab_destroy, [:pointer], :void
    attach_function :mecab_sparse_tonode, [:pointer, :string], :pointer

    def self.destroy(mecab)
      proc {
        mecab_destory(mecab)
      }
    end

    # Initialize the mecab tagger with the given option.
    #
    # How to specify options is as follows:
    #
    # @example
    #   mecab = Nameko::Mecab.new("-d /usr/local/lib/mecab/dic/mecab-ipadic-neologd")
    #   mecab = Nameko::Mecab.new(["-d /usr/local/lib/mecab/dic/mecab-ipadic-neologd"])
    #   mecab = Nameko::Mecab.new(["-d", "/usr/local/lib/mecab/dic/mecab-ipadic-neologd"])
    #
    #
    def initialize(option = '')
      option = option.join(' ') if option.is_a? Array

      @mecab = mecab_new2(option)
      ObjectSpace.define_finalizer(self, Mecab.destroy(@mecab))
    end

    # Parse the given string by MeCab.
    # @param [String] str Parsed text
    # @return [Array<MecabNode>] Result of Mecab parsing
    #
    # @example
    #   node = mecab.parse("私以外私じゃないの")[0]
    #
    #   node.surface # => "私"
    #   node.feature #=> {:pos=>"名詞", :pos1=>"代名詞", :pos2=>"一般", :pos3=>"", :conjugation_form=>"", :conjugation=>"", :base=>"私", :yomi=>"ワタシ", :pronunciation=>"ワタシ"}
    #   node.posid #=> 59
    #   node.id #=> 1
    #

    def parse(str)
      node = MecabNode.new mecab_sparse_tonode(@mecab, str)
      result = []

      while !node.null? do
        if node.surface.empty?
          node = node.next
          next
        end
        result << node
        node = node.next
      end

      result
    end

    private

    def analyze(mecab_row)
      mecab_row.split("\n").select{ |m| m != "EOS"}.map do |sentence|
        sentence.match(/
          ^
          (?<surface>[^\t]+)
          \t
          (?:
            (?<pos>[^,]+),
            \*?(?<pos1>[^,]*),
            \*?(?<pos2>[^,]*),
            \*?(?<pos3>[^,]*),
            \*?(?<conjugation_form>[^,]*),
            \*?(?<conjugation>[^,]*),
            (?<base>[^,]*)
            (?:
              ,(?<yomi>[^,]*)
              ,(?<pronunciation>[^,]*)
            )?
          )?
          /x) do |md|
          md.named_captures.map{ |k, v| [k.to_sym, v] }.to_h
        end
      end
    end

    def fill_up(analysis)
      analysis.map do |parsed|
        if !parsed[:yomi] && parsed[:surface].match(/\p{katakana}+/)
          parsed[:yomi] = parsed[:surface]
          parsed[:pronunciation] = parsed[:surface]
        end
        parsed
      end
    end
  end
end
