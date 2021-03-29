require 'base64'
require 'openssl'
require 'digest'
require 'lzutf8'

module XBookmarkWebClient
  class Crypto
    def self.decrypt(user_id, password, sync_data)
      DefaultCrypto.decrypt_bookmarks(user_id, password, sync_data['bookmarks'])
    end
  end

  class DefaultCrypto
    KEY_HASH_ALGORITHM = 'sha256'
    CIPHER_ALGORITHM = 'aes-256-gcm'
    KEY_ITERATIONS = 250_000
    KEY_LENGTH = 32
    IV_LENGTH = 16

    def self.decrypt_bookmarks(user_id, password, encrypted_bookmark_data_b64)
      Log.debug('Starting decrypt_bookmarks')

      cipher_text = Base64.decode64(encrypted_bookmark_data_b64)
      key = OpenSSL::KDF.pbkdf2_hmac(password, salt: user_id, iterations: KEY_ITERATIONS, length: KEY_LENGTH,
                                               hash: KEY_HASH_ALGORITHM)

      Log.debug('decrypt_bookmarks: key generated')

      cipher_text_with_auth_tag = cipher_text.unpack('C*')
      iv = cipher_text_with_auth_tag.slice(0, 16).pack('C*')
      cipher_text = cipher_text_with_auth_tag[0..-17].slice(16..cipher_text_with_auth_tag.length - 1).pack('C*')
      auth_tag = cipher_text_with_auth_tag.last(16).pack('C*')

      Log.debug('decrypt_bookmarks: determined iv and auth_tag')

      cipher = OpenSSL::Cipher.new('aes-256-gcm')

      cipher.decrypt
      cipher.padding = 0
      cipher.key = key
      cipher.iv_len = 16
      cipher.iv = iv
      cipher.auth_tag = auth_tag

      plain_text = cipher.update(cipher_text) + cipher.final
      Log.debug('decrypt_bookmarks: text decrypted')
      LZUTF8.decompress(plain_text)
    end
  end
end
