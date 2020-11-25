# DinDonDan - Daily Readings

An open source app by DinDonDan to display catholic mass daily readings.

## How to build

This app is based on Flutter framework and relies on Firebase Cloud Firestore for data sourcing. In order to build your own version:

- Set up Flutter as explained in the [documentation](https://flutter.dev/docs/get-started/install)
- Set up a Firebase account and register your app following the [official guide](https://firebase.google.com/docs/flutter/setup). You will be provided a configuration file for each platform to insert into the project folder.
- Populate your Cloud Firestore database (that can be accessed from [Firebase Console](https://console.firebase.google.com)) with the readings data, according the data format illustrated in [ReadingsRepository.dart](lib/ReadingsRepository.dart).