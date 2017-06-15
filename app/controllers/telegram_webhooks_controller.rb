class TelegramWebhooksController < Telegram::Bot::UpdatesController
  include Telegram::Bot::UpdatesController::MessageContext
  context_to_action!

  require 'net/http'
  require 'uri'
  require 'json'

  # в этом хелпере парсим из JSON ответ в удобочитаемом виде
  include WeatherHelper

  # класс для погоды
  class GetWeather
    require 'net/http'
    require 'uri'
    require 'json'
    

    def initialize(value)
      @city = value
    end


    def get_current_weather
      url = "http://api.openweathermap.org/data/2.5/weather?q=#{@city}&APPID=f13a8139e0c1140a87a69282d21af141&lang=ru&units=metric"
      # в конце приписана русская локализация и единицы измерения в с-ме СИ
    
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)
      # из за русской локализации ответя необходимо конвертировать кодировку
      response.body = response.body.force_encoding('UTF-8')

      return response

    end


    def get_3_weather
      url = "http://api.openweathermap.org/data/2.5/forecast?q=#{@city}&APPID=f13a8139e0c1140a87a69282d21af141&lang=ru&units=metric&cnt=5"
    
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)
      response.body = response.body.force_encoding('UTF-8')
      # из за русской локализации ответя необходимо конвертировать кодировку
      # response.body = response.body.force_encoding('UTF-8')

      return response

    end

  end

############################################################
  
  # ответ бота по команде старт
  def start(*)
    respond_with :message, text: t('.content')
  end

  
  # ответ бота по команде /help, команда нуждается в доработке
  def help(*)
    respond_with :message, text: t('.content')
  end

#------------------------------------------------
  # ф-ия - текущая погода в указанном городе
  def weather(city = nil, *)

   # инициализация класса погоды
   weather_answer = GetWeather.new(city)
   # дать запрос и получить ответ с погодой 
   # weather_answer.get_current_weather
   # дальнейшие действия и сообщения в зависимости от кода ответа
   # определение, прошел ли запрос успешно
   case weather_answer.get_current_weather.code
    # если код 200 ок то работаем дальше
    when '200' then
      # получаем ответ из хелпера в удобочитаемом формате
      weather_to_user = weather_list(JSON.parse(weather_answer.get_current_weather.body))
      respond_with :message, text: weather_to_user
    when '404'
      respond_with :message, text: "Неверное написано название города или на Ваш город не дается прогноз. 
      Список поддерживаемых городов можно увидеть тут http://bulk.openweathermap.org/sample/"
    else
      respond_with :message, text: "Что то пошло не так"
    end

  end


#------------------------------------------------
  # прогноз погоды на 3 дня
  def weather3(city = nil, *)
    # инициализация класса погоды
    weather_answer = GetWeather.new(city)
    # дать запрос и получить ответ с погодой на 3 дня
    result = weather_answer.get_3_weather
    respond_with :message, text: result.body.to_json
  end


  # курс валют по приватбанку
  def rate
    url = "https://api.privatbank.ua/p24api/pubinfo?json&exchange&coursid=5"
    uri = URI.parse(url)
    response = Net::HTTP.get_response(uri)
    response.body = response.body.force_encoding('UTF-8')
    rate_to_user = rate_list(JSON.parse(response.body))
    respond_with :message, text: rate_to_user
  end


end
