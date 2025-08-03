import 'package:fractal/index.dart';
import 'procedure.dart';

class TreatmentCtrl<T extends Treatment> extends EventsCtrl<T> {
  TreatmentCtrl({
    super.name = 'treatment',
    required super.make,
    required super.extend,
    required super.attributes,
  });
}

class Treatment<T extends EventFractal> extends EventFractal
    with FlowF<T>, MF<String, T>, MFE<T>, Rewritable {
  static final controller = TreatmentCtrl(
    extend: EventFractal.controller,
    make: (d) => switch (d) {
      MP() => Treatment.fromMap(d),
      _ => throw ('wrong rewriter given')
    },
    attributes: <Attr>[
      Attr(name: 'tooth', format: FormatF.integer, canNull: true),
      Attr(name: 'time', format: FormatF.integer),
      Attr(name: 'surface', format: FormatF.text, canNull: true),
      Attr(name: 'status', format: FormatF.integer),
      Attr(
        name: 'price',
        format: FormatF.real,
      ),
      Attr(
        name: 'user_id',
        format: FormatF.text,
      ),
      Attr(
        name: 'procedure',
        format: FormatF.integer,
      ),
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

  /*
  static final all = TypeFilter<Treatment>(
    EventFractal.map,
  );
  */

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
  consume(f) async {
    switch (f.name) {
      case 'description':
        description.value = f;
    }
    super.consume(f);
  }
}
