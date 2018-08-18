import 'package:flutter/material.dart';

class HelloRectangle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.lightBlue,
        height: 400.0,
        width: 250.0,
        child: Center(
          child: Text("howdie!",
          style: new TextStyle(color: Colors.purple,
          fontSize: 30.0),),
        ),
      ),
    );
  }
}

void main() {
  print("42");
  runApp(new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new Scaffold(
        appBar: new AppBar(
          title: Text("42"),
          centerTitle: true,
          backgroundColor: Colors.amber,
        ),
        body: HelloRectangle(),
      )));
}

//import 'package:flutter/material.dart';
//
//void main() {
//  runApp(
//    MaterialApp(
//      debugShowCheckedModeBanner: false,
//      title: 'Hello Rectangle',
//      home: Scaffold(
//        appBar: AppBar(
//          title: Text('Hello Rectangle'),
//        ),
//        body: HelloRectangle(),
//      ),
//    ),
//  );
//}
//
//class HelloRectangle extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return Center(
//      child: Container(
//        color: Colors.greenAccent,
//        height: 400.0,
//        width: 300.0,
//        child: Center(
//          child: Text(
//            'Hello!',
//            style: TextStyle(fontSize: 40.0),
//            textAlign: TextAlign.center,
//          ),
//        ),
//      ),
//    );
//  }
//}
