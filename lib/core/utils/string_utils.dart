class StringUtils{
  const StringUtils._();

  static String? dayName(int daysFromToday) {
    if(daysFromToday == 0)
      return "Today";
    if(daysFromToday == 1)
      return "Tomorrow";
    return weekDayToString(DateTime.now().add(Duration(days: daysFromToday)).weekday);
  }

  // ignore: missing_return
  static String? weekDayToString(int weekday){
    switch(weekday){
      case 7:
        return "Sunday";
      case 1:
        return "Monday";
      case 2:
        return "Tuesday";
      case 3:
        return "Wednesday";
      case 4:
        return "Thursday";
      case 5:
        return "Friday";
      case 6:
        return "Saturday";
    }
    return null;
  }

  static String getWeatherIconUrl(int iconNumber){
    String num = (iconNumber<10) ? "0$iconNumber": "$iconNumber";
    return "https://developer.accuweather.com/sites/default/files/$num-s.png";
  }
}
