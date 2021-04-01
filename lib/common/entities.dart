import 'package:flutter/foundation.dart';

class ReadingsData {
  final String title;
  final Rite rite;
  final String source;
  final Uri sourceURL;
  final DateTime date;
  final List<Section> sections;

  /// Creates a set of readings given its structured contents
  ReadingsData({
    @required this.sections,
    @required this.title,
    @required this.rite,
    @required this.source,
    @required this.sourceURL,
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
  final String label;

  SectionAlternative({@required this.blocks, this.label});
}

class Block {
  final BlockType type;
  final String content;

  Block({@required this.type, @required this.content});
}

enum BlockType {
  Heading, // Heading of a section (sometimes there may be multiple headings)
  Subheading,
  Source, // A block that introduces a text stating the source
  Reference, // Reference to scriptures
  Passage, // A passage from scriptures
  Poetry, // Poetry text
  Text, // Generic text
  Emphasis, // A generic emphasised text
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
