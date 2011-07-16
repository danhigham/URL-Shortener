# Credit to http://www.snippetit.com/2009/04/php-short-url-algorithm-implementation/ for 
# original php implentation of pseudo code found at http://www.snippetit.com/2008/10/implement-your-own-short-url/

%w(rubygems digest/md5 dm-core dm-redis-adapter dm-timestamps uri).each { |lib| require lib }

class UrlShortener < Sinatra::Base

  get '/shorten/*' do
    url = params[:splat][0]
    short_code = short_url(url)[0]
    record = Url.first_or_create :short_code => short_code, :original => url
    "http://#{env['HTTP_HOST']}/#{short_code}"
  end
  
  get '/*' do
    url = Url.first :short_code => params[:splat][0]
    halt 404, 'Not Found' if url.nil?
    redirect url.original
  end
  
end

class Url
  
  include DataMapper::Resource
  
  property  :id,          Serial
  property  :short_code,  String, :length => 6
  property  :original,    String, :length => 255
  property  :created_at,  DateTime  
  
end

def short_url(url)
  base32 = %w{ a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3 4 5 }
  url_md5 = Digest::MD5.hexdigest(url)
  sub_hex_len = url_md5.length / 8
  
  output = Array.new
  
  (0..sub_hex_len-1).each do |i|
    s = i*8
    e = (i*8) + 8
    sub_hex = url_md5[s..e]
    int = 0x3FFFFFFF & (1 * ("0x#{sub_hex}").to_i(16))
    out = ''
    
    (0..5).each do |j|
      val = 0x0000001F & int
      out = "#{out}#{base32[val]}"
      int = int >> 5
    end
    
    output << out 
  end
  
  output
end
