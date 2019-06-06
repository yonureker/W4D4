# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  email           :string           not null
#  password_digest :string           not null
#  session_token   :string           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class User < ApplicationRecord
  validates :email, :password_digest, :session_token, presence: true
  validates :email, uniqueness: true

  after_initialize :session_token

  # before running any validation run this method:
  # if user doesn't have any session token, our validations will fail
  # as we validate :session_token
  before_validation :ensure_session_token

  # returns a random session token.
  def self.generate_session_token
    SecureRandom.urlsafe_base64
  end

  def self.find_by_credentials(email, password)
    # first, find if any users exists in our DB with the provided email.
    user = User.find_by(email: email)

    # if user exists, return the user, else return nil.
    user && user.is_password?(password) ? user : nil
  end

  def reset_session_token!
    # assigning a new session token
    self.session_token = User.generate_session_token

    # save the user with the new session token
    self.save!
    self.session_token
  end

  def ensure_session_token
    # make sure the user has a session token
    # do nothing if they already have a session token
    # using lazy assignement:
    self.session_token ||= User.generate_session_token

    # WHY DON'T WE SAVE USER HERE?
  end

  def password=(password)
    # set the encrypted hash using BCrypt
    self.password_digest = BCrypt::Password.create(password)

    # we need the @password instance variable to validate
    @password = password
  end

  def is_password?(password)
    # Check if user's encrypted hash matches the Bcrypted password.
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end
end
