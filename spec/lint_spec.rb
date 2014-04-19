require_relative 'helper'

class Appium::Lint
  describe H1Present do
    it 'detects missing h1' do
      rule     = H1Present.new data: '## hi'
      expected = rule.fail
      actual   = rule.call.first

      expect(actual).to eq(expected)
    end

    it 'detects h1 present' do
      rule     = H1Present.new data: '# hi'
      expected = []
      actual   = rule.call

      expect(actual).to eq(expected)
    end
  end

  describe H1Invalid do
    it 'detects invalid h1' do
      rule     = H1Invalid.new data: "hi\n==="
      expected = rule.fail
      actual   = rule.call.first

      expect(actual).to eq(expected)
    end

    it 'detects valid h1' do
      rule     = H1Invalid.new data: '# hi'
      expected = []
      actual   = rule.call

      expect(actual).to eq(expected)
    end
  end

  describe H2Invalid do
    it 'detects invalid h2' do
      rule     = H2Invalid.new data: "hi\n---"
      expected = rule.fail
      actual   = rule.call.first

      expect(actual).to eq(expected)
    end

    it 'detects valid h2' do
      rule     = H2Invalid.new data: '## hi'
      expected = []
      actual   = rule.call

      expect(actual).to eq(expected)
    end
  end
end