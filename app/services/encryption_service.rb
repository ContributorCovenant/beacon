class EncryptionService
  require 'digest'

  def self.hash(text)
    Digest::MD5.hexdigest(text)
  end

  def self.encrypt(text)
    len   = ActiveSupport::MessageEncryptor.key_len
    salt  = SecureRandom.hex len
    key   = ActiveSupport::KeyGenerator.new(Rails.application.credentials.secret_key_base).generate_key(salt, len)
    crypt = ActiveSupport::MessageEncryptor.new key
    encrypted_data = crypt.encrypt_and_sign(text)
    "#{salt}$$#{encrypted_data}"
  end

  def self.decrypt(text)
    salt, data = text.split('$$')
    len   = ActiveSupport::MessageEncryptor.key_len
    key   = ActiveSupport::KeyGenerator.new(Rails.application.credentials.secret_key_base).generate_key(salt, len)
    crypt = ActiveSupport::MessageEncryptor.new(key)
    crypt.decrypt_and_verify(data)
  end
end
