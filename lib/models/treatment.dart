import 'package:signed_fractal/signed_fractal.dart';
import 'procedure.dart';

class TreatmentCtrl<T extends Treatment> extends EventsCtrl<T> {
  TreatmentCtrl({
    super.name = 'treatment',
    required super.make,
    required super.extend,
    required super.attributes,
  });
}

class Treatment extends EventFractal with Rewritable {
  static final controller = TreatmentCtrl(
    extend: EventFractal.controller,
    make: (d) => switch (d) {
      MP() => Treatment.fromMap(d),
      _ => throw ('wrong rewriter given')
    },
    attributes: <Attr>[
      Attr(name: 'tooth', format: 'INTEGER', canNull: true),
      Attr(name: 'time', format: 'INTEGER'),
      Attr(name: 'surface', format: 'TEXT', canNull: true),
      Attr(name: 'status', format: 'INTEGER'),
      Attr(
        name: 'price',
        format: 'DOUBLE',
      ),
      Attr(
        name: 'user_id',
        format: 'TEXT',
      ),
      Attr(name: 'procedure', format: 'INTEGER'),
    ],
  );

  @override
  TreatmentCtrl get ctrl => controller;

  String? surface;
  DateTime? completed;
  Procedure procedure;
  int? tooth;
  int? time;
  bool future;
  double price;
  String user_id;
  bool checked = false;

  static final all = TypeFilter<Treatment>(
    EventFractal.map,
  );

  Treatment({
    this.surface,
    required this.procedure,
    this.future = false,
    this.price = 0,
    this.tooth,
    required this.user_id,
    super.to,
    this.time,
  }) {
    time ??= DateTime.now().millisecondsSinceEpoch;
    //if(procedure == null)
  }

  Treatment.fromMap(MP m)
      : tooth = m['tooth'],
        time = m['time'],
        surface = m['surface'],
        future = m['status'] == 1,
        price = (m['price'] ?? 0) + 0.0,
        user_id = m['user_id'] ?? '',
        procedure = Procedure.get(
          m['procedure'],
        ),
        super.fromMap(m);

  @override
  MP toMap() => {
        ...super.toMap(),
        'tooth': tooth,
        'time': time,
        'surface': surface,
        'status': future ? 1 : 2,
        'price': price,
        'user_id': user_id,
        'procedure': procedure.id,
      };

  final description = Writable();

  @override
  onWrite(f) async {
    final ok = await super.onWrite(f);
    if (ok) {
      switch (f.attr) {
        case 'description':
          description.value = f;
      }
    }
    return ok;
  }
}
