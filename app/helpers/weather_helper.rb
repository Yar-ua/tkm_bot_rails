module WeatherHelper

  require 'net/http'
  require 'uri'  
  

  def get_weather
   
    url = "http://api.openweathermap.org/data/2.5/weather?q=sumy&APPID=f13a8139e0c1140a87a69282d21af141"
    uri = URI.parse(url)
    response = NET::HTTP.get_response(uri)
    @weather = response
  
  end 

end
