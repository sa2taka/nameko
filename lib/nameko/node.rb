# This class define Node struct
# Nameko::Mecab#parse method return it.
class MecabNode < FFI::Struct
  layout  :prev,      :pointer,
          :next,      :pointer,
          :enext,     :pointer,
          :bnext,     :pointer,
          :rpath,     :pointer,
          :lpath,     :pointer,
          :surface,   :string,
          :feature,   :string,
          :id,        :uint,
          :length,    :ushort,
          :rlength,   :ushort,
          :rcAttr,    :ushort,
          :lcAttr,    :ushort,
          :posid,     :ushort,
          :char_type, :uchar,
          :stat,      :uchar,
          :isbest,    :uchar,
          :alpha,     :float,
          :beta,      :float,
          :prob,      :float,
          :wcost,     :short,
          :cost,      :long

  def feature
    feature = self[:feature].force_encoding(Encoding.default_external).match(/
      ^
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

    fill_up(feature)
  end

  def next
    MecabNode.new self[:next]
  end

  def surface
    self[:surface][0...self[:length]].force_encoding(Encoding.default_external)
  end

  private

  def fill_up(analysis)
    if !analysis[:yomi] && analysis[:surface].match(/\p{katakana}+/)
      analysis[:yomi] = analysis[:surface]
      analysis[:pronunciation] = analysis[:surface]
    end
    analysis
  end

  def to_s
    self[:surface]
  end

  def to_ary
    [self[:surface]]
  end

  private

  def method_missing(key)
    self[key]
  end
end
