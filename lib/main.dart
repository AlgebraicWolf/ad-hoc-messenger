import 'package:ad_hoc_messenger/utility/contact.dart';
import 'package:cat_avatar_generator/cat_avatar_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:dartz/dartz.dart';
import 'state.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';

import 'package:ad_hoc_messenger/databaseManager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DatabaseManager().initDB();
  DatabaseManager().newContact(Contact('wolf', 'key0', 'mr volkov'));
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle.light.copyWith(
      systemNavigationBarColor: Colors.purple,
      // statusBarColor: Colors.purple[600],
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ad-hoc Messenger',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => MainScreen(),
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  final handleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Align(
      child: Container(
        color: Colors.purple[300],
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: "Handle",
              ),
              controller: handleController,
            ),
            Container(
              height: 20.0,
            ),
            OutlinedButton(
              child: Text(
                "Login",
                style: TextStyle(
                  fontSize: 20.0,
                ),
              ),
              onPressed: () {
                if (handleController.text.isNotEmpty)
                  Navigator.pushReplacementNamed(context, '/home',
                      arguments: MessengerState(handleController.text, None()));
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.white),
                padding: MaterialStateProperty.all(EdgeInsets.all(10.0)),
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

class MainScreen extends StatelessWidget {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ad-hoc Messenger"),
      ),
      body: Navigator(
        key: _navigatorKey,
        initialRoute: '/',
        onGenerateRoute: (RouteSettings settings) {
          WidgetBuilder builder;
          switch (settings.name) {
            case '/':
              builder = (BuildContext context) => ChatsPage();
              break;
            case '/settings':
              builder = (BuildContext context) => SettingsPage();
              break;
            default:
              throw "Invalid route name";
          }

          return MaterialPageRoute(
            builder: builder,
            settings: settings,
          );
        },
      ),
      bottomNavigationBar: ConvexAppBar(
          style: TabStyle.react,
          backgroundColor: Colors.purple,
          items: [
            TabItem(icon: Icons.message, title: "Messages"),
            TabItem(icon: Icons.settings, title: "Settings"),
          ],
          onTap: (int i) {
            final pages = <String>['/', '/settings'];
            _navigatorKey.currentState.pushReplacementNamed(pages[i]);
          }),
    );
  }
}

class ChatEntry extends StatelessWidget {
  final Option<String> _handle;
  ChatEntry(this._handle);

  @override
  Widget build(BuildContext context) {
    String unfolded_handle =
        _handle.cata(() => "Local chat", (handle) => '@' + handle);

    return Slidable(
      actionPane: SlidableScrollActionPane(),
      actionExtentRatio: 0.15,
      child: Container(
        color: Colors.white,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            child: Image(image: MeowatarImage.fromString(unfolded_handle)),
          ),
          title: Text(unfolded_handle),
        ),
      ),
      actions: <Widget>[
        IconSlideAction(
          caption: "Wipe",
          color: Colors.yellowAccent,
          icon: Icons.remove,
          onTap: () {},
        ),
        IconSlideAction(
          caption: "Delete",
          color: Colors.redAccent,
          icon: Icons.delete,
          onTap: () {},
        )
      ],
    );
  }
}

class ChatsPage extends StatelessWidget {
  /*
  final availableChats = <Option<String>>[
    Some("fckxorg"),
    Some("BorisTab"),
    Some("AlgebraicWolf"),
    Some("akudrinsky"),
  ];
  */

  Future<List<Contact>> _getUserContacts() async {
    await DatabaseManager().db;
    return DatabaseManager().getUserContacts();
  }

  @override
  Widget build(BuildContext context) {
    final state = ModalRoute.of(context).settings.arguments as MessengerState;
    final groupChat = ChatEntry(None());

    return FutureBuilder(
      future: _getUserContacts(),
      builder: (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
        if (snapshot.hasData) {
          final handles = snapshot.data.map((e) => Some(e.handle));

          return ListView(
            children: [groupChat] +
                handles.map((handle) => ChatEntry(handle)).toList(),
          );
        } else if (snapshot.hasError) {
          print(snapshot.error.toString());
          return Text("Error with contacts rout");
        } else {
          return Text("Waiting");
        }
      },
    );
  }
}

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text("Ностройки");
  }
}
