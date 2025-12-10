import 'package:debug_host_env/debug_host_env.dart';
import 'package:example/app.dart';
import 'package:{{name}}/{{name}}.dart';

Future<void> main()async{
  initHttp(app);
  HouseRequest request = HouseRequest();
  HouseListPayload payload = HouseListPayload(
    page: 1,
    pageSize: 20,
    cityId: 7,
  );
  var ret = await request.query(payload);
  if(ret.success){
    print(ret.data.length);
  }
}
