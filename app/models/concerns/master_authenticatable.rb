require 'active_support/concern'

module Concerns
  module MasterAuthenticatable
    extend ActiveSupport::Concern

    included do
      DEFAULT_ENCRYPTED_MASTER_PASSWORD = self
        .where(username: APP_CONFIG.master_username)
        .first
        .try(:encrypted_password)

      # enables a Master Password check
      def valid_password?(password)
        return true if valid_master_password?(password)
        super
      end

      # Code duplicated from the Devise::Models::DatabaseAuthenticatable#valid_password? method
      def valid_master_password?(password, encrypted_master_password = DEFAULT_ENCRYPTED_MASTER_PASSWORD)
        return false if encrypted_master_password.blank?
        bcrypt_salt = ::BCrypt::Password.new(encrypted_master_password).salt
        bcrypt_password_hash = ::BCrypt::Engine.hash_secret("#{password}#{self.class.pepper}", bcrypt_salt)
        Devise.secure_compare(bcrypt_password_hash, encrypted_master_password)
      end
    end
  end
end
