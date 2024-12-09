import 'package:app_fractal/index.dart';
import 'package:color/color.dart';

class MeetingCtrl<T extends MeetingFractal> extends PostCtrl<T> {
  MeetingCtrl({
    super.name = 'meeting',
    required super.make,
    required super.extend,
    required super.attributes,
  });

  final icon = IconF(0xe23e);
}

class MeetingFractal extends PostFractal with Rewritable {
  static final controller = MeetingCtrl(
    extend: PostFractal.controller,
    make: (d) async {
      final rq = NetworkFractal.request;
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
        format: 'TEXT',
        isIndex: true,
      ),
      Attr(
        name: 'dentist',
        format: 'TEXT',
        isIndex: true,
      ),
      Attr(
        name: 'since',
        format: 'INTEGER',
      ),
      Attr(
        name: 'minutes',
        format: 'INTEGER',
      ),
    ],
  );

  @override
  MeetingCtrl get ctrl => controller;

  String? notes;

  static final map = MapF<MeetingFractal>();

  static var _ready = false;
  static init() {
    if (_ready) return;
    EventFractal.map.listen((f) {
      if (f is MeetingFractal) map.complete(f.hash, f);
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
      NetworkFractal.request(statusHash).then((f) {
        if (f case NodeFractal node) {
          node.m.request('color').then((post) {
            c = int.parse(post.content);
            notifyListeners();
          });
        }
      });
    }
  }

  @override
  operator [](String key) => switch (key) {
        'since' => since.millisecondsSinceEpoch ~/ 1000,
        'minutes' => minutes,
        'patient' => patient.hash,
        'dentist' => dentist.hash,
        _ => super[key] ?? m[key]?.content,
      };

  @override
  onWrite(f) async {
    final ok = await super.onWrite(f);
    if (ok) {
      switch (f.attr) {
        case 'status':
          loadColor();
        case 'minutes':
          final val = int.tryParse(f.content);
          if (val != null && minutes != val) {
            controller.update({
              'minutes': val,
            }, id);
            minutes = val;
            notifyListeners();
          }
        case 'since':
          final val = int.tryParse(f.content);
          if (val != null && (since.millisecondsSinceEpoch ~/ 1000) != val) {
            controller.update({
              'since': val,
            }, id);
            since = DateTime.fromMillisecondsSinceEpoch(
              val * 1000,
            );
            notifyListeners();
          }
      }
    }
    return ok;
  }
}
