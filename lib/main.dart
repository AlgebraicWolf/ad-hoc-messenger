import 'package:ad_hoc_messenger/utility/contact.dart';
import 'package:cat_avatar_generator/cat_avatar_generator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:dartz/dartz.dart' hide State;
import 'state.dart';
import 'utility/contact.dart';
import 'utility/messages.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_nearby_connections/flutter_nearby_connections.dart';
import 'package:dash_chat/dash_chat.dart' as DashChat;

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
        '/chat': (context) => ChatPage(),
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
    final state = ModalRoute.of(context).settings.arguments as MessengerState;
    print("Current handle is ${state.handle}");

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
              builder = (BuildContext context) => ChatsPage(state);
              break;
            case '/addFriend':
              builder = (BuildContext context) => AddFriendPage(state);
              break;
            case '/settings':
              builder = (BuildContext context) => SettingsPage(state);
              break;
            case '/chat':
              builder = (BuildContext context) => ChatsPage(state);
              Navigator.pushNamed(context, '/chat',
                  arguments: settings.arguments);
              break;
            default:
              throw "Invalid route name, lol";
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
            TabItem(icon: Icons.add, title: "Add friend"),
            TabItem(icon: Icons.settings, title: "Settings"),
          ],
          onTap: (int i) {
            final pages = <String>['/', '/addFriend', '/settings'];
            _navigatorKey.currentState.pushReplacementNamed(pages[i]);
          }),
    );
  }
}

class ChatEntry extends StatelessWidget {
  final Option<String> _handle;
  final MessengerState _state;
  ChatEntry(this._handle, this._state);

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
          onTap: () {
            Navigator.pushNamed(context, '/chat',
                arguments: _state.copy(friend: _handle));
          },
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
  final MessengerState _state;
  ChatsPage(this._state);

  Future<List<Contact>> _getUserContacts() async {
    return DatabaseManager()
        .db
        .then((_) => DatabaseManager().getUserContacts());
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final groupChat = ChatEntry(None(), state);

    return FutureBuilder(
      future: _getUserContacts(),
      builder: (BuildContext context, AsyncSnapshot<List<Contact>> snapshot) {
        if (snapshot.hasData) {
          final handles = snapshot.data.map((e) => Some(e.handle));
          final entries = [groupChat] +
              handles.map((handle) => ChatEntry(handle, state)).toList();

          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (BuildContext, int) => Divider(),
            itemBuilder: (BuildContext, int index) => entries[index],
          );
        } else if (snapshot.hasError) {
          print(snapshot.error.toString());
          return Text("Error with contacts route");
        } else {
          return Text("Waiting");
        }
      },
    );
  }
}

class SettingsPage extends StatelessWidget {
  final MessengerState _state;
  SettingsPage(this._state);

  @override
  Widget build(BuildContext context) {
    return Text("Ностройки");
  }
}

class AddFriendPage extends StatelessWidget {
  final MessengerState _state;
  AddFriendPage(this._state);

  @override
  Widget build(BuildContext context) {
    return Text("Here you can add a friend");
    // TODO Get user handle and pull the required data from the server
  }
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  DashChat.ChatUser _userFromHandle(String handle) {
    return DashChat.ChatUser(
      name: handle,
      uid: handle,
    );
  }

  Future<List<ChatMessage>> _getCorrespondance(Option<String> handle) async {
    final unfolded_handle = handle.cata(() => "__groupchat__", (a) => a);

    return DatabaseManager()
        .getCorrespondance(Contact(unfolded_handle, "", ""));
  }

  @override
  Widget build(BuildContext context) {
    final state = ModalRoute.of(context).settings.arguments as MessengerState;
    final friend = state.friend; // Get friend we're currently talking to
    final unfoldedFriend = friend.cata(() => '__groupchat__', (a) => a);
    // TODO: Make the interface
    // TODO: Make the helper classes like chat bubbles etc
    // TODO: Find the way to pull message history
    // TODO: Figure out how to do things we need to do

    return Scaffold(
      appBar: AppBar(
        title: Text(
          state.friend.cata(() => "Local chat", (a) => "@" + a),
        ),
      ),
      body: FutureBuilder(
        future: _getCorrespondance(friend),
        builder: (BuildContext ctx, AsyncSnapshot<List<ChatMessage>> msgs) {
          if (msgs.hasData) {
            return DashChat.DashChat(
              user: _userFromHandle(state.handle),
              onSend: (DashChat.ChatMessage msg) {
                print(
                    "Sending ${state.handle == msg.user.uid} message ${msg.text} from ${msg.user.name} created at ${msg.createdAt}");

                DatabaseManager()
                    .newMessage(ChatMessage(unfoldedFriend,
                        msg.user.uid == state.handle, msg.text, msg.createdAt))
                    .then((_) => (context as Element).markNeedsBuild());
              },
              avatarBuilder: (DashChat.ChatUser user) => CircleAvatar(
                backgroundColor: Colors.grey,
                child: Image(image: MeowatarImage.fromString('@' + user.name)),
              ),
              messages: msgs.data.map((message) {
                print(message.mine);
                return DashChat.ChatMessage(
                  text: message.text,
                  user: _userFromHandle(
                      message.mine ? state.handle : message.otherHandle),
                  createdAt: message.sentAt,
                );
              }).toList(),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
