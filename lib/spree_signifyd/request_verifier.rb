module SpreeSignifyd
  module RequestVerifier

    def build_sha(key, message)
      sha256 = OpenSSL::Digest::SHA256.new
      digest = OpenSSL::HMAC.digest(sha256, key, message)
      Base64.encode64(digest).strip
    end
  end
end
