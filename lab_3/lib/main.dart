import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
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

class TermScheduleScreen extends StatelessWidget {
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
      body: TermList(),
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
