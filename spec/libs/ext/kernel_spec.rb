require File.join(RAILS_ROOT, 'spec', 'spec_helper')

class FakeClass
  def say_nil; nil end
  def say_hi; 'hi' end
end

describe KernelExt do

  describe '#if_available' do
    let(:fake) { FakeClass.new }

    context 'with nil object' do
      it 'should return nil' do
        fake.if_available?(:say_nil).length.should be_nil
      end
    end

    context 'without nil object' do
      it 'should return the expected value' do
        fake.if_available?(:say_hi).length.should == 2
      end
    end
  end
end
