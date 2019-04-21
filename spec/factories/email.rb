FactoryBot.define do
  factory :email, class: OpenStruct do
    to {
      [
        {
          full: 'sample_project@issues.coc-beacon.com',
          email: 'sample_project@issues.coc-beacon.com',
          token: 'sample_project', host: 'coc-beacon.com',
          name: nil
        }
      ]
    }
    from { { token: 'reporter', host: 'foo.com', email: 'reporter@foo.com', full: 'Reporter <reporter@foo.com>', name: 'Reporter' } }
    subject { 'CoC Issue' }
    body { 'Something bad happened to me.' }
    attachments { [] }

    trait :response_to_issue do
      subject { 'Re: Issue #101' }
      body { 'More details' }
    end

    trait :with_valid_attachment do
      attachments {
        [
          ActionDispatch::Http::UploadedFile.new(
            filename: 'img_1.png',
            type: 'image/png',
            tempfile: File.new("#{File.expand_path(File.dirname(__FILE__))}/fixtures/img_1.png")
          )
        ]
      }
    end

    trait :with_invalid_attachment do
      attachments {
        [
          ActionDispatch::Http::UploadedFile.new(
            filename: 'random.csv',
            type: 'text/csv',
            tempfile: File.new("#{File.expand_path(File.dirname(__FILE__))}/fixtures/random.csv")
          )
        ]
      }
    end

    trait :with_valid_and_invalid_attachments do
      attachments {
        [
          ActionDispatch::Http::UploadedFile.new(
            filename: 'img_2.png',
            type: 'image/png',
            tempfile: File.new("#{File.expand_path(File.dirname(__FILE__))}/fixtures/img_2.png")
          ),
          ActionDispatch::Http::UploadedFile.new(
            filename: 'random.csv',
            type: 'text/csv',
            tempfile: File.new("#{File.expand_path(File.dirname(__FILE__))}/fixtures/random.csv")
          )
        ]
      }
    end

  end
end
