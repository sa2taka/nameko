# Nameko

Ruby binding for MeCab, Part-of-Speech and Morphological Analyzer.

Note:Nameko means "NAtto ya MEcab-gem yori KOkateki - NattoやMecab-gemより効果的(It is more effective than Natto or Mecab-gem)".

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'nameko'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nameko

## Usage

```ruby
require 'nameko'

mecab = Nameko::Mecab.new
mecab.parse("私以外私じゃないの")
# =>
#   [
#     #<MecabNode:0x00007f8f51117348>,
#     #<MecabNode:0x00007f8f51116d30>,
#     #<MecabNode:0x00007f8f51115610>,
#     #<MecabNode:0x00007f8f51115138>,
#     #<MecabNode:0x00007f8f51123fa8>,
#     #<MecabNode:0x00007f8f51123be8>
#   ]

node = mecab.parse("私以外私じゃないの")[0]
node.surface # => "私"
node.feature #=> {:pos=>"名詞", :pos1=>"代名詞", :pos2=>"一般", :pos3=>"", :conjugation_form=>"", :conjugation=>"", :base=>"私", :yomi=>"ワタシ", :pronunciation=>"ワタシ"}
node.posid #=> 59
node.id #=> 1
```

Nameko::Mecab#parse returns an array of `MecabNode`.

The MecabNode has `feature` method that return hash.
The hash's keys meaning is as follows(The key is symbol):

+ `pos`: 品詞(Part of speech)
+ `pos1`: 品詞細分類1(Part of speech subcategory1)
+ `pos2`: 品詞細分類2(Part of speech subcategory2)
+ `pos3`: 品詞細分類3(Part of speech subcategory3)
+ `conjugation_form`: 活用形(Conjugation form)
+ `conjugation`: 活用形(conjucation)
+ `base`: 基本形・原型(Lexical form)
+ `yomi`: 読み(Reading)
+ `pronunciation`: 発音(Pronunciation)

### With option

For example, if you use mecab-ipadic-neologd as a mecab dictionary:

```ruby
require 'nameko'

mecab = Nameko::Mecab.new("-d /usr/local/lib/mecab/dic/mecab-ipadic-neologd")  
# mecab = Nameko::Mecab.new(["-d /usr/local/lib/mecab/dic/mecab-ipadic-neologd"])
# mecab = Nameko::Mecab.new(["-d", "/usr/local/lib/mecab/dic/mecab-ipadic-neologd"])

mecab.parse("アラレちゃん").map(&:feature)
# => [{:pos=>"名詞", :pos1=>"固有名詞", :pos2=>"一般", :pos3=>"", :conjugation_form=>"", :conjugation=>"", :base=>"アラレちゃん", :yomi=>"アラレチャン", :pronunciation=>"アラレチャン"}]
```

## Nameko VS. Natto

The key difference between Natto and Nameko is the return value of feature method.

```ruby:Natto
require 'natto'

nm = Natto::MeCab.new

nm.enum_parse("私とあなた").each do |n|
  puts n.feature unless n.is_eos?
end
# =>
名詞,代名詞,一般,*,*,*,私,ワタシ,ワタシ
助詞,格助詞,一般,*,*,*,と,ト,ト
名詞,代名詞,一般,*,*,*,あなた,アナタ,アナタ
```

```ruby:Nameko
require 'nameko'

mecab = Nameko::Mecab.new

mecab.parse("私とあなた").map(&:feature)
# =>
[
  {:pos=>"名詞", :pos1=>"代名詞", :pos2=>"一般", :pos3=>"", :conjugation_form=>"", :conjugation=>"", :base=>"私", :yomi=>"ワタシ", :pronunciation=>"ワタシ"},
  {:pos=>"助詞", :pos1=>"格助詞", :pos2=>"一般", :pos3=>"", :conjugation_form=>"", :conjugation=>"", :base=>"と", :yomi=>"ト", :pronunciation=>"ト"},
  {:pos=>"名詞", :pos1=>"代名詞", :pos2=>"一般", :pos3=>"", :conjugation_form=>"", :conjugation=>"", :base=>"あなた", :yomi=>"アナタ", :pronunciation=>"アナタ"}
]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/sa2taka/nameko. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Nameko project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/nameko/blob/master/CODE_OF_CONDUCT.md).

## Author
[@t0p_l1ght](https://mstdn-workers.com/@t0p_l1ght)
