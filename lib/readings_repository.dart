import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'common/enums.dart';
import 'common/extensions.dart';

/// An object that handles data sourcing for the readings
class ReadingsRepository {
  ReadingsDataIdentifier _id;
  ReadingsDataIdentifier get id => _id;

  static final readingsStreamController = StreamController<ReadingsSnapshot>();
  static final calendarIntervalStreamController =
      StreamController<DayInterval>();

  /// A stream of [ReadingsData] objects
  final Stream<ReadingsSnapshot> readingsStream;

  /// A stream of [DayInterval] objects
  final Stream<DayInterval> calendarIntervalStream;

  /// Creates an object that handles data sourcing from Firebase Cloud
  /// Firestore, for the given [ReadingsDataIdentifier]
  ReadingsRepository([ReadingsDataIdentifier id])
      : readingsStream = readingsStreamController.stream,
        calendarIntervalStream = calendarIntervalStreamController.stream {
    if (id != null) {
      this.id = id;
    }
  }

  set id(ReadingsDataIdentifier value) {
    if (this.id == null ||
        value.day != this.id.day ||
        value.rite != this.id.rite) {
      getReadingsStream(value)
          .listen((snapshot) => readingsStreamController.add(snapshot));
    }
    if (this.id == null || value.day != this.id.day) {
      //getCalendarIntervalStream(value.rite).listen((snapshot) => calendarIntervalStreamController.add(snapshot));
    }

    this._id = value;
  }

  /// Creates [Stream] of [ReadingsData] objects from the remote
  /// repository for the given [day]
  static Stream<ReadingsSnapshot> getReadingsStream(ReadingsDataIdentifier id) {
    return FirebaseFirestore.instance
        .collection('readings')
        .doc(id.serialize())
        .snapshots()
        .map<ReadingsSnapshot>((snapshot) {
      if (snapshot.exists) {
        return ReadingsSnapshot.fromFirebase(id, snapshot.data());
      } else {
        if (snapshot.metadata.isFromCache) {
          return ReadingsSnapshot.notDownloaded(id);
        } else {
          return ReadingsSnapshot.nonExistent(id);
        }
      }
    });
  }

  /// Creates a broadcast [Stream] of [DayInterval] that describes the dates of
  /// the available readings for the selected rite
  static Stream<DayInterval> getCalendarIntervalStream(Rite rite) {
    return FirebaseFirestore.instance
        .collection('meta')
        .doc('calendar')
        .snapshots()
        .map<DayInterval>((event) {
      try {
        final Map<String, Timestamp> intervalMap =
            event.get('availableIntervals')[rite.enumSerialize()];
        return DayInterval(
            start: intervalMap['start'].toDate(),
            end: intervalMap['end'].toDate());
      } catch (e) {
        return DayInterval();
      }
    });
  }

  void dispose() {
    readingsStreamController.close();
    calendarIntervalStreamController.close();
  }
}

/// A unique identifier for a set of daily readings
class ReadingsDataIdentifier {
  final Day day;
  final Rite rite;

  /// Creates a unique identifier for a set of daily readings, defined by the
  /// date and rite of the readings
  ReadingsDataIdentifier({@required this.day, @required this.rite});

  /// Returns a serialized identifier in a standard format consistent with the
  /// remote repository
  String serialize() {
    return '${this.day.toLocal().year}-${this.day.toLocal().month.toString().padLeft(2, '0')}-${this.day.toLocal().day.toString().padLeft(2, '0')}-${this.rite.enumSerialize()}';
  }

  @override
  bool operator ==(other) {
    return (other is ReadingsDataIdentifier) &&
        other.serialize() == serialize();
  }

  @override
  int get hashCode => serialize().hashCode;
}

/// A snapshot object that contains the response to a request for daily readings
class ReadingsSnapshot {
  final ReadingsDataIdentifier requestedId;
  final ReadingsData data;
  final ReadingsSnapshotState state;

  ReadingsSnapshot.notDownloaded(this.requestedId)
      : data = null,
        state = ReadingsSnapshotState.waitingForDownload;

  ReadingsSnapshot.nonExistent(this.requestedId)
      : data = null,
        state = ReadingsSnapshotState.inexistent;

  /// Creates a structured set of readings from a suitably formatted Cloud Firestore map
  ReadingsSnapshot.fromFirebase(this.requestedId, Map<String, dynamic> document)
      : data = ReadingsParser.parse(document),
        state = ReadingsSnapshotState.downloaded;
}

/// A static class with methods to parse a Firestore document and its parse
/// into valid objects for the reader
class ReadingsParser {
  /// Returns a parsed [ReadingsData] object from its serialized representation
  static ReadingsData parse(Map<String, dynamic> document) {
    return ReadingsData(
      title: document["title"],
      rite: parseRite(document["rite"]),
      source: Uri.tryParse(document["source"]),
      date: DateTime.tryParse(document["date"]),
      sections: parseSections(document["sections"]),
    );
  }

  /// Returns a parsed rite from its serialized representation
  static Rite parseRite(String string) {
    Map riteMatchMap =
        Map.fromEntries(Rite.values.map((e) => MapEntry(e.enumSerialize(), e)));

    return riteMatchMap.containsKey(string) ? riteMatchMap[string] : null;
  }

  /// Returns a list of parsed [Section] objects from their Firestore
  /// representation
  static List<Section> parseSections(List data) {
    // Create a map that matches the string representation of the section type to a valid [RomanSectionType]
    Map sectionTypeMatch = Map.fromEntries(
      SectionType.values.map<MapEntry<String, SectionType>>(
        (value) => MapEntry(value.enumSerialize(), value),
      ),
    );

    if (data is List) {
      return data
          .map<Section>((element) {
            if (element is Map &&
                sectionTypeMatch.containsKey(element['name']) &&
                element['alternatives'] is List) {
              return Section(
                name: sectionTypeMatch[element['name']],
                alternatives: (element["alternatives"] as List)
                    .map(
                      (alternative) => parseSectionAlternative(alternative),
                    )
                    .where((e) => e != null)
                    .toList(),
              );
            } else {
              print('Section parsing failed for $data');
              return null;
            }
          })
          .where((e) => e != null)
          .toList();
    } else {
      print('Sections parsing failed for $data');
      return [];
    }
  }

  /// Returns a parsed [SectionAlternative] from their Firestore representation
  static SectionAlternative parseSectionAlternative(dynamic data) {
    // Create a map that matches the string representation of the section
    // type to a valid [RomanSectionType]
    Map blockTypeMatch = Map.fromEntries(
      BlockType.values.map<MapEntry<String, BlockType>>(
        (value) => MapEntry(value.enumSerialize(), value),
      ),
    );
    if (data is Map && data["blocks"] is List) {
      return SectionAlternative(
        label: data["label"],
        blocks: List.castFrom(data["blocks"])
            .map<Block>(
              (blockMap) {
                if (blockMap is Map &&
                    blockTypeMatch.containsKey(blockMap['type'])) {
                  return Block(
                    type: blockTypeMatch[blockMap['type']],
                    content: blockMap['content'].toString(),
                  );
                } else {
                  print('Block parsing failed for $blockMap');
                  return null;
                }
              },
            )
            .where((e) => e != null)
            .toList(),
      );
    } else {
      print('SectionAlternative parsing failed for $data');
      return null;
    }
  }
}

enum ReadingsSnapshotState {
  inexistent,
  badFormat,
  waitingForDownload,
  downloaded
}
