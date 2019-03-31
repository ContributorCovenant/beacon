namespace :projects do

  desc 'Map accounts to owners'
  task :map_accounts_to_roles => :environment do
    Project.all.each{ |project| Role.create(project: project, account: project.account, is_owner: true) }
  end

  desc 'Set sort keys for existing projects'
  task :sort_keys => :environment do
    Project.all.each{ |project| project.update_attribute(:sort_key, project.name[0].downcase) }
  end

  desc 'Set org name for projects'
  task :org_name => :environment do
    Organization.all.each do |org|
      org.projects.each{ |project| project.update_attribute(:organization_name, org.name) }
    end
  end
end
