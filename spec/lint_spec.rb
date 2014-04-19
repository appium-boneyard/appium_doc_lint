require_relative 'helper'

class Appium::Lint
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

  describe H456Present do
    it 'detects invalid h4, h5, h6' do
      ['#### h4', '##### h5', '###### h6'].each do |data|
        rule     = H456Present.new data: data
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
      MARKDOWN

      rule     = H456Present.new data: data
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
      rule     = H456Present.new data: data
      expected = {}
      actual   = rule.call

      expect(actual).to eq(expected)
    end
  end
end