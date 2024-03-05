import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:kp/api/request_middleware.dart';
import 'package:kp/globals.dart';
import 'package:kp/models/country.dart';
import 'package:kp/models/heirachy_unit.dart';
import 'package:kp/models/lab.dart';
import 'package:kp/models/metadata.dart';

class MetadataApi {
  static Future<List<KpMetaData>> getGenericMetaData(String name) async {
    try {
      String url = endPointBaseUrl + genericMetaDataList[name]['end_point'];
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url, method: RequestMethod.GET);
      if (response.statusCode == 200) {
        List data = JsonDecoder().convert(response.body);
        return data.map((e) {
          return KpMetaData(
              id: e[genericMetaDataList[name]['id_name']],
              name: e['name'],
              code: e['code'],
              description: e['description']);
        }).toList();
      }
      throw ('Connection Error');
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<List<KpMetaData>> getMetaData(String path) async {
    try {
      String url = endPointBaseUrl + "/" + path;
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url, method: RequestMethod.GET);
      if (response.statusCode == 200) {
        List data = JsonDecoder().convert(response.body);
        return data.map((e) {
          String idName = "";
          e.keys.toList().forEach((key) {
            if (idName == "") {
              if (key.contains("_id")) {
                idName = key;
              }
            }
          });
          return KpMetaData(
              id: e[idName],
              name: e['name'],
              code: e['code'],
              description: e['description']);
        }).toList();
      }
      throw ('Connection Error');
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<List<LabTestType>> getLabTestTypes() async {
    try {
      String url = endPointBaseUrl + '/listlaboratorytesttype';
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url, method: RequestMethod.GET);
      if (response.statusCode == 200) {
        List data = JsonDecoder().convert(response.body);
        return data.map((e) {
          return LabTestType(
              labTestTypeId: e['laboratory_test_type_id'],
              name: e['name'],
              code: e['code'],
              description: e['description']);
        }).toList();
      }
      throw ('Connection Error');
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<List<LabTest>> getLabTests() async {
    try {
      String url = endPointBaseUrl + '/listlaboratorytests';
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url, method: RequestMethod.GET);
      if (response.statusCode == 200) {
        List data = JsonDecoder().convert(response.body);
        return data.map((e) {
          return LabTest(
              labTestTypeId: e['laboratory_test_type_id'],
              labTestId: e['laboratory_test_id'],
              name: e['name'],
              code: e['code'],
              description: e['description']);
        }).toList();
      }
      throw ('Connection Error');
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<List<Country>> getCountries() async {
    try {
      String url = endPointBaseUrl + '/listnationalities';
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url, method: RequestMethod.GET);
      if (response.statusCode == 200) {
        List data = JsonDecoder().convert(response.body);
        List<Country> countries = [];
        data.forEach((e) {
          countries.add(Country.fromJson(e));
        });
        return countries;
      }
      throw ('Connection Error');
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }

  static Future<Map<String, List<HierarchyUnit>>> getHierarchyUnits() async {
    try {
      String url = endPointBaseUrl + '/listheirarchyunitsbyparentid?parentid=1';
      http.Response response = await RequestMiddleWare.makeRequest(
          url: url, method: RequestMethod.GET);
      if (response.statusCode == 200) {
        List data = JsonDecoder().convert(response.body);
        print(data);
        List<HierarchyUnit> units = [];
        List<HierarchyUnit> unitsCopy = [];
        data.forEach((e) {
          HierarchyUnit unit = HierarchyUnit.fromJson(e);
          units.add(unit);
          unitsCopy.add(unit);
        });

        for (int x = 0; x < units.length; x++) {
          for (int y = 0; y < units.length; y++) {
            if (units[x].parnetId == units[y].id) {
              units[y].children.add(units[x]);
              units[x].movedIntoParent = true;
              break;
            } else {
              HierarchyUnit u = searchTree(units[y], units[x]);
              if (u != null) {
                u.children.add(units[x]);
                units[x].movedIntoParent = true;
                break;
              }
            }
          }
        }

        List<HierarchyUnit> sortedUnits = [];
        units.forEach((element) {
          if (element.movedIntoParent == false) {
            sortedUnits.add(element);
          }
        });
        // return sortedUnits;
        return {'tree': sortedUnits, 'array': unitsCopy};
      }
      throw ('Connection Error');
    } on SocketException catch (_) {
      throw ('Connection Error');
    }
  }
}

HierarchyUnit searchTree(
    HierarchyUnit hierarchy, HierarchyUnit matchingHierarchy) {
  if (hierarchy.id == matchingHierarchy.parnetId) {
    return hierarchy;
  } else {
    var i;
    HierarchyUnit result;
    for (i = 0; result == null && i < hierarchy.children.length; i++) {
      result = searchTree(hierarchy.children[i], matchingHierarchy);
    }
    return result;
  }
}
