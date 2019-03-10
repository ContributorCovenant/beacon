class EncryptionService
  require 'digest'

  def self.hash(text)
    Digest::MD5.hexdigest(text)
  end

  def self.encrypt(text, secret_key_base = nil)
    secret_key_base ||= Setting.encryption(:secret_key_base)
    len   = ActiveSupport::MessageEncryptor.key_len
    salt  = SecureRandom.hex len
    key   = ActiveSupport::KeyGenerator.new(secret_key_base).generate_key(salt, len)
    crypt = ActiveSupport::MessageEncryptor.new key
    encrypted_data = crypt.encrypt_and_sign(text)
    "#{salt}$$#{encrypted_data}"
  end

  def self.decrypt(text, secret_key_base = nil)
    secret_key_base ||= Setting.encryption(:secret_key_base)
    salt, data = text.split('$$')
    len   = ActiveSupport::MessageEncryptor.key_len
    key   = ActiveSupport::KeyGenerator.new(secret_key_base).generate_key(salt, len)
    crypt = ActiveSupport::MessageEncryptor.new(key)
    crypt.decrypt_and_verify(data)
  rescue StandardError => e
    Rails.logger.info("Failed to decrypt: #{e.backtrace}\n#{e}")
    return nil
  end
end
