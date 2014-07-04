require_relative 'helper'

class Appium::Lint
  describe 'Lint' do
    it 'processes globbed files using all lint rules' do
      lint = Appium::Lint.new
      dir  = File.join(Dir.pwd, 'spec', 'data', '**', '*.md')

      actual   = lint.glob dir

      # 1.md has no problems so it doesn't show up in expected failures
      expected = { '0.md' => { 1 => [H2Missing::FAIL],
                               2 => [H156Invalid::FAIL],
                               5 => [H2Invalid::FAIL] },
                   '3.md' => { 3  => [LineBreakInvalid::FAIL],
                               7  => [LineBreakInvalid::FAIL],
                               9  => [H2Multiple::FAIL],
                               11 => [H156Invalid::FAIL],
                               21 => [H2Multiple::FAIL],
                               23 => [ExtMissing::FAIL + ' [ok](ok#ok)'] } }

      # convert path/to/0.md to 0.md
      actual.keys.each do |key|
        new_key         = File.basename key
        actual[new_key] = actual[key]
        actual.delete key
      end

      expect(actual).to eq(expected)
    end

    it 'reports globbed files using all lint rules' do
      lint = Appium::Lint.new
      dir  = File.join(Dir.pwd, 'spec', 'data', '**', '*.md')

      actual   = lint.report lint.glob dir
      expected = (<<REPORT).strip
./spec/data/0.md
  1: #{H2Missing::FAIL}
  2: #{H156Invalid::FAIL}
  5: #{H2Invalid::FAIL}

./spec/data/sub/3.md
  3: #{LineBreakInvalid::FAIL}
  7: #{LineBreakInvalid::FAIL}
  9: #{H2Multiple::FAIL}
  11: #{H156Invalid::FAIL}
  21: #{H2Multiple::FAIL}
  23: #{ExtMissing::FAIL + ' [ok](ok#ok)'}
REPORT

      expect(actual).to eq(expected)
    end

    it 'empty report is falsey' do
      lint   = Appium::Lint.new
      actual = !!lint.report({})
      expect(actual).to eq(false)
    end

    it 'processes all rules without raising an exception' do
      lint = Appium::Lint.new

      markdown = <<MARKDOWN
hi
====

hi 2
=====

there
------

there 2
--------

--

---

#### h4
##### h5
###### h6
MARKDOWN

      expected = { 1  => [H2Missing::FAIL],
                   2  => [H156Invalid::FAIL],
                   5  => [H156Invalid::FAIL],
                   8  => [H2Invalid::FAIL],
                   11 => [H2Invalid::FAIL],
                   13 => [LineBreakInvalid::FAIL],
                   15 => [LineBreakInvalid::FAIL],
                   18 => [H156Invalid::FAIL],
                   19 => [H156Invalid::FAIL] }

      actual = lint.call data: markdown

      expect(actual).to eq(expected)
    end
  end

  describe H2Multiple do
    it 'detects extra h2s' do
      rule     = H2Multiple.new data: "## hi\n## bye\n##test"
      expected = { 2 => [rule.fail],
                   3 => [rule.fail] }
      actual   = rule.call

      expect(actual).to eq(expected)
    end

    it 'does not error on one h2' do
      rule     = H2Multiple.new data: '## hi'
      expected = {}
      actual   = rule.call

      expect(actual).to eq(expected)
    end

    it 'does not error on code blocks' do
      data = <<'DATA'
# title

```ruby
```

```ruby
```

Here's a Ruby example:

