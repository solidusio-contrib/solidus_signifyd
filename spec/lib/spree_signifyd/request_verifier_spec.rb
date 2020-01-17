require 'spec_helper'

module SolidusSignifyd
  describe RequestVerifier do
    include RequestVerifier

    describe "#build_sha" do
      it "returns an HMAC SHA256 encoded message" do
        expect(build_sha('ABCDE', 'test')).to eq "K0y2rIeTA77lBEHP8cRPk64fVRbhMrZqEk7la39EjEM="
      end
    end
  end
end
