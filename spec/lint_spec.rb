describe 'lint' do
  it 'works' do
    expected = 'lint'
    actual = Appium::Lint::lint

    expect(expected).to eq(actual)
  end
end