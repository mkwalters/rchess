require 'rchess'

describe 'Rchess' do
  let(:rchess) do
    Rchess.new
  end

  it 'has a board' do
    expect(rchess.board).to_not be(nil)
  end
end
