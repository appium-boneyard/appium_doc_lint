require_relative 'helper'

class Appium::Lint
  describe 'Lint' do
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

      expected = { 0  => [H1Present::FAIL],
                   1  => [H1Invalid::FAIL],
                   4  => [H1Invalid::FAIL],
                   7  => [H2Invalid::FAIL, LineBreakInvalid::FAIL],
                   10 => [H2Invalid::FAIL, LineBreakInvalid::FAIL],
                   12 => [LineBreakInvalid::FAIL],
                   14 => [H2Invalid::FAIL, LineBreakInvalid::FAIL],
                   16 => [H456Invalid::FAIL],
                   17 => [H456Invalid::FAIL],
                   18 => [H456Invalid::FAIL] }

      actual = lint.call data: markdown

      expect(actual).to eq(expected)
    end
  end

  describe H1Present do
    it 'detects missing h1' do
      rule     = H1Present.new data: '## hi'
      expected = { 0 => [rule.fail] }
      actual   = rule.call

      expect(actual).to eq(expected)
    end

    it 'detects h1 present' do
      rule     = H1Present.new data: '# hi'
      expected = {}
      actual   = rule.call

      expect(actual).to eq(expected)
    end
  end

  describe H1Invalid do
    it 'detects invalid h1' do
      rule     = H1Invalid.new data: "hi\n==="
      expected = { 1 => [rule.fail] }
      actual   = rule.call

      expect(actual).to eq(expected)
    end

    it 'detects multiple invalid h1' do
      rule     = H1Invalid.new data: "hi\n===\nbye\n======"
      expected = { 1 => [rule.fail],
                   3 => [rule.fail] }
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
      expected = { 1 => [rule.fail] }
      actual   = rule.call

      expect(actual).to eq(expected)
    end

    it 'detects multiple invalid h2' do
      rule     = H2Invalid.new data: "hi\n---\nbye\n-------"
      expected = { 1 => [rule.fail],
                   3 => [rule.fail] }
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
        expected = { 0 => [rule.fail] }
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
      expected = { 3 => [rule.fail],
                   4 => [rule.fail],
                   5 => [rule.fail] }
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
        expected = { 0 => [rule.fail] }
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
      expected = { 3 => [rule.fail],
                   4 => [rule.fail],
                   5 => [rule.fail] }
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