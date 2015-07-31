module SpreeSignifyd
  module RequestVerifier

    def encode_request(request_body)
      request_body.force_encoding('ISO-8859-1').encode('UTF-8')
    end

    def build_sha(key, message)
      sha256 = OpenSSL::Digest::SHA256.new
      digest = OpenSSL::HMAC.digest(sha256, key, message)
      Base64.encode64(digest).strip
    end
  end
end
