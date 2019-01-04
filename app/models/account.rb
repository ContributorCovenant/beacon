class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  devise :confirmable, :lockable, :timeoutable, :trackable, :omniauthable,
         :database_authenticatable, :registerable, :recoverable, :rememberable,
         :validatable

end
