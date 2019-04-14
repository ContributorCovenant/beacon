FactoryBot.define do
  factory :email, class: OpenStruct do
    to { [{ full: 'sample_project@issues.coc-beacon.com', email: 'sample_project@issues.coc-beacon.com', token: 'sample_project', host: 'coc-beacon.com', name: nil }] }
    from { { token: 'reporter', host: 'foo.com', email: 'reporter@foo.com', full: 'Reporter <reporter@foo.com>', name: 'Reporter' } }
    subject { 'CoC Issue' }
    body { 'Something bad happened to me while contributing to sample_project.' }
    attachments { [] }

    trait :with_attachment do
      attachments {[
        ActionDispatch::Http::UploadedFile.new({
          filename: 'img.png',
          type: 'image/png',
          tempfile: File.new("#{File.expand_path(File.dirname(__FILE__))}/fixtures/img.png")
        })
      ]}
    end
  end
end
