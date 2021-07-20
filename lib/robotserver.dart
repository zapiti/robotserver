library robotserver;
import 'dart:mirrors';
import 'package:xml_rpc/simple_server.dart' as xml_rpc_server;
import 'src/robot_codecs.dart';

class RobotServer {
  RemoteLibraryFactory? _libraryFactory;
  xml_rpc_server.SimpleXmlRpcServer? _server;
  RobotRemoteHandler? robotRemoteHandler;

  var port;
  var host;
  var library;

  RobotServer(this.library, {this.host = '127.0.0.1', this.port = 5001}) {
    _libraryFactory = RemoteLibraryFactory(library);
    robotRemoteHandler = RobotRemoteHandler(robotCodecs);
    _register_functions();
  }

  void _register_functions() {
    robotRemoteHandler?.add_methods(_libraryFactory!);
    _server = xml_rpc_server.SimpleXmlRpcServer(
        host: host, port: port, handler: robotRemoteHandler!);
  }

  void serve() {
    _server?.start();
  }
}

class RobotRemoteHandler extends xml_rpc_server.XmlRpcHandler {
  RobotRemoteHandler(robotCodecs) : super(methods: {}, codecs: robotCodecs);

  void add_methods(RemoteLibraryFactory libraryFactory) {
    methods['get_library_information'] = libraryFactory.getInformation;
    methods['run_keyword'] = libraryFactory.run_keyword;
  }
}

class RemoteLibraryFactory {
  Object library;
  Map? library_information;
  RemoteLibraryFactory(this.library);

  Map? getInformation() {
    const PythonTypeMap = {
      'String': 'str',
      'int': 'int',
      'DateTime': 'datetime'
    };
    var instance_mirror = reflect(library);
    var class_mirror = instance_mirror.type;
    // instance_mirror.invoke(memberName, positionalArguments)
     library_information = {
      '__intro__': {'doc': 'Library documentation'},
    } ;
    for (var v in class_mirror.declarations.values) {
      if (v is MethodMirror) {
        var props = {
          'args': [],
          'types': [],
          'doc': '',
        };
        var args = [];
        var types = [];
        var name = MirrorSystem.getName(v.simpleName);
        for (var p in v.parameters) {
          var name = MirrorSystem.getName(p.simpleName);
          var type = MirrorSystem.getName(p.type.simpleName);
          args.add(name);
          types.add(PythonTypeMap[type]);
        }
        props['args'] = args;
        props['types'] = types;
        if(library_information != null) {
          library_information![name] = props;
        }
      }
    }
    print('returned library info $library_information');
    return library_information;
  }

  Map run_keyword(name, List args) {
    print('invoking method $name with args $args');
    var resp = {'status': 'PASS', 'output': '', 'return': ''};
    var instance_mirror = reflect(library);
    var ret = instance_mirror.invoke(Symbol(name), args);
    print('run keyword returned $ret');
    resp['return'] = ret.reflectee.toString();
    return resp;
  }
}
