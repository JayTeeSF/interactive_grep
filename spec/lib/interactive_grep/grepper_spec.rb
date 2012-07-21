require  "spec_helper"
describe InteractiveGrep::Grepper do
  describe "instantiation" do
    let(:params) { {} }
    let(:grepper) { InteractiveGrep::Grepper.new( params ) }
    context "with invalid params" do
      it "should raise an error" do
        expect { InteractiveGrep::Grepper.new(:one) }.to raise_error
        expect { InteractiveGrep::Grepper.new("./*.gz") }.to raise_error
        expect { InteractiveGrep::Grepper.new( { "files" => "" } ) }.to raise_error
        expect { InteractiveGrep::Grepper.new }.to raise_error
      end
    end
    context "with valid params" do
      it "should not raise an error" do
        expect { InteractiveGrep::Grepper.new( { "files" => "#{file_dir}/**/*", "verbose" => nil, "pattern" => "", "mode" => "", "gz" => "" } ) }.not_to raise_error
      end
    end

    describe "detecting files" do
      context "when specifying an ungzipped file" do
        let(:params) { { "files" => "#{ungzipped_file}" } }

        it "should have an array consisting of the ungzipped file" do
          grepper.file_names.should == [ ungzipped_file ]
        end

        it "should have gz set to false" do
          grepper.gz.should be_false
        end
      end

      context "when specifying a gzipped file" do
        let(:params) { { "files" => "#{gzipped_file}" } }

        it "should have an array consisting of the gzipped file" do
          grepper.file_names.should == [ gzipped_file ]
        end

        it "should have gz set to true" do
          grepper.gz.should be_true
        end
      end

      context "when specifying a gzip glob " do
        let(:params) { { "files" => "#{gzip_glob}" } }

        it "should have an array consisting of the gzipped file" do
          grepper.file_names.should == [ gzipped_file ]
        end

        it "should have gz set to true" do
          grepper.gz.should be_true
        end
      end

      context "when specifying a ungzipped glob " do
        let(:params) { { "files" => "#{ungzip_glob}" } }

        it "should have an array consisting of the ungzipped file" do
          grepper.file_names.should == [ ungzipped_file ]
        end

        it "should have gz set to false" do
          grepper.gz.should be_false
        end
      end
    end

    describe "detecting file-patterns" do
      context "in gzipped files" do
        context "counting matches" do
          let(:params) { { "files" => "#{gzipped_file}", "pattern" => "pattern", "mode" => "count" } }
          it "should be in 'count' mode" do
            grepper.should be_just_count
          end
          it "should match two lines" do
            grepper.run.should == 2
          end
        end
      end

      # test w/ default pattern
      context "in ungzipped files" do
        context "counting matches" do
          let(:params) { { "files" => "#{ungzipped_file}", "pattern" => "pattern", "mode" => "count" } }
          it "should be in 'count' mode" do
            grepper.should be_just_count
          end
          it "should match two lines" do
            grepper.run.should == 2
          end
        end
      end
    end

  end
end
