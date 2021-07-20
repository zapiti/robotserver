import 'package:xml/xml.dart';
import 'package:xml_rpc/src/converter.dart';

final robotCodecs = List<Codec>.unmodifiable(<Codec>[
  doubleCodec,
  intCodec,
  boolCodec,
  stringCodec,
  dateTimeCodec,
  base64Codec,
  structCodec,
  arrayCodec,
  mapCodec,
]);

typedef XmlCodecDecodeSignature = Object Function(XmlNode);
typedef XmlCodecEncodeSignature = XmlNode Function(Object);

final mapCodec = _InternalCodec();

class _InternalCodec implements Codec<Map<String, dynamic>> {
  @override
  XmlNode encode(value,encode) {
    // if (value is Map<dynamic, dynamic>) throw ArgumentError();

    final members = <XmlNode>[];
    (value as Map).forEach((k, v) {
      members.add(XmlElement(XmlName('member'), [], [
        XmlElement(XmlName('name'), [], [XmlText(k)]),
        XmlElement(XmlName('value'), [], [encode!(v)])
      ]));
    });
    return XmlElement(XmlName('struct'), [], members);
  }

  @override
  Map<String, dynamic> decode( node,  decode) {
    if ((node is XmlElement && node.name.local == 'struct')) {
      throw ArgumentError();
    }

    final struct = <String, dynamic>{};
    for (final member in node!.findElements('member')) {
      final name = member.findElements('name').first.text;
      final valueElt = member.findElements('value').first;
      final elt = getValueContent(valueElt);
      struct[name] = decode!(elt);
    }
    return struct;
  }
}