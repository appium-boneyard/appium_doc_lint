require_relative 'helper'

class Appium::Lint
  describe 'Lint' do
    it 'processes globbed files using all lint rules' do
      lint = Appium::Lint.new
      dir  = File.join(Dir.pwd, 'spec', 'data', '**', '*.md')

      actual   = lint.glob dir

      # 1.md has no problems so it doesn't show up in expected failures
      expected = { '0.md' => { 1 => [H1Missing::FAIL],
                               2 => [H1Invalid::FAIL],
                               5 => [H2Invalid::FAIL] },
                   '3.md' => { 3  => [LineBreakInvalid::FAIL],
                               7  => [LineBreakInvalid::FAIL],
                               9  => [H1Multiple::FAIL],
                               11 => [H456Invalid::FAIL] } }

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
0.md
  1: #{H1Missing::FAIL}
  2: #{H1Invalid::FAIL}
  5: #{H2Invalid::FAIL}

3.md
  3: #{LineBreakInvalid::FAIL}
  7: #{LineBreakInvalid::FAIL}
  9: #{H1Multiple::FAIL}
  11: #{H456Invalid::FAIL}
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

      expected = { 1  => [H1Missing::FAIL],
                   2  => [H1Invalid::FAIL],
                   5  => [H1Invalid::FAIL],
                   8  => [H2Invalid::FAIL],
                   11 => [H2Invalid::FAIL],
                   13 => [LineBreakInvalid::FAIL],
                   15 => [LineBreakInvalid::FAIL],
                   17 => [H456Invalid::FAIL],
                   18 => [H456Invalid::FAIL],
                   19 => [H456Invalid::FAIL] }

      actual = lint.call data: markdown

      expect(actual).to eq(expected)
    end
  end

  describe H1Multiple do
    it 'detects extra h1s' do
      rule     = H1Multiple.new data: "# hi\n# bye\n#test"
      expected = { 2 => [rule.fail],
                   3 => [rule.fail] }
      actual   = rule.call

      expect(actual).to eq(expected)
    end

    it 'does not error on one h1' do
      rule     = H1Multiple.new data: '# hi'
      expected = {}
      actual   = rule.call

      expect(actual).to eq(expected)
    end
  end

  describe H1Missing do
    it 'detects missing h1' do
      rule     = H1Missing.new data: '## hi'
      expected = { 1 => [rule.fail] }
      actual   = rule.call

      expect(actual).to eq(expected)
    end

    it 'does not error on valid h1' do
      rule     = H1Missing.new data: '# hi'
      expected = {}
      actual   = rule.call

      expect(actual).to eq(expected)
    end
  end

  describe H1Invalid do
    it 'detects invalid h1' do
      rule     = H1Invalid.new data: "hi\n==="
      expected = { 2 => [rule.fail] }
      actual   = rule.call

      expect(actual).to eq(expected)
    end

    it 'detects multiple invalid h1' do
      rule     = H1Invalid.new data: "hi\n===\nbye\n======\n\n===="
      expected = { 2 => [rule.fail],
                   4 => [rule.fail],
                   6 => [rule.fail] }
      actual   = rule.call

      expect(actual).to eq(expected)
    end

    it 'detects valid h1' do
      rule     = H1Invalid.new data: '# hi'
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
      rule     = H2Invalid.new data: "hi\n---\nbye\n-------"
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

  describe H456Invalid do
    it 'detects invalid h4, h5, h6' do
      ['#### h4', '##### h5', '###### h6'].each do |data|
        rule     = H456Invalid.new data: data
        expected = { 1 => [rule.fail] }
        actual   = rule.call

        expect(actual).to eq(expected)
      end
    end

    it 'detects multiple invalid h4, h5, h6' do
      data = <<-MARKDOWN
# h1
## h2
### h3
#### h4
##### h5
###### h6
 #### not actually a h4 due to leading space
      MARKDOWN

      rule     = H456Invalid.new data: data
      expected = { 4 => [rule.fail],
                   5 => [rule.fail],
                   6 => [rule.fail] }
      actual   = rule.call

      expect(actual).to eq(expected)
    end

    it 'does not error on h1, h2, h3' do
      data = <<-MARKDOWN
# h1
# h2
# h3
      MARKDOWN
      rule     = H456Invalid.new data: data
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
end