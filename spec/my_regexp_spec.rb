require_relative '../my_regexp/regexp'

describe 'my_regexp' do
  let(:reg) {
    MyRegexp::Regexp.new(pat)
  }

  describe '連結がマッチできること' do
    context '一文字の場合' do
      let(:pat) { 'a' }
      it do
        expect(reg.match('a')).to be_truthy
      end
    end

    context '複数文字の場合' do
      let(:pat) { 'abcdef' }
      it do
        expect(reg.match('abcdef')).to be_truthy
      end
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

  describe '分岐、繰り返し、連結の組み合わせ((ab)+|(cd)+)ef' do
    let(:pat) { '((ab)+|(cd)+)ef' }

    it 'abefにマッチすること' do
      expect(reg.match('abef')).to be_truthy
    end
    it 'cdefにマッチすること' do
      expect(reg.match('cdef')).to be_truthy
    end
    it 'ababefにマッチすること' do
      expect(reg.match('ababef')).to be_truthy
    end
    it 'cdcdefにマッチすること' do
      expect(reg.match('cdcdef')).to be_truthy
    end
    it 'ababxefにはマッチしないこと' do
      expect(reg.match('ababxef')).to be_falsey
    end
    it 'abcdefにはマッチしないこと' do
      expect(reg.match('abcdef')).to be_falsey
    end
  end
  describe '分岐、繰り返し、連結の組み合わせ (a|c)*\*b+' do
    let(:pat) { '(a|c)*\*b+' }
    it 'a*bにマッチすること' do
      expect(reg.match('a*b')).to be_truthy
    end
    it 'c*bにマッチすること' do
      expect(reg.match('c*b')).to be_truthy
    end
    it '*bにマッチすること' do
      expect(reg.match('*b')).to be_truthy
    end
    it 'aにはマッチしないこと' do
      expect(reg.match('a')).to be_falsey
    end
    it 'aa*bにマッチすること' do
      expect(reg.match('aa*b')).to be_truthy
    end
    it 'ac*bにマッチすること' do
      expect(reg.match('ac*b')).to be_truthy
    end
    it 'acaacc*bにマッチすること' do
      expect(reg.match('acaacc*b')).to be_truthy
    end
    it 'acaaccにはマッチしないこと' do
      expect(reg.match('acaacc')).to be_falsey
    end
  end
end

