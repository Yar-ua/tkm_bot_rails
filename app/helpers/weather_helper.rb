module WeatherHelper

  def weather_list(value)

    # для перевода кПа в мм рт ст
    # 1 kPa = 7.5 mmHg

    answer = "------
    погода: #{value['weather'][0]['description']}
    ----------
    температура: #{value['main']['temp']}, град С
    температурный градиет: #{value['main']['temp_min']} ... #{value['main']['temp_max']}, град С
    давление: #{(value['main']['pressure']/10).round(2)} кПа или #{(value['main']['pressure']*0.75).round(2)} мм рт.ст.
    влажность: #{value['main']['humidity']} %
    дальность прямой видимости: #{value['visibility']} м
    скорость ветра: #{value['wind']['speed']} м/с
    направление ветра: #{value['wind']['deg']} град по азимуту
    облачность: #{value['clouds']['all']} %
    ---------- "

    return answer

  end

end
