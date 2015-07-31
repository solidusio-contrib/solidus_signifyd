require 'spec_helper'

module SpreeSignifyd
  describe RequestVerifier do
    include RequestVerifier

    describe "#encode_request" do
      context "request has special characters" do
        it "returns an unescaped UTF-8 string" do
          expect(encode_request("R\xE9n\xE9 Pe\xF1a")).to eq "Réné Peña"
        end
      end

      context "request doesn't contain special characters" do
        it "returns the original string" do
          expect(encode_request("John Doe")).to eq "John Doe"
        end
      end
    end

    describe "#build_sha" do
      it "returns an HMAC SHA256 encoded message" do
        expect(build_sha('ABCDE', 'test')).to eq "K0y2rIeTA77lBEHP8cRPk64fVRbhMrZqEk7la39EjEM="
      end
    end
  end
end
