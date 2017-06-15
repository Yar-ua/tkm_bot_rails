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


    # валидация класса на корректное имя города, ответ http200ok и т д
    def validate


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
      url = "http://api.openweathermap.org/data/2.5/forecast?q=#{@city}&APPID=f13a8139e0c1140a87a69282d21af141&lang=ru&units=metric"
    
      uri = URI.parse(url)
      response = Net::HTTP.get_response(uri)
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
   result = weather_answer.get_current_weather
   # дальнейшие действия и сообщения в зависимости от кода ответа
   # определение, прошел ли запрос успешно
   case result.code
    # если код 200 ок то работаем дальше
    when '200' then
      # получаем ответ из хелпера в удобочитаемом формате
      weather_to_user = weather_list(JSON.parse(result.body))
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
    # дать запрос и получить ответ с погодой на # дня
    result = weather_answer.get_3_weather
    respond_with :message, text: result.body[0..256]
  end










  # оформляем меню погоды wmenu
  # def wmenu
  #   respond_with :message, text: t('.prompt'), reply_markup: {
  #    inline_keyboard: [
  #      [
  #        {text: t('.current_weather'), callback_data: 'alert'},
  #        {text: t('.5_weather'), callback_data: 'no_alert'},
  #      ],
  #      [{text: "...далее будет...", callback_data: 'находится в разработке'}],
  #    ],
  #  }
  # end



#####################
  def memo(*args)
    if args.any?
      session[:memo] = args.join(' ')
      respond_with :message, text: t('.notice')
    else
      respond_with :message, text: t('.prompt')
      save_context :memo
    end
  end

  def remind_me
    to_remind = session.delete(:memo)
    reply = to_remind || t('.nothing')
    respond_with :message, text: reply
  end

  def keyboard(value = nil, *)
    if value
      respond_with :message, text: t('.selected', value: value)
    else
      save_context :keyboard
      respond_with :message, text: t('.prompt'), reply_markup: {
        keyboard: [t('.buttons')],
        resize_keyboard: true,
        one_time_keyboard: true,
        selective: true,
      }
    end
  end

  def inline_keyboard
    respond_with :message, text: t('.prompt'), reply_markup: {
      inline_keyboard: [
        [
          {text: t('.alert'), callback_data: 'alert'},
          {text: t('.no_alert'), callback_data: 'no_alert'},
        ],
        [{text: t('.repo'), url: 'https://github.com/telegram-bot-rb/telegram-bot'}],
      ],
    }
  end

  def callback_query(data)
    if data == 'alert'
      answer_callback_query t('.alert'), show_alert: true
    else
      answer_callback_query t('.no_alert')
    end
  end

  def message(message)
    respond_with :message, text: t('.content', text: message['text'])
  end

  def inline_query(query, offset)
    query = query.first(10) # it's just an example, don't use large queries.
    t_description = t('.description')
    t_content = t('.content')
    results = 5.times.map do |i|
      {
        type: :article,
        title: "#{query}-#{i}",
        id: "#{query}-#{i}",
        description: "#{t_description} #{i}",
        input_message_content: {
          message_text: "#{t_content} #{i}",
        },
      }
    end
    answer_inline_query results
  end

  # As there is no chat id in such requests, we can not respond instantly.
  # So we just save the result_id, and it's available then with `/last_chosen_inline_result`.
  def chosen_inline_result(result_id, query)
    session[:last_chosen_inline_result] = result_id
  end

  def last_chosen_inline_result
    result_id = session[:last_chosen_inline_result]
    if result_id
      respond_with :message, text: t('.selected', result_id: result_id)
    else
      respond_with :message, text: t('.prompt')
    end
  end

  def action_missing(action, *_args)
    if command?
      respond_with :message, text: t('telegram_webhooks.action_missing.command', command: action)
    else
      respond_with :message, text: t('telegram_webhooks.action_missing.feature', action: action)
    end
  end
end
