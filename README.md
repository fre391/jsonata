

JSONata plugin for Flutter

## Features

The Jsonata plugin provides functionality for querying and transforming JSON data using Jsonata expressions. 

## Getting started

Permissions:
As this plugin uses the latest version of jsonata from you need to enable internet permission:

    Android:
        In your AndroidManifest.xml, you’ll need to include the following permission to allow internet access:
        <uses-permission android:name="android.permission.INTERNET" />

    macOS /iOS:
        For macOS and iOS, you’ll need to configure entitlements. In your DebugProfile.entitlements and ReleaseProfile.entitlements files, add the following key to allow network access:

        DebugProfile.entitlements:
            <key>com.apple.security.network.client</key>
            <true/>    
        ReleaseProfile.entitlements:
            <key>com.apple.security.network.client</key>
            <true/>
        Info.plist
            <key>NSAllowsArbitraryLoads</key>
            <true/>

## Usage

The plugin allows you to extract specific information from your data by applying Jsonata queries. Here are the three alternative ways to use it:

Alternative 1:
In this approach, you directly evaluate the Jsonata expression (jql) against the provided data. 
```dart
var json = await Jsonata(jql).evaluate(data);
```

Alternative 2:
Here, you create a Jsonata expression object and then evaluate it against the data. 
```dart
var expression = Jsonata(jql);
var json = await expression.evaluate(data);
```

Alternative 3:
This method involves setting the data explicitly in the Jsonata instance and then querying it with the specified expression.
```dart
var jsonata = Jsonata();
jsonata.set(data: data);
var json = await jsonata.query(jql);
```


