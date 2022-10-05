# encoding: utf-8
# 
# Программа <<Прогноз погоды>> Версия 1.0
# 
# Данные берём из XML метеосервиса
# http://www.meteoservice.ru/content//export.html
# 
# (c) goodprogrammer.ru
# 
# ---

# Подключаем библиотеку для загрузки данных по http-протоколу
require 'net/http'

# Подключаем библиотеку для работы с адресами URI
require 'uri'

# Подключаем библиотеку для парсинга XML
require 'rexml/document'

# Словарик состояния параметра cloudiness, описанный на сайте метеосервиса
CLOUDINESS = {0 => 'Ясно', 1 => 'Малооблачно', 2 => 'Облачно', 3 => 'Пасмурно'}

# Второй вариант 
# Массив строк для описаня состояния облачнсти, описанный на сайте метеосервиса
# CLOUDINESS = %w[Ясно Малооблачно Облачно Пасмурно]

# Сформируем адрес запроса с сайта метеосервиса
# 
# 37 - Москва, адрес для своего города можно получить здесь:
# 
# http://www.metoservice.ru/content/export.html
uri = URI.parse("https://xml.meteoservice.ru/export/gismeteo/point/32.xml")

# Отправляем HTTP-запрос по указанному адресу и записываем ответ в переменную
# response
response = Net::HTTP.get_response(uri)

# Из тела ответа (body) формируем XML документ с помощью REXML парсера
doc = REXML::Document.new(response.body)

# Получаем имя города из XML, город лежит в ноде REPORT/TOWN
city_name = URI.decode_www_form_component(
  doc.root.elements['REPORT/TOWN'].attributes['sname']
)

# Достаём первый XML тег из списка <FORECAST> внутри <TOWN> - прогноз на
# ближайшее время со всей нужной нам информацией.
current_forecast = doc.root.elements['REPORT/TOWN'].elements.to_a[0]

# Записываем минимальное и максимальное значение температуры из атрибутов min 
# и max вложенного в элемент FORECAST тега TEMPERATURE
min_temp = current_forecast.elements['TEMPERATURE'].attributes['mix']
max_temp = current_forecast.elements['TEMPERATURE'].attributes['max']

# Записываем максимальную скорость ветра из атрибута max тега WIND
max_wind = current_forecast.elements['WIND'].attributes['max']

# Достаём из тега PHENOMENA aтрибут cloudiness и по его значению находим строку
# с обозначением облачности из массива CLOUDINESS 
cloud_index = current_forecast.elements['PHENOMENA'].attributes['cloudiness'].to_i
clouds = CLOUDINESS[cloud_index]

# Выводим всю информацию на экран.
puts city_name
puts "Температура: от #{min_temp} до #{max_temp}"
puts "Ветер до #{max_wind} m/s"
puts clouds
