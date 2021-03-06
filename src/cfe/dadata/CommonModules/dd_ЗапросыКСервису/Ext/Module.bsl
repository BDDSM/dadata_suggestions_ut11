﻿
Функция ПолучитьСоответствиеПодсказок(Текст, ВидПодсказки) Экспорт
	
	НастройкиПодсистемы = dd_ОбщийМодульПовторноеИспользование.ПолучитьНастройкиПодсистемы();
	
	СоответствиеОтвет = Новый Соответствие;
	
	Если НЕ НастройкиПодсистемы.ИспользованиеСервиса Тогда
		Возврат СоответствиеОтвет;
	КонецЕсли;
	
	СоответствиеДанные = Новый Соответствие;
	СоответствиеДанные.Вставить("query", Текст);
	СтрокаДанные = В_JSON(СоответствиеДанные);
	
	АдресРесурса = "/suggestions/api/4_1/rs";
	
	Если ВидПодсказки = "Адрес" Тогда
		АдресРесурса = АдресРесурса + "/suggest/address";
		
	ИначеЕсли ВидПодсказки = "ФИО" Тогда
		АдресРесурса = АдресРесурса + "/suggest/fio";
		
	ИначеЕсли ВидПодсказки = "ОрганизацияНаименование" Тогда
		АдресРесурса = АдресРесурса + "/suggest/party";
		
	ИначеЕсли ВидПодсказки = "ОрганизацияИНН" Тогда
		АдресРесурса = АдресРесурса + "/findById/party";
		
	Иначе
		Возврат СоответствиеОтвет;
	КонецЕсли;
	
	ДанныеОтвет = POST(АдресРесурса, СтрокаДанные);
	
	Если ДанныеОтвет.КодСостояния = 200 Тогда
		
		СтрокаДанныеОтвет = ДанныеОтвет.ПолучитьТелоКакСтроку();
		СоответствиеОтвет = ИЗ_JSON(СтрокаДанныеОтвет);
		
	КонецЕсли;
	
	Возврат СоответствиеОтвет;
	
КонецФункции

