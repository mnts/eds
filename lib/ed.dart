import 'package:fractal/lib.dart';
import 'package:signed_fractal/signed_fractal.dart';

import 'models/appointment.dart';
import 'models/treatment.dart';

class Ed {
  static final ctrls = <FractalCtrl>[
    MeetingFractal.controller,
    Treatment.controller,
  ];

  static Future<int> init() async {
    for (final el in ctrls) {
      await el.init();
    }

    MeetingFractal.init();

    return 1;
  }
}
