# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Criar usuário admin padrão
admin = User.find_or_create_by(email: 'admin@parking.com') do |user|
  user.password = 'admin123'
  user.password_confirmation = 'admin123'
  user.user_type = 'admin'
end

# Criar usuário manager padrão
manager = User.find_or_create_by(email: 'manager@parking.com') do |user|
  user.password = 'manager123'
  user.password_confirmation = 'manager123'
  user.user_type = 'manager'
end