Функция СформироватьКИФормата1С(СоответствиеАдресДаДата) Экспорт
	
	СтруктураДанных = Новый Структура;
	СтруктураДанных.Вставить("Комментарий", "");
	СтруктураДанных.Вставить("КонтактнаяИнформация", "");
	СтруктураДанных.Вставить("Корректный", Неопределено);
	СтруктураДанных.Вставить("Представление", "");
	
	СтруктураДанных.Представление = СоответствиеАдресДаДата.Получить("unrestricted_value");
	
	АдресДаДатаДанные = СоответствиеАдресДаДата.Получить("data");
	
	
	Результат = РаботаСАдресамиКлиентСервер.ОписаниеНовойКонтактнойИнформации(ПредопределенноеЗначение("Перечисление.ТипыКонтактнойИнформации.Адрес"));
	
	Результат.Вставить("Country", "Россия");
	Результат.Вставить("CountryCode", "643");
	Результат.Вставить("Value", СоответствиеАдресДаДата.Получить("unrestricted_value"));
	
	Результат.AddressType = РаботаСАдресамиКлиентСервер.АдминистративноТерриториальныйАдрес();
	
	Результат.ZIPCode = Строка(АдресДаДатаДанные.Получить("postal_code"));
	Результат.OKTMO = Строка(АдресДаДатаДанные.Получить("oktmo"));
	Результат.OKATO = Строка(АдресДаДатаДанные.Получить("okato"));
	
	Результат.Area     = Строка(АдресДаДатаДанные.Получить("region"));
	Результат.AreaType = Строка(АдресДаДатаДанные.Получить("region_type"));
	
	Результат.District     = Строка(АдресДаДатаДанные.Получить("area"));
	Результат.DistrictType = Строка(АдресДаДатаДанные.Получить("area_type"));
	
	Результат.City     = Строка(АдресДаДатаДанные.Получить("city"));
	Результат.CityType = Строка(АдресДаДатаДанные.Получить("city_type"));
	
	Если Результат.City = "Москва" Тогда
		Результат.City = "";
		Результат.CityType = "";
	КонецЕсли;
	
	Результат.Locality     = Строка(АдресДаДатаДанные.Получить("settlement"));
	Результат.LocalityType = Строка(АдресДаДатаДанные.Получить("settlement_type"));
	
	Результат.Street     = Строка(АдресДаДатаДанные.Получить("street"));
	Результат.StreetType = Строка(АдресДаДатаДанные.Получить("street_type"));
	
	Результат.CityDistrict     = Строка(АдресДаДатаДанные.Получить("city_district"));
	Результат.CityDistrictType = Строка(АдресДаДатаДанные.Получить("city_district_type"));
	
	Если Не ПустаяСтрока(АдресДаДатаДанные.Получить("house")) Тогда
		
		house_type = АдресДаДатаДанные.Получить("house_type");
		
		Если house_type = "д" Тогда
			
			Результат.HouseType = "Дом";
			Результат.HouseNumber = АдресДаДатаДанные.Получить("house");
			
		ИначеЕсли house_type = "влд" Тогда
			
			Результат.HouseType = "Владение";
			Результат.HouseNumber = АдресДаДатаДанные.Получить("house");
			
		ИначеЕсли house_type = "двлд" Тогда			
			
			Результат.HouseType = "Домовладение";
			Результат.HouseNumber = АдресДаДатаДанные.Получить("house");
			
		ИначеЕсли house_type = "к" Тогда
			Результат.Buildings.Добавить(УправлениеКонтактнойИнформациейКлиентСервер.ЗначениеСтроенияИлиПомещения("Корпус", АдресДаДатаДанные.Получить("house")));
		КонецЕсли;
		
	КонецЕсли;
	
	Если Не ПустаяСтрока(АдресДаДатаДанные.Получить("block")) Тогда
		
		block_type = АдресДаДатаДанные.Получить("block_type");
		
		Если block_type = "стр" Тогда
			Тип = "Строение";
		ИначеЕсли block_type = "к" Тогда
			Тип = "Корпус";
		ИначеЕсли block_type = "сооружение" Тогда
			Тип = "Сооружение";	
		ИначеЕсли block_type = "литер" Тогда
			Тип = "Литер";
		Иначе
			Тип = "";
		КонецЕсли;
		
		Результат.Buildings.Добавить(УправлениеКонтактнойИнформациейКлиентСервер.ЗначениеСтроенияИлиПомещения(Тип, АдресДаДатаДанные.Получить("block")));
		
	КонецЕсли;
	
	Если Не ПустаяСтрока(АдресДаДатаДанные.Получить("flat")) Тогда
		
		flat_type = АдресДаДатаДанные.Получить("flat_type");
		
		Если block_type = "оф" Тогда
			Тип = "Офис";
		ИначеЕсли block_type = "кв" Тогда
			Тип = "Квартира";
		ИначеЕсли block_type = "эт" Тогда
			Тип = "Этаж";	
		ИначеЕсли block_type = "пом" Тогда
			Тип = "Помещение";
		Иначе
			Тип = "";
		КонецЕсли;
		
		Результат.Apartments.Добавить(УправлениеКонтактнойИнформациейКлиентСервер.ЗначениеСтроенияИлиПомещения(Тип, АдресДаДатаДанные.Получить("flat")));
		
	КонецЕсли;
	
	СтруктураДанных.КонтактнаяИнформация = dd_ЗапросыКСервису.В_JSON(Результат);
	
	Возврат СтруктураДанных;
	
КонецФункции

//--

Функция POST(АдресРесурса, СтрокаДанные, ИмяСобытия = "POST запрос") Экспорт
	
	HTTPСтруктура = ПолучитьHTTPСтруктура(АдресРесурса);
	
	HTTPЗапрос = HTTPСтруктура.HTTPЗапрос;
	HTTPСоединение = HTTPСтруктура.HTTPСоединение;
	
	HTTPЗапрос.УстановитьТелоИзСтроки(СтрокаДанные);
	
	Попытка
		
		HTTPОтвет = HTTPСоединение.ОтправитьДляОбработки(HTTPЗапрос);
		
	Исключение
		СообщитьОбОшибке(ИмяСобытия, ОписаниеОшибки());
		Отказ = Истина;
		HTTPОтвет = Новый Структура;
		HTTPОтвет.Вставить("КодСостояния", 500);
		
	КонецПопытки;
	
	ПроверитьНаКодыОшибок(HTTPОтвет, "POST " + АдресРесурса, ИмяСобытия);
	
	Возврат HTTPОтвет;
	
