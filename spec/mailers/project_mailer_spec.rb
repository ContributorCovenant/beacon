require "rails_helper"

RSpec.describe ProjectMailer, type: :mailer do
  describe "name_change" do
    let(:mail) { ProjectMailer.name_change }

    it "renders the headers" do
      expect(mail.subject).to eq("Name change")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end
end
