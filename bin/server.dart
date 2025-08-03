import 'dart:io';
import 'package:fractal/index.dart';
import 'package:ed/ed.dart';
import 'package:fractals2d/lib.dart';
import 'package:currency_fractal/fractals/transaction.dart';
import 'package:fractal_socket/client.dart';

void main(List<String> args) async {
  FileF.path = './';
  await DBF.initiate();
  await SignedFractal.init();
  await AppFractal.init();
  await Fractals2d.init();
  await Ed.init();

  await TransactionFractal.controller.init();

  NetworkFractal.active = NetworkFractal(
    name: 'edental',
  );

  final dir = Directory.current.path;
  print(dir);
  final map = EventFractal.map.map;

  if (args.length > 1) {
    final net = args[1];

    NetworkFractal.active = NetworkFractal.fromMap({
      'name': net,
      'createdAt': 2,
      'pubkey': '',
    })
      ..synch()
      ..preload();

    NetworkFractal.out = ClientFractal(
      from: DeviceFractal.my,
      to: NetworkFractal.active!,
    )..establish();
  } else {
    map['network'] =
        NetworkFractal.active = await NetworkFractal.controller.put({
      'name': FileF.host,
      'createdAt': 2,
      'pubkey': '',
    });
  }

  FServer(
    port: args.isNotEmpty ? int.parse(args[0]) : 8811,
    buildSocket: (device) => ClientFractal(
      from: device,
      to: NetworkFractal.active!,
    ),
  );
}
