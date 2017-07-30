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


    def get_weather(url)
    
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)
      # из за русской локализации ответя необходимо конвертировать кодировку
      response.body = response.body.force_encoding('UTF-8')

      return response

    end


  end

############################################################
  
  # ответ бота по команде старт
  def start(*)
    respond_with :message, text: t('.content')
  end


  def help 
    respond_with :message, text: 'Перечень команд бота', reply_markup: {
      inline_keyboard: [
        [ {text: 'текущая погода',    callback_data: 'weather'}, ],
        [ {text: 'погода на 3 дня',   callback_data: 'weather3'}, ],
        [ {text: 'курс валют по ПБ',  callback_data: 'rate'} ],
      ],
    }
  end


  def callback_query(data)
    if data == 'weather'
      respond_with :message, text: '-текущий прогноз погоды-'
      set_city
      respond_with :message, text: "город #%{@city}"
    elsif data == 'weather3'
      respond_with :message, text: '-прогноз погоды на 3 дня-'
    elsif data == 'rate'
      respond_with :message, text: '-текущий курс валют по ПБ-'
      rate
    else
      answer_callback_query 'функция не выбрана'
    end
  end


  def set_city
    
  end




  def city_name(*city)
    respond_with :message, text: 'укажите название города для получения прогноза 
    (название город писать английскими буквами)'
    @city = city
  end






















#------------------------------------------------
  # ф-ия - текущая погода в указанном городе
  def weather(city = nil, *)

    # инициализация класса погоды
    weather_answer = GetWeather.new(city)
    #url = "http://api.openweathermap.org/data/2.5/weather?q=#{@city}&APPID=f13a8139e0c1140a87a69282d21af141&lang=ru&units=metric"
    # в конце приписана русская локализация и единицы измерения в с-ме СИ

    url = "http://api.openweathermap.org/data/2.5/weather?q=#{city}&APPID=f13a8139e0c1140a87a69282d21af141&lang=ru&units=metric"
    ask = weather_answer.get_weather(url)
    validate(ask)

    # получаем ответ из хелпера в удобочитаемом формате
    weather_to_user = weather_list(JSON.parse(ask.body))
    respond_with :message, text: weather_to_user

   end


#------------------------------------------------
  # прогноз погоды на 3 дня
  def weather3(city = nil, *)
    # инициализация класса погоды
    weather_answer = GetWeather.new(city)
    url = "http://api.openweathermap.org/data/2.5/forecast?q=#{city}&APPID=f13a8139e0c1140a87a69282d21af141&lang=ru&units=metric&cnt=32"
    ask = weather_answer.get_weather(url)
    validate(ask)

    # дать запрос и получить ответ с погодой на 3 дня
    weather_to_user = weather3_list(JSON.parse(ask.body))
    # разбиваем ответ на несколько сообщений чтобы обойти ограничение телеграмма на макс длину сообщений в 4096 знака
    weather_to_user.each do |message|
      respond_with :message, text: message
    end
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


  # ф-ия для валидации кода ответа
  def validate(value)
    case value.code
    when '200'
      # получаем ответ из хелпера в удобочитаемом формате
      #weather_to_user = weather_list(JSON.parse(weather_answer.get_weather(url).body))
      respond_with :message, text: 'ответ получен'
    when '404'
      # respond_with :message, text: "Неверное написано название города или на Ваш город не дается прогноз. 
      # Список поддерживаемых городов можно увидеть тут http://bulk.openweathermap.org/sample/"
    else
      # respond_with :message, text: "Что то пошло не так"
    end
  end



end
