import 'package:fractal/index.dart';
import 'package:fractal/index.dart';

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