```ruby
# Ruby example
```
DATA
      rule     = H2Multiple.new data: data
      expected = {}
      actual   = rule.call
      expect(actual).to eq(expected)
    end
  end

  describe H2Missing do
    it 'detects missing h1' do
      rule     = H2Missing.new data: '### hi'
      expected = { 1 => [rule.fail] }
      actual   = rule.call

      expect(actual).to eq(expected)
    end

    it 'does not error on valid h2' do
      rule     = H2Missing.new data: '## hi'
      expected = {}
      actual   = rule.call

      expect(actual).to eq(expected)
    end
  end

  describe H2Invalid do
    it 'detects invalid h2' do
      rule     = H2Invalid.new data: "hi\n---"
      expected = { 2 => [rule.fail] }
      actual   = rule.call

      expect(actual).to eq(expected)
    end

    it 'detects multiple invalid h2' do
      rule     = H2Invalid.new data: "hi\n---\nbye\n-----\n\n-------"
      expected = { 2 => [rule.fail],
                   4 => [rule.fail] }
      actual   = rule.call

      expect(actual).to eq(expected)
    end

    it 'detects valid h2' do
      rule     = H2Invalid.new data: '## hi'
      expected = {}
      actual   = rule.call

      expect(actual).to eq(expected)
    end
  end

  describe H156Invalid do
    it 'detects invalid h1, h5, h6' do
      ['# h1', '##### h5', '###### h6'].each do |data|
        rule     = H156Invalid.new data: data
        expected = { 1 => [rule.fail] }
        actual   = rule.call

        expect(actual).to eq(expected)
      end
    end

    it 'detects multiple invalid h1, h5, h6' do
      data = <<-MARKDOWN
# h1
## h2
### h3
#### h4
##### h5
###### h6
 #### not actually a h4 due to leading space

      MARKDOWN

      rule     = H156Invalid.new data: data
      expected = { 1 => [rule.fail],
                   5 => [rule.fail],
                   6 => [rule.fail] }
      actual   = rule.call

      expect(actual).to eq(expected)
    end

    it 'does not error on h2, h3, h4' do
      data = <<-MARKDOWN
## h2
### h3
#### h4
      MARKDOWN
      rule     = H156Invalid.new data: data
      expected = {}
      actual   = rule.call

      expect(actual).to eq(expected)
    end
  end

  describe LineBreakInvalid do
    it 'detects invalid line breaks' do
      %w(-- --- ----).each do |data|
        rule     = LineBreakInvalid.new data: data
        expected = { 1 => [rule.fail] }
        actual   = rule.call

        expect(actual).to eq(expected)
      end
    end

    it 'detects multiple invalid line breaks' do
      data = <<-MARKDOWN
 -- not a break
 ------
-- still not

--

---

-----
      MARKDOWN

      rule     = LineBreakInvalid.new data: data
      expected = { 5 => [rule.fail],
                   7 => [rule.fail],
                   9 => [rule.fail] }
      actual   = rule.call

      expect(actual).to eq(expected)
    end

    it 'does not error on valid data' do
      data = <<-MARKDOWN
some --
 ------
markdown--
-- examples
      MARKDOWN
      rule     = LineBreakInvalid.new data: data
      expected = {}
      actual   = rule.call

      expect(actual).to eq(expected)
    end
  end

  describe ExtMissing do
    it 'detects missing extensions in markdown links' do
      data = <<-MARKDOWN
[link to read](readme)
[ok](ok#ok)
[intro](intro#start)
[testing](docs/en/ok) ok should be ok.md
      MARKDOWN
      rule     = ExtMissing.new data: data
      expected = { 1 => [rule.fail + ' [link to read](readme)'],
                   2 => [rule.fail + ' [ok](ok#ok)'],
                   3 => [rule.fail + ' [intro](intro#start)'],
                   4 => [rule.fail + ' [testing](docs/en/ok)'] }
      actual   = rule.call

      expect(actual).to eq(expected)
    end

    it 'detects accepts valid links' do
      data = <<-MARKDOWN
[link to read](readme.md)
[README](README.md)
[intro](intro.md#start)
[example](https://example.com/)
[testing](docs/en/)
[getting started doc](../../README.md)
[link to self is valid](#)
      MARKDOWN
      rule     = ExtMissing.new data: data
      expected = {}
      actual   = rule.call

      expect(actual).to eq(expected)
    end
  end
end
