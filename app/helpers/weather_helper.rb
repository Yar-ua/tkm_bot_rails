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


  def weather3_list(value)
    array = []
    (0..value['list'].count-1).each do |i|
      time = value['list'][i]['dt_txt']
      if time[11..18] == "18:00:00"
        array << value['list'][i]
      end
    
    end
    answer = array
    return answer
  end

  
  def rate_list(value)
    answer = "------
    наличный курс валют по отделениям ПБ:
    #{value[0]['ccy']} к #{value[0]['base_ccy']}: покупка #{(value[0]['buy']).to_f.round(3)}, продажа #{(value[0]['sale']).to_f.round(3)}
    #{value[1]['ccy']} к #{value[1]['base_ccy']}: покупка #{(value[1]['buy']).to_f.round(3)}, продажа #{(value[1]['sale']).to_f.round(3)}
    #{value[2]['ccy']} к #{value[2]['base_ccy']}: покупка #{(value[2]['buy']).to_f.round(3)}, продажа #{(value[2]['sale']).to_f.round(3)}"
  end


end
