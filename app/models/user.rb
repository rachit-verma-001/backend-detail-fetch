# frozen_string_literal: true

class User < ActiveRecord::Base
  extend Devise::Models
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :token_authenticatable, :confirmable
  # include DeviseTokenAuth::Concerns::User
  # acts_as_token_authenticatable

  has_many :authentication_tokens, dependent: :destroy
  after_create :send_confirmation_email

  private

  def send_confirmation_email
    self.send_confirmation_instructions
  end


end
