import 'package:flutter/material.dart';
import 'package:jsonata/jsonata.dart';

void main() {
  runApp(
    const MaterialApp(home: MyHomePage()), // use MaterialApp
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String data = '''{
        "FirstName": "Fred",
        "Surname": "Smith",
        "Age": 28,
        "Gender": "Male",
        "Married": false,
        "Address": {
          "Street": "Hursley Park",
          "City": "Winchester",
          "Postcode": "SO21 2JN"
        },
        "Children": ["John","Jane","Jill"]
      }''';
  String jql = "Address.City='Winchester'";
  String result = "";

  @override
  void initState() {
    super.initState();
  }

  query() async {
    try {
      // Alternative 1:
      //var json = await Jsonata(jql).evaluate(data);

      // Alternative 2:
      //var expression = Jsonata(jql);
      //var json = await expression.evaluate(data);

      // Alternative 3:
      var jsonata = Jsonata();
      jsonata.set(data: data);
      var json = await jsonata.query(jql);

      setState(() {
        result = json.toString();
      });
    } catch (e) {
      setState(() {
        result = 'Error: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Jsonata Query App'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: null,
                maxLength: 120,
                decoration: InputDecoration(
                  hintText: data,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => data = value,
              ),
              TextFormField(
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 3,
                maxLength: 120,
                decoration: InputDecoration(
                  hintText: jql,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) => jql = value,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: query,
                child: const Text('Query'),
              ),
              const SizedBox(height: 20),
              Text(
                result,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
