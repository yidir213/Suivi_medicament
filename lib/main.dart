import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'shared_preferences_helper.dart';
import 'package:intl/date_symbol_data_local.dart';



void main() {
  initializeDateFormatting().then((_) {
    runApp(MyApp());
  });
}
//run the principal app

class MyApp extends StatelessWidget { //groupview
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ButtonPage(),
    );
  }
}

class ButtonPage extends StatefulWidget {
  @override
  _ButtonPageState createState() => _ButtonPageState();
}

class _ButtonPageState extends State<ButtonPage> {
  late bool _isButtonEnabled=true;
  late CalendarFormat _calendarFormat;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  late SharedPreferences _prefs;
  Color buttonColor = Colors.grey;
  Map<DateTime, List<dynamic>> _markedDays = {};

  @override
  void initState() {
    super.initState();

    _calendarFormat = CalendarFormat.month;
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now().add(Duration(days: 1));
    _initializeSharedPreferences();
  }

  Future<void> _initializeSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _checkButtonState(); // Call the initial check after SharedPreferences is initialized
  }

  Future<void> _checkButtonState() async {
    bool? isButtonChecked = _prefs.getBool('isButtonChecked');
    if (isButtonChecked == null) {
      Color buttonColor = Colors.red;
      _isButtonEnabled = true;
    } else {
      DateTime now = DateTime.now();
      DateTime lastCheckedTime = DateTime.fromMillisecondsSinceEpoch(
          _prefs.getInt('lastCheckedTime') ?? 0);
      if (now.day == lastCheckedTime.day) {
        _isButtonEnabled = false;
        buttonColor = Colors.green;
      } else {
        Color buttonColor = Colors.red;
        _isButtonEnabled = true;
      }
    }

    // Retrieve all previously checked days and mark them in the calendar
    String? encoded=_prefs.getString("checkedDays");
    Map<DateTime, List<dynamic>> checkedDays = {};

    if(encoded!=null && encoded.isNotEmpty){
      checkedDays=SharedPreferencesHelper.decodeMap(encoded);
    }
    _markedDays = checkedDays;
  }

  Future<void> _handleButtonPress() async {
    setState(() {

      _isButtonEnabled = false;
      buttonColor = Colors.green;
      _prefs.setBool('isButtonChecked', true);
      _prefs.setInt('lastCheckedTime', DateTime.now().millisecondsSinceEpoch);

      // Mark the checked day in the calendar
      DateTime now = DateTime.now();
      DateTime dateOnly = DateTime(now.year, now.month, now.day);

      _markedDays[dateOnly] = [];
      _prefs.setString('checkedDays', SharedPreferencesHelper.encodeMap(_markedDays));
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _initializeSharedPreferences(),
    builder: (context, snapshot) {
    // if (snapshot.connectionState == ConnectionState.waiting) {
    // return Center(child: CircularProgressIndicator()); // Or any other loading indicator
    // } else {

    return Scaffold(
      appBar: AppBar(
        title: Text('Medicaments Papa'),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'fr_FR',
            firstDay: DateTime.utc(2023, 12, 28),
            lastDay: DateTime.utc(2025, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {

             if(!(isSameDay(day,DateTime.now()))) {return isSameDay(_selectedDay, day);}
             return false;
            },
            // onDaySelected: (selectedDay, focusedDay) {
            //   setState(() {
            //     _selectedDay = selectedDay;
            //     _focusedDay = focusedDay;
            //   });
            // },
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, date, _) {
          DateTime dateOnly = DateTime(date.year, date.month, date.day);
          bool isChecked=false;
          String? encoded=_prefs.getString("checkedDays");
          Map<DateTime, List<dynamic>> checkedDays = {};

          print(encoded!=null); print("h"); print(encoded!=null&&encoded.isNotEmpty);
          if(encoded!=null && encoded.isNotEmpty){
            checkedDays=SharedPreferencesHelper.decodeMap(encoded);
            print(checkedDays);
            print("date");print(dateOnly);
          }
          isChecked=checkedDays.containsKey(dateOnly);print("checked");print(isChecked);
          // String dateString = date.toIso8601String();
          // String? encoded=_prefs.getString("checkedDays");
          // if(encoded!=null){
          //   isChecked  = jsonDecode(encoded).containsKey(dateString);
          // }
          //

          bool istoday=checkedDays.containsKey(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day));

           if (isChecked ) {
            return Center(
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                child: Center(
                  child: Text(
                    '${date.day}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          } else {
            return Center(
              child: Container(
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: TextStyle(
                    color: Colors.black, // Maintain default text color
                  ),
                ),
              ),
            );
           }

        },
        todayBuilder: (context, date, _) {
          String? encoded=_prefs.getString("checkedDays");
          Map<DateTime, List<dynamic>> checkedDays = {};
          DateTime dateOnly = DateTime(date.year, date.month, date.day);

          print(encoded!=null); print("h"); print(encoded!=null&&encoded.isNotEmpty);
          if(encoded!=null && encoded.isNotEmpty){
            checkedDays=SharedPreferencesHelper.decodeMap(encoded);
            print(checkedDays);
            print("date");print(dateOnly);
          }

          bool istoday=checkedDays.containsKey(DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day));
          if(istoday){
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.green, // Example: Highlight in blue for the current day
            ),
    child: Center(
    child: Stack(
    children: [
    // Contour text (slightly larger and positioned behind)
    Positioned(
    top: 2.0, // Adjust the position as needed
    left: 2.0, // Adjust the position as needed
    child: Text(
    '${date.day}',
    style: TextStyle(
    color: Colors.black, // Contour color
    fontWeight: FontWeight.bold,
    fontSize: 20, // Slightly larger font size
    ),
    ),
    ),
    // Main text
    Text(
    '${date.day}',
    style: TextStyle(
    color: Colors.white, // Main text color
    fontWeight: FontWeight.bold,
    fontSize: 20,
    ),
    ),
    ],
    ),
    ),
          );
        }},
      ),
    ),
          ElevatedButton(
            onPressed: _isButtonEnabled != null && _isButtonEnabled!
                ? _handleButtonPress
                : null,
            child: Container(
              width: 100, // Adjust width as needed
              height: 100, // Adjust height as needed
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  'Swigh dwa-inou',
                  style: TextStyle(fontSize: 16), // Adjust font size as needed
                ),
              ),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(buttonColor),
            ),
          ),
        ],
      ),
    );
  }
// }
  );
}
}
