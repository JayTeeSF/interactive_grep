require  "spec_helper"
describe InteractiveGrep::Grepper do
  context "initialization" do
    context "with invalid params" do
      it "should raise an error" do
        expect { InteractiveGrep::Grepper.new }.to raise_error(ArgumentError)
        expect { InteractiveGrep::Grepper.new(:one) }.to raise_error
      end
    end
    context "with valid params" do
      it "should not raise an error" do
        expect { InteractiveGrep::Grepper.new( "./*.gz" ) }.not_to raise_error
      end
    end
  end

end
