require_relative '../my_regexp/regexp'

describe 'my_regexp' do
  let(:reg) {
    MyRegexp::Regexp.new(pat)
  }

  describe '連結がマッチできること' do
    let(:pat) { 'abcdef' }
    it do
      expect(reg.match('abcdef')).to be_truthy
    end
  end

  describe '0回以上の繰り返しがマッチできること' do
    let(:pat) { 'a*b' }
    it 'aが0回でもマッチすること' do
      expect(reg.match('b')).to be_truthy
    end
    it 'aが1回でもマッチすること' do
      expect(reg.match('ab')).to be_truthy
    end
    it 'aが2回でもマッチすること' do
      expect(reg.match('aab')).to be_truthy
    end
  end

  describe '1回以上の繰り返しがマッチできること' do
    let(:pat) { 'a+b' }
    it 'aが0回ではマッチしないこと' do
      expect(reg.match('b')).to be_falsey
    end
    it 'aが1回ならマッチすること' do
      expect(reg.match('ab')).to be_truthy
    end
    it 'aが2回でもマッチすること' do
      expect(reg.match('aab')).to be_truthy
    end
  end

  describe '分岐がマッチすること' do
    let(:pat) { '(aa|bb)c' }
    it '分岐の左にマッチする場合' do
      expect(reg.match('aac')).to be_truthy
    end
    it '分岐の右にマッチすること' do
      expect(reg.match('bbc')).to be_truthy
    end
    it '分岐のどちらにもマッチしない場合マッチしないこと' do
      expect(reg.match('ddc')).to be_falsey
    end
  end

  describe '分岐、繰り返し、連結の組み合わせ((a+|ddd)ef)' do
    let(:pat) { '(a+|ddd)ef' }

    it 'aefにマッチすること' do
      expect(reg.match('aef')).to be_truthy
    end
    it 'aaefにマッチすること' do
      expect(reg.match('aaef')).to be_truthy
    end
    it 'efにはマッチしないこと' do
      expect(reg.match('aaef')).to be_truthy
    end
    it 'dddcefにマッチすること' do
      expect(reg.match('dddef')).to be_truthy
    end
  end
end

