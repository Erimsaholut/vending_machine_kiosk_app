
library buzlime_models;

class Cmd {
  final String type; // 'cmd' | 'read'
  final String name; // M1/M2/M3/M4/RELAY/TEMP/TOF
  final String? dir; // F/B
  final Map<String, dynamic>? data;
  final String? state; // ON/OFF
  final String id;
  Cmd({required this.type, required this.name, this.dir, this.data, this.state, required this.id});
  Map<String, dynamic> toJson() => {
    'v': 1, 'type': type, 'name': name, if (dir!=null) 'dir': dir, if (state!=null) 'state': state, if (data!=null) 'data': data, 'id': id
  };
}

class Resp {
  final bool ok;
  final Map<String, dynamic>? ack;
  final Map<String, dynamic>? resp;
  final Map<String, dynamic>? err;
  Resp({required this.ok, this.ack, this.resp, this.err});
  static Resp fromJson(Map<String, dynamic> j) {
    return Resp(ok: j['ok'] == true, ack: j['ack'] as Map<String, dynamic>?, resp: j['resp'] as Map<String, dynamic>?, err: j['err'] as Map<String, dynamic>?);
  }
}

class Telemetry {
  double? tempC;
  double? tofCm;
  String? lastError;
}

typedef Json = Map<String, dynamic>;
