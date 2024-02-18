import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:location/location.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

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

  // Иницијализација на локациски сервиси
  Location location = Location();
  await location.serviceEnabled();
  location.requestPermission();

  // Иницијализација на локациски потсетници
  GeoFlutterFire geo = GeoFlutterFire();
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
        // Пример настан со локација (координати)
        EventWithLocation event = EventWithLocation(
          name: 'Предмет Име',
          dateTime: DateTime.now(),
          location: LocationData.fromMap({
            'latitude': 41.8781, // Пример: Координати за Њујорк
            'longitude': -87.6298,
          }),
        );
        return TermCard(event: event);
      },
    );
  }
}

class TermCard extends StatelessWidget {
  final EventWithLocation event;

  TermCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            event.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Датум и време: ${event.dateTime}',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 8),
          Container(
            height: 150, // Пример висина на мапата
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  event.location.latitude,
                  event.location.longitude,
                ),
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('event_location'),
                  position: LatLng(
                    event.location.latitude,
                    event.location.longitude,
                  ),
                ),
              },
              polylines: {
                Polyline(
                  polylineId: PolylineId('route_to_event'),
                  color: Colors.blue,
                  points: [], // Празна листа, ќе се дополни со координати
                ),
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Пресметка на најкратка рута
              PolylinePoints polylinePoints = PolylinePoints();
              List<PointLatLng> result = await polylinePoints.getRouteBetweenCoordinates(
                'AIzaSyA4YZO6pW_3k0veX333TD967ru8wT3UGwY',
                event.location.latitude,
                event.location.longitude,
                // Дополнителни точки може да се додадат за рутата
              );

              // Ажурирање на полилинијата на мапата со новите координати
              if (result.isNotEmpty) {
                List<LatLng> routeCoordinates = result
                    .map((point) => LatLng(point.latitude, point.longitude))
                    .toList();

                setState(() {
                  Polyline polyline = Polyline(
                    polylineId: PolylineId('route_to_event'),
                    color: Colors.blue,
                    points: routeCoordinates,
                  );

                  // Додајте полилинијата на мапата
                  _polylines.add(polyline);
                });
              }
            },
            child: Text('Прикажи најкратка рута'),
          ),
        ],
      ),
    );
  }
}

class EventWithLocation {
  final String name;
  final DateTime dateTime;
  final LocationData location;

  EventWithLocation({required this.name, required this.dateTime, required this.location});
}
