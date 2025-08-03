import 'package:fractal/index.dart';
import 'package:color/color.dart';

class MeetingCtrl<T extends MeetingFractal> extends EventsCtrl<T> {
  MeetingCtrl({
    super.name = 'meeting',
    required super.make,
    required super.extend,
    required super.attributes,
  });

  //final icon = IconF(0xe23e);
}

class MeetingFractal<T extends EventFractal> extends EventFractal
    with FlowF<T>, MF<String, T>, MFE<T>, Rewritable {
  static final controller = MeetingCtrl(
    extend: EventFractal.controller,
    make: (d) async {
      final rq = NetworkFractal.discover;
      final patient = await rq(d['patient']) as UserFractal;
      final dentist = await rq(d['dentist']) as UserFractal;
      return switch (d) {
        MP() => MeetingFractal.fromMap(
            d,
            patient: patient,
            dentist: dentist,
          ),
        _ => throw (),
      };
    },
    attributes: [
      Attr(
        name: 'patient',
        format: FormatF.text,
        isIndex: true,
      ),
      Attr(
        name: 'dentist',
        format: FormatF.text,
        isIndex: true,
      ),
      Attr(
        name: 'since',
        format: FormatF.integer,
      ),
      Attr(
        name: 'minutes',
        format: FormatF.integer,
      ),
    ],
  );

  @override
  MeetingCtrl get ctrl => controller;

  String? notes;

  static final storage = MapF<MeetingFractal>();

  static var _ready = false;
  static init() {
    if (_ready) return;
    EventFractal.storage.listen((f) {
      if (f is MeetingFractal) storage.associate(f.hash, f);
    });
    _ready = true;
  }

  int minutes;
  DateTime since;
  //DateTime until;
  UserFractal patient;
  UserFractal dentist;
  //Color? background;
  bool isAllDay = false;

  MeetingFractal({
    required this.since,
    //required this.until,
    required this.minutes,
    super.to,
    //required this.status,
    required this.patient,
    required this.dentist,
    required super.content,
  }) {
    _construct();
  }

  MeetingFractal.fromMap(
    MP d, {
    required this.patient,
    required this.dentist,
  })  : since = DateTime.fromMillisecondsSinceEpoch(
          d['since'] * 1000,
        ),
        minutes = d['minutes'],
        super.fromMap(d) {
    _construct();
  }

  _construct() {
    //map.complete(hash, this);
    //init();
  }

  @override
  MP toMap() => {
        ...super.toMap(),
        for (var a in controller.attributes) a.name: this[a.name],
      };

  //static const String type = 'appointment';

  late DateTime until = since.add(
    Duration(
      minutes: minutes,
    ),
  );

  int c = 0;
  loadColor() {
    if (this['status'] case String statusHash) {
      NetworkFractal.discover(statusHash).then((f) {
        if (f case NodeFractal node) {
          node.request('color').then((post) {
            c = int.parse(post.content);
            notifyListeners();
          });
        }
      });
    }
  }

  @override
  operator [](key) => switch (key) {
        'since' => since.millisecondsSinceEpoch ~/ 1000,
        'minutes' => minutes,
        'patient' => patient,
        'dentist' => dentist,
        _ => super[key] ?? sub[key]?.content,
      };

  @override
  consume(f) async {
    switch (f.name) {
      case 'status':
        loadColor();
      case 'minutes':
        final val = int.tryParse(f.content);
        if (val != null && minutes != val) {
          controller.updateDB({
            'minutes': val,
          }, id);
          minutes = val;
          notifyListeners();
        }
      case 'since':
        final val = int.tryParse(f.content);
        if (val != null && (since.millisecondsSinceEpoch ~/ 1000) != val) {
          controller.updateDB({
            'since': val,
          }, id);
          since = DateTime.fromMillisecondsSinceEpoch(
            val * 1000,
          );
          notifyListeners();
        }
    }
    super.consume(f);
  }
}
