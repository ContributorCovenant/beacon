namespace :projects do

  desc 'Map accounts to owners'
  task :map_accounts_to_roles => :environment do
    Project.all.each{ |project| Role.create(project: project, account: project.account, is_owner: true) }
  end

end