КонецФункции

Процедура ПроверитьНаКодыОшибок(HTTPОтвет, ОписаниеЗапроса, ИмяСобытия)
	
	КодСостояния = HTTPОтвет.КодСостояния;
	
	Если КодСостояния = 301
		ИЛИ КодСостояния = 302 
		ИЛИ КодСостояния = 501 
		ИЛИ КодСостояния = 401
		ИЛИ КодСостояния = 500
		Тогда
		
		СообщитьОбОшибке(ИмяСобытия, ОписаниеЗапроса + Символы.ПС + "КодСостояния: " + КодСостояния);
		
		Отказ = Истина;
		
	ИначеЕсли КодСостояния = 400 Тогда 
		СообщитьОбОшибке(ИмяСобытия, ОписаниеЗапроса + Символы.ПС + "КодСостояния: " + КодСостояния  + Символы.ПС + HTTPОтвет.ПолучитьТелоКакСтроку());
	КонецЕсли;
	
КонецПроцедуры

//--------

Функция ПолучитьHTTPСтруктура(АдресРесурса)
	
	НастройкиПодсистемы = dd_ОбщийМодульПовторноеИспользование.ПолучитьНастройкиПодсистемы();
	
	ИмяСервера = "suggestions.dadata.ru";
	Порт = 443;
	
	ssl4 = Новый ЗащищенноеСоединениеOpenSSL(Неопределено, Неопределено);
	
	HTTPСоединение = Новый HTTPСоединение(ИмяСервера,Порт,,,,,ssl4);
	
	Заголовки = Новый Соответствие;
	Заголовки.Вставить("Content-type", "application/json");
	Заголовки.Вставить("Accept", "application/json");
	Заголовки.Вставить("Authorization", "Token " + НастройкиПодсистемы.КлючДоступа);
	
	HTTPЗапрос = Новый HTTPЗапрос(АдресРесурса, Заголовки);
	
	HTTPСтруктура = Новый Структура;
	HTTPСтруктура.Вставить("HTTPСоединение", HTTPСоединение);
	HTTPСтруктура.Вставить("HTTPЗапрос", HTTPЗапрос);
	
	Возврат HTTPСтруктура; 
		
КонецФункции


Функция В_JSON(СоответствиеДанные, Отказ = Ложь) Экспорт
	
	Попытка
		
		ЗаписьJSON = Новый ЗаписьJSON;
		ЗаписьJSON.УстановитьСтроку();
		
		ЗаписатьJSON(ЗаписьJSON, СоответствиеДанные);
		
		СтрокаДанные = ЗаписьJSON.Закрыть();
		
		Возврат СтрокаДанные;
		
	Исключение
		
		Отказ = Истина;
		Сообщить(ОписаниеОшибки());
		
		Возврат Неопределено;
		
	КонецПопытки;
	
КонецФункции

Функция ИЗ_JSON(Строка_JSON, Отказ = Ложь, ИменаСвойствСоЗначениямиДата = "") Экспорт
	
	Попытка
		
		ЧтениеJSON = Новый ЧтениеJSON;
		ЧтениеJSON.УстановитьСтроку(Строка_JSON);
		
		Возврат ПрочитатьJSON(ЧтениеJSON, Истина, ИменаСвойствСоЗначениямиДата);
		
	Исключение
		Отказ = Истина;
		Сообщить(ОписаниеОшибки());
		
		Возврат Неопределено;
		
	КонецПопытки;
	
	
КонецФункции


Процедура СообщитьОбОшибке(ИмяСобытия, Комментарий, Уровень = "", Данные = Неопределено) Экспорт
		
	Сообщение = Новый СообщениеПользователю;
	Сообщение.Текст = "" + Комментарий;
	Сообщение.Сообщить();
	
КонецПроцедуры
