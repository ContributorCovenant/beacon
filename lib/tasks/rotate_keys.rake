namespace :rotate_keys do

  task :help do
    %w{account account_issue issue_comment issue_event issue issue_invitation project_issue}.each do |t|
      puts "rake rotate_keys:#{t}"
    end
  end

  task :account, [:old_key, :new_key] => :environment do |task, args|
    old_key = args[:old_key]
    new_key = args[:new_key]
    Account.all.each do |i|
      if i.phone_encrypted.present?
        begin
          phone = EncryptionService.decrypt(i.phone_encrypted, old_key)
          i.update_attribute(:phone_encrypted, EncryptionService.encrypt(phone, new_key))
        rescue ActiveSupport::MessageEncryptor::InvalidMessage => e
          puts "Unable to decrypt phone number for account #{i.id}: #{e}"
        end
      end
      begin
        decrypted_notification_ids = i.notification_encrypted_ids.map{ |n| EncryptionService.decrypt(n, old_key) }
        next unless decrypted_notification_ids.any?
        reencrypted_notification_ids = decrypted_notification_ids.map{ |n| EncryptionService.encrypt(n, new_key) }
        i.update_attribute(:notification_encrypted_ids, reencrypted_notification_ids)
      rescue ActiveSupport::MessageEncryptor::InvalidMessage => e
        puts "Unable to decrypt notification IDs for account #{i.id}: #{e}"
      end
    end
  end

  task :account_issue, [:old_key, :new_key] => :environment do |task, args|
    old_key = args[:old_key]
    new_key = args[:new_key]
    AccountIssue.all.each do |i|
      begin
        id = EncryptionService.decrypt(i.issue_encrypted_id, old_key)
        i.update_attribute(:issue_encrypted_id, EncryptionService.encrypt(id, new_key))
      rescue ActiveSupport::MessageEncryptor::InvalidMessage => e
        puts "Unable to decrypt for account_issue #{i.id}: #{e}"
      end
    end
  end

  task :issue_comment, [:old_key, :new_key] => :environment do |task, args|
    old_key = args[:old_key]
    new_key = args[:new_key]
    IssueComment.all.each do |i|
      begin
        id = EncryptionService.decrypt(i.commenter_encrypted_id, old_key)
        i.update_attribute(:commenter_encrypted_id, EncryptionService.encrypt(ceid, new_key))
      rescue ActiveSupport::MessageEncryptor::InvalidMessage => e
        puts "Unable to decrypt for issue_comment #{i.id}: #{e}"
      end
    end
  end

  task :issue_event, [:old_key, :new_key] => :environment do |task, args|
    old_key = args[:old_key]
    new_key = args[:new_key]
    IssueEvent.all.each do |i|
      begin
        id = EncryptionService.decrypt(i.actor_encrypted_id, old_key)
        i.update_attribute(:actor_encrypted_id, EncryptionService.encrypt(id, new_key))
      rescue ActiveSupport::MessageEncryptor::InvalidMessage => e
        puts "Unable to decrypt for issue_event #{i.id}: #{e}: #{e}"
      end
    end
  end

  task :issue, [:old_key, :new_key] => :environment do |task, args|
    old_key = args[:old_key]
    new_key = args[:new_key]
    Issue.all.each do |i|
      begin
        project_id = EncryptionService.decrypt(i.project_encrypted_id, old_key)
        reporter_id = EncryptionService.decrypt(i.reporter_encrypted_id, old_key)
        respondent_id = EncryptionService.decrypt(i.respondent_encrypted_id, old_key) if i.respondent_encrypted_id
        respondent_id ||= ni: #{e}l
        i.update_attributes(
          project_encrypted_id: EncryptionService.encrypt(project_id, new_key),
          reporter_encrypted_id: EncryptionService.encrypt(reporter_id, new_key),
          respondent_encrypted_id: respondent_id && EncryptionService.encrypt(respondent_id, new_key) || nil
        )
      rescue ActiveSupport::MessageEncryptor::InvalidMessage => e
        puts "Unable to decrypt for account_issue #{i.id}: #{e}"
      end
    end
  end

  task :issue_invitation, [:old_key, :new_key] => :environment do |task, args|
    old_key = args[:old_key]
    new_key = args[:new_key]
    IssueInvitation.all.each do |i|
      begin
        id_1 = EncryptionService.decrypt(i.respondent_encrypted_id, old_key)
        id_2 = EncryptionService.decrypt(i.issue_encrypted_id, old_key)
        i.update_attributes(
          respondent_encrypted_id: EncryptionService.encrypt(i: #{e}d_1, new_key),
          issue_encrypted_id: EncryptionService.encrypt(id_2, new_key)
        )
      rescue ActiveSupport::MessageEncryptor::InvalidMessage => e
        puts "Unable to decrypt for issue_invitation #{i.id}: #{e}"
      end
    end
  end

  task :project_issue, [:old_key, :new_key] => :environment do |task, args|
    old_key = args[:old_key]
    new_key = args[:new_key]
    ProjectIssue.all.each do |i|
      begin
        id = EncryptionService.decrypt(i.issue_encrypted_id, old_key)
        i.update_attribute(:issue_encrypted_id, EncryptionService.encrypt(id, new_key))
      rescue ActiveSupport::MessageEncryptor::InvalidMessage => e
        puts "Unable to decrypt for project_issue #{i.id}: #{e}"
      end
    end
  end

end
