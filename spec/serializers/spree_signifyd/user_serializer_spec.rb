require 'spec_helper'

module SpreeSignifyd
  describe UserSerializer do
    let(:user) { create(:user) }
    let(:serialized_user) { JSON.parse(UserSerializer.new(user).to_json) }

    context "node values" do
      it "emailAddress" do
        expect(serialized_user['emailAddress']).to eq user.email
      end

      it "username" do
       expect(serialized_user['username']).to eq user.email
      end

      it "createdDate" do
       expect(serialized_user['createdDate']).to eq user.created_at.utc.iso8601
      end

      it "lastUpdateDate" do
       expect(serialized_user['lastUpdateDate']).to eq user.updated_at.utc.iso8601
      end
    end
  end
end
