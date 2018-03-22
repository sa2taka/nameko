require "ffi"

module Nameko
  #  This class is providing a parse method.
  #   require 'nameko'
  #
  #   mecab = Nameko::Mecab.new
  #   mecab.parse("私以外私じゃないの。")
  #
  #   [
  #     {:surface=>'私', :pos=>'名詞', :pos1=>'代名詞', :pos2=>'一般', :pos3=>'', :conjugation_form=>'', :conjugation=>'', :base=>'私', :yomi=>'ワタシ', :pronunciation=>'ワタシ'},
  #     {:surface=>'以外', :pos=>'名詞', :pos1=>'非自立', :pos2=>'副詞可能', :pos3=>'', :conjugation_form=>'', :conjugation=>'', :base=>'以外', :yomi=>'イガイ', :pronunciation=>'イガイ'},
  #     {:surface=>'私', :pos=>'名詞', :pos1=>'代名詞', :pos2=>'一般', :pos3=>'', :conjugation_form=>'', :conjugation=>'', :base=>'私', :yomi=>'ワタシ', :pronunciation=>'ワタシ'},
  #     {:surface=>'じゃ', :pos=>'助詞', :pos1=>'副助詞', :pos2=>'', :pos3=>'', :conjugation_form=>'', :conjugation=>'', :base=>'じゃ', :yomi=>'ジャ', :pronunciation=>'ジャ'},
  #     {:surface=>'ない', :pos=>'助動詞', :pos1=>'', :pos2=>'', :pos3=>'', :conjugation_form=>'特殊・ナイ', :conjugation=>'基本形', :base=>'ない', :yomi=>'ナイ', :pronunciation=>'ナイ'},
  #     {:surface=>'の', :pos=>'助詞', :pos1=>'終助詞', :pos2=>'', :pos3=>'', :conjugation_form=>'', :conjugation=>'', :base=>'の', :yomi=>'ノ', :pronunciation=>'ノ'},
  #     {:surface=>'。',:pos=>'記号', :pos1=>'句点', :pos2=>'', :pos3=>'', :conjugation_form=>'', :conjugation=>'', :base=>'。', :yomi=>'。', :pronunciation=>'。'},
  #   ]
  #

  class Mecab
    extend FFI::Library
    ffi_lib 'mecab'

    attach_function :mecab_new2, [:string], :pointer
    attach_function :mecab_destroy, [:pointer], :void
    attach_function :mecab_sparse_tostr, [:pointer, :string], :string

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
    # @return [Array<Hash>] Result of Mecab parsing
    #
    # The return value is array of hash.
    #
    # The hash keys meaning is as follows(The key is symbol):
    #   surface: 表層系(Surface)
    #   pos: 品詞(Part of speech)
    #   pos1: 品詞細分類1(Part of speech subcategory1)
    #   pos2: 品詞細分類2(Part of speech subcategory2)
    #   pos3: 品詞細分類3(Part of speech subcategory3)
    #   conjugation_form: 活用形(Conjugation form)
    #   conjugation: 活用形(conjucation)
    #   base: 基本形・原型(Lexical form)
    #   yomi: 読み(Reading)
    #   pronunciation: 発音(Pronunciation)

    def parse(str)
      mecab_row = mecab_sparse_tostr(@mecab, str).force_encoding(Encoding.default_external)
      analysis_result = analyze(mecab_row)
      fill_up(analysis_result)
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
            md.named_captures.map{|k,v| [k.to_sym, v] }.to_h
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
