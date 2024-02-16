import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:table_calendar/table_calendar.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Иницијализација на локални нотификации
  await initLocalNotifications();

  runApp(MyApp());
}

Future<void> initLocalNotifications() async {
  final InitializationSettings initializationSettings =
  InitializationSettings(
    android: AndroidInitializationSettings('app_icon'), // Име на иконата во mipmap
    iOS: IOSInitializationSettings(),
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Колоквиуми и Испити',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            return TermScheduleScreen();
          } else {
            return AuthenticationScreen();
          }
        }
      },
    );
  }
}

class AuthenticationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Автентикација'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Додадете Firebase автентикација код тука
          },
          child: Text('Најава со Firebase'),
        ),
      ),
    );
  }
}

class TermScheduleScreen extends StatefulWidget {
  @override
  _TermScheduleScreenState createState() => _TermScheduleScreenState();
}

class _TermScheduleScreenState extends State<TermScheduleScreen> {
  CalendarController _calendarController;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Колоквиуми и Испити'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Отворете дијалог за додавање на нов термин
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar(
            calendarController: _calendarController,
            events: {
              DateTime.now(): ['Колоквиум по математика'],
              DateTime.now().add(Duration(days: 2)): ['Испит по програмирање'],
              DateTime.now().add(Duration(days: 4)): ['Консултации по предмет X'],
            },
            calendarStyle: CalendarStyle(
              todayColor: Colors.blue,
              selectedColor: Theme.of(context).accentColor,
              todayStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                fontWeight: FontWeight.bold,
              ),
              weekendStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            eventDayStyle: EventDayStyle(
              textStyle: TextStyle(
                color: Colors.black,
              ),
            ),
            onDaySelected: (date, events, holidays) {
              print(date);
              print(events);
              print(holidays);
            },
          ),
          Expanded(
            child: TermList(),
          ),
        ],
      ),
    );
  }
}

class TermList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Додадете код за прикажување на листа со термини
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
      ),
      itemCount: 5, // Пример број на термини
      itemBuilder: (context, index) {
        return TermCard();
      },
    );
  }
}

class TermCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Предмет Име',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Датум и време',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
