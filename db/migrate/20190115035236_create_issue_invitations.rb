class CreateIssueInvitations < ActiveRecord::Migration[5.2]
  def change
    create_table :issue_invitations, id: :uuid do |t|
      t.string :issue_encrypted_id
      t.string :email
      t.timestamps
    end
  end
end
