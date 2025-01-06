# frozen_string_literal: true

namespace :oerr do
  desc 'TODO'
  task create_user: :environment do
    puts 'creating oerr user'
    user = User.find_by(username: OerrService.oerr_configs[:username])
    if user
      puts 'User already exist'
    else
      UserManagement::UserService.create_user(user_params)
      puts "Account created successfully for #{OerrService.oerr_configs[:username]}"
    end
  end

  def user_params
    oerr_configs = OerrService.oerr_configs
    {
      user: {
        username: oerr_configs[:username],
        password: oerr_configs[:password]
      },
      person: { first_name: 'Oerr', last_name: 'KCH' },
      roles: [],
      departments: [],
      lab_locations: []
    }
  end
end
