RSpec.describe Nameko do
  it 'has a version number' do
    expect(Nameko::VERSION).not_to be nil
  end

  it 'parseing result is correct' do
    sentence = '私以外私じゃないの。'
    analysis = [
      {:surface=>'私', :pos=>'名詞', :pos1=>'代名詞', :pos2=>'一般', :pos3=>'', :conjugation_form=>'', :conjugation=>'', :base=>'私', :yomi=>'ワタシ', :pronunciation=>'ワタシ'},
      {:surface=>'以外', :pos=>'名詞', :pos1=>'非自立', :pos2=>'副詞可能', :pos3=>'', :conjugation_form=>'', :conjugation=>'', :base=>'以外', :yomi=>'イガイ', :pronunciation=>'イガイ'},
      {:surface=>'私', :pos=>'名詞', :pos1=>'代名詞', :pos2=>'一般', :pos3=>'', :conjugation_form=>'', :conjugation=>'', :base=>'私', :yomi=>'ワタシ', :pronunciation=>'ワタシ'},
      {:surface=>'じゃ', :pos=>'助詞', :pos1=>'副助詞', :pos2=>'', :pos3=>'', :conjugation_form=>'', :conjugation=>'', :base=>'じゃ', :yomi=>'ジャ', :pronunciation=>'ジャ'},
      {:surface=>'ない', :pos=>'助動詞', :pos1=>'', :pos2=>'', :pos3=>'', :conjugation_form=>'特殊・ナイ', :conjugation=>'基本形', :base=>'ない', :yomi=>'ナイ', :pronunciation=>'ナイ'},
      {:surface=>'の', :pos=>'助詞', :pos1=>'終助詞', :pos2=>'', :pos3=>'', :conjugation_form=>'', :conjugation=>'', :base=>'の', :yomi=>'ノ', :pronunciation=>'ノ'},
      {:surface=>'。',:pos=>'記号', :pos1=>'句点', :pos2=>'', :pos3=>'', :conjugation_form=>'', :conjugation=>'', :base=>'。', :yomi=>'。', :pronunciation=>'。'},
    ]
    expect(Nameko::Mecab.new.parse(sentence)).to eq(analysis)
  end
end
