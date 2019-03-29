class UrlValidator < ActiveModel::EachValidator

  def self.compliant?(value)
     uri = URI.parse(value)
     uri.is_a?(URI::HTTP) && !uri.host.nil?
   rescue URI::InvalidURIError
     false
   end

   def validate(record)
     return unless record.urls.map(&:present?).any?
     record.urls.each do |url|
       next unless url.present?
       unless self.class.compliant?(url)
         record.errors.add(url, "is not a valid URL")
       end
     end
   end

end
