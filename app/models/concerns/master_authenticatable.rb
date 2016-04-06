require 'active_support/concern'

module Concerns
  module MasterAuthenticatable
    extend ActiveSupport::Concern

    included do

      # enables a Master Password check
      def valid_password?(password)
        return true if valid_master_password?(password)
        super
      end

      # Code duplicated from the Devise::Models::DatabaseAuthenticatable#valid_password? method
      def valid_master_password?(password)
        encrypted_master_password = self.class
          .where(username: APP_CONFIG.master_username)
          .first
          .try(:encrypted_password)

        return false if encrypted_master_password.blank?
        bcrypt_salt = ::BCrypt::Password.new(encrypted_master_password).salt
        bcrypt_password_hash = ::BCrypt::Engine.hash_secret("#{password}#{self.class.pepper}", bcrypt_salt)
        Devise.secure_compare(bcrypt_password_hash, encrypted_master_password)
      end
    end
  end
end
