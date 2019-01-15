class AddRespondentEncryptedIdToIssues < ActiveRecord::Migration[5.2]
  def change
    change_table :issues do |t|
      t.text :respondent_encrypted_id
    end
  end
end
