import 'package:flutter/material.dart';
import 'package:first_project/pages/automatePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ThemeData _theme = ThemeData.light();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Langage Formel',
      theme: _theme,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Test Concepts Langage formel'),
          ),
          bottomNavigationBar: TabBar(
            tabs: <Widget>[
              Tab(
                  icon: Icon(
                    Icons.autofps_select_outlined,
                    color: _theme.primaryColorDark,
                  ),
                  child: Text(
                    'Automate',
                    style: TextStyle(color: _theme.primaryColorDark),
                  )),
              Tab(
                  icon: Icon(
                    Icons.book_sharp,
                    color: _theme.primaryColorDark,
                  ),
                  child: Text(
                    'Grammaire',
                    style: TextStyle(color: _theme.primaryColor),
                  )),
            ],
          ),
          body: const TabBarView(children: [
            AutomatePage(
              title: '',
            ),
            Text('data')
          ]),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
