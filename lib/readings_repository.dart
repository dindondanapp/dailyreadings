import 'package:cloud_firestore/cloud_firestore.dart';

import 'utils.dart';

class ReadingsRepository {
  final ReadingsDataIdentifier id;

  /// Creates an object that handles data sourcing from Firebase Cloud Firestore, for the given [ReadingsDataIdentifier]
  ReadingsRepository(this.id) : readingsStream = getReadingsStream(id);

  /// A stream of [ReadingsData] objects
  final Stream<ReadingsData> readingsStream;

  /// Creates a broadcast [Stream] of [ReadingsData] objects from the remote repository for the given [day]
  static Stream<ReadingsData> getReadingsStream(ReadingsDataIdentifier id) {
    print(id);
    return Firestore.instance
        .collection('readings')
        .document(id.serialize())
        .snapshots()
        .map<ReadingsData>(
          (snapshot) => ReadingsData.fromFirebase(snapshot.data),
        )
        .asBroadcastStream();
  }
}

class ReadingsDataIdentifier {
  final Day day;
  final Rite rite;

  /// Creates a unique identifier for a set of daily readings, that can be se
  ReadingsDataIdentifier({required this.day, required this.rite});

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

class ReadingsData {
  final String title;
  final Rite rite;
  final Uri source;
  final DateTime date;
  final List<Section> sections;

  /// Creates a set of readings given its structured contents
  ReadingsData({
    required this.sections,
    required this.title,
    required this.rite,
    required this.source,
    required this.date,
  });

  /// Creates a structured set of readings from a suitably formatted Cloud Firestore map
  ReadingsData.fromFirebase(Map<String, dynamic> document)
      : title = document["title"],
        rite = parseRite(document["rite"])!,
        source = Uri.tryParse(document["source"])!,
        date = DateTime.tryParse(document["date"])!,
        sections = parseSections(document["sections"]);

  /// Returns a parsed rite from its serialized representation
  static Rite? parseRite(String string) {
    Map riteMatchMap =
        Map.fromEntries(Rite.values.map((e) => MapEntry(e.enumSerialize(), e)));

    return riteMatchMap.containsKey(string) ? riteMatchMap[string] : null;
  }

  /// Returns a list of parsed sections from
  static List<Section> parseSections(List data) {
    print('Parsing sections…');
    // Create a map that matches the string representation of the section type to a valid [RomanSectionType]
    Map sectionTypeMatch = Map.fromEntries(
      RomanSectionType.values.map<MapEntry<String, RomanSectionType>>(
        (value) => MapEntry(value.enumSerialize(), value),
      ),
    );

    if (data is List) {
      return data
          .map<Section?>((element) {
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
                    .map((e) => e!)
                    .toList(),
              );
            } else {
              print('Section parsing failed for $data');
              return null;
            }
          })
          .where((e) => e != null)
          .map((e) => e!)
          .toList();
    } else {
      print('Sections parsing failed for $data');
      return [];
    }
  }

  static SectionAlternative? parseSectionAlternative(dynamic data) {
    // Create a map that matches the string representation of the section type to a valid [RomanSectionType]
    Map blockTypeMatch = Map.fromEntries(
      BlockType.values.map<MapEntry<String, BlockType>>(
        (value) => MapEntry(value.enumSerialize(), value),
      ),
    );
    if (data is Map && data["blocks"] is List) {
      return SectionAlternative(
        blocks: List.castFrom(data["blocks"])
            .map<Block?>(
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
            .map((e) => e!)
            .toList(),
      );
    } else {
      print('SectionAlternative parsing failed for $data');
      return null;
    }
  }
}

class Section {
  final RomanSectionType name;
  final List<SectionAlternative> alternatives;

  Section({required this.name, required this.alternatives});
}

class SectionAlternative {
  final List<Block> blocks;

  SectionAlternative({required this.blocks});
}

class Block {
  final BlockType type;
  final String content;

  Block({required this.type, required this.content});
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

enum RomanSectionType {
  AntiphonaAdIntroitum,
  IncensatioAltaris,
  Salutatio,
  Aspersio,
  ActusPaenitentialis,
  KyrieGloria,
  Collecta,
  LectioPrima,
  Psalmus,
  LectioSecunda,
  Alleluia,
  Evangelium,
  Homilia,
  Credo,
  OratioFidelium,
  AntiphonaAdOffertorium,
  Incensatio,
  Lavabo,
  OratioSuperOblata,
  Praefatio,
  Sactus,
  CanonRomanus,
  PaterNoster,
  AgnusDei,
  AntiphonaAdCommunionem,
  AmmunioFidelium,
  Postcommunio,
  BenedictioEtDimissio,
  GratiaActioPostMissam
}

enum Rite { ambrosian, roman }
