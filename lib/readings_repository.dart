import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'utils.dart';

class ReadingsRepository {
  final ReadingsDataIdentifier id;

  /// Creates an object that handles data sourcing from Firebase Cloud Firestore, for the given [ReadingsDataIdentifier]
  ReadingsRepository(this.id) : readingsStream = getReadingsStream(id);

  /// A stream of [ReadingsData] objects
  final Stream<ReadingsSnapshot> readingsStream;

  /// Creates a broadcast [Stream] of [ReadingsData] objects from the remote repository for the given [day]
  static Stream<ReadingsSnapshot> getReadingsStream(ReadingsDataIdentifier id) {
    return FirebaseFirestore.instance
        .collection('readings')
        .doc(id.serialize())
        .snapshots()
        .map<ReadingsSnapshot>((snapshot) {
      if (snapshot.exists) {
        return ReadingsSnapshot.fromFirebase(snapshot.data());
      } else {
        return ReadingsSnapshot.nonExistent();
      }
    }).asBroadcastStream();
  }
}

class ReadingsDataIdentifier {
  final Day day;
  final Rite rite;

  /// Creates a unique identifier for a set of daily readings, that can be se
  ReadingsDataIdentifier({@required this.day, @required this.rite});

  /// Returns a serialized identifier in a standard format consistent with the remote repository
  String serialize() {
    return '${this.day.toLocal().year}-${this.day.toLocal().month}-${this.day.toLocal().day}-${this.rite.enumSerialize()}';
  }

  @override
  bool operator ==(other) {
    return (other is ReadingsDataIdentifier) &&
        other.serialize() == serialize();
  }

  @override
  int get hashCode => serialize().hashCode;
}

class ReadingsSnapshot {
  final ReadingsData data;
  final bool exists;
  final bool badFormat;

  ReadingsSnapshot.nonExistent()
      : data = null,
        exists = false,
        badFormat = false;

  /// Creates a structured set of readings from a suitably formatted Cloud Firestore map
  ReadingsSnapshot.fromFirebase(Map<String, dynamic> document)
      : data = ReadingsData(
          title: document["title"],
          rite: parseRite(document["rite"]),
          source: Uri.tryParse(document["source"]),
          date: DateTime.tryParse(document["date"]),
          sections: parseSections(document["sections"]),
        ),
        exists = true,
        badFormat = false;

  /// Returns a parsed rite from its serialized representation
  static Rite parseRite(String string) {
    Map riteMatchMap =
        Map.fromEntries(Rite.values.map((e) => MapEntry(e.enumSerialize(), e)));

    return riteMatchMap.containsKey(string) ? riteMatchMap[string] : null;
  }

  /// Returns a list of parsed sections from
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

  static SectionAlternative parseSectionAlternative(dynamic data) {
    // Create a map that matches the string representation of the section type to a valid [RomanSectionType]
    Map blockTypeMatch = Map.fromEntries(
      BlockType.values.map<MapEntry<String, BlockType>>(
        (value) => MapEntry(value.enumSerialize(), value),
      ),
    );
    if (data is Map && data["blocks"] is List) {
      return SectionAlternative(
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

class ReadingsData {
  final String title;
  final Rite rite;
  final Uri source;
  final DateTime date;
  final List<Section> sections;

  /// Creates a set of readings given its structured contents
  ReadingsData({
    @required this.sections,
    @required this.title,
    @required this.rite,
    @required this.source,
    @required this.date,
  });
}

class Section {
  final SectionType name;
  final List<SectionAlternative> alternatives;

  Section({@required this.name, @required this.alternatives});
}

class SectionAlternative {
  final List<Block> blocks;

  SectionAlternative({@required this.blocks});
}

class Block {
  final BlockType type;
  final String content;

  Block({@required this.type, @required this.content});
}

enum BlockType {
  Heading, // Heading of a section (sometimes there may be multiple headings)
  Subheading,
  Emphasis,
  Reference, // Reference to scriptures
  Text, // Normal text
  Verse, // A verse in a poetry-stile text
  Space // Just an empty line
}

enum SectionType {
  rAntiphonaAdIntroitum,
  rIncensatioAltaris,
  rSalutatio,
  rAspersio,
  rActusPaenitentialis,
  rKyrieGloria,
  rCollecta,
  rLectioPrima,
  rPsalmus,
  rLectioSecunda,
  rAlleluia,
  rEvangelium,
  rHomilia,
  rCredo,
  rOratioFidelium,
  rAntiphonaAdOffertorium,
  rIncensatio,
  rLavabo,
  rOratioSuperOblata,
  rPraefatio,
  rSactus,
  rCanonRomanus,
  rPaterNoster,
  rAgnusDei,
  rAntiphonaAdCommunionem,
  rAmmunioFidelium,
  rPostcommunio,
  rBenedictioEtDimissio,
  rGratiaActioPostMissam,
  aAntiphonaAdIntroitum,
  aIncensatioAltaris,
  aSalutatio,
  aAspersio,
  aActusPaenitentialis,
  aKyrieGloria,
  aOratio,
  aLectio,
  aPsalmus,
  aEpistula,
  aAlleluia,
  aEvangelium,
  aPostEvangelium,
  aHomilia,
  aCredo,
  aOratioFidelium,
  aAntiphonaAdOffertorium,
  aIncensatio,
  aLavabo,
  aOratioSuperOblata,
  aPraefatio,
  aSactus,
  aCanonRomanus,
  aPaterNoster,
  aAgnusDei,
  aAntiphonaAdCommunionem,
  aAmmunioFidelium,
  aPostcommunio,
  aBenedictioEtDimissio,
  aGratiaActioPostMissam,
}

enum Rite { ambrosian, roman }
