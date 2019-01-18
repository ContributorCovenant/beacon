class WatermarkService
  require 'digest'

  def self.watermark(text)
    "003366#{Digest::MD5.hexdigest(text)}ff".each_char.each_slice(2).map(&:join).map{ |octet| octet * 3 }
  end
end
