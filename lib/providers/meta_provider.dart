import 'package:flutter/material.dart';
import 'package:kp/api/metadata_api.dart';
import 'package:kp/db/metadata.dart';
import 'package:kp/globals.dart';
import 'package:kp/models/country.dart';
import 'package:kp/models/heirachy_unit.dart';
import 'package:kp/models/lab.dart';
import 'package:kp/models/metadata.dart';

class MetadataProvider extends ChangeNotifier {
  Map<String, List<KpMetaData>> genericMetaData = {};
  Map<String, bool> metadataCacheTracker = {};
  List<LabTestType> testTypes;
  List<LabTest> tests;
  List<HierarchyUnit> hierarchyUnits;
  List<HierarchyUnit> hierarchyUnitsArray;
  List<Country> countries;

  MetadataProvider() {
    genericMetaDataList.forEach((key, value) {
      setGenericMetaData(key).then((val) async {
        while (
            genericMetaData[key] == null || metadataCacheTracker[key] == null) {
          await Future.delayed(Duration(milliseconds: 300));
          await setGenericMetaData(key);
        }
      });
    });

    setCountries().then((value) async {
      while (countries == null || metadataCacheTracker['countries'] == null) {
        await Future.delayed(Duration(milliseconds: 300));
        await setCountries();
      }
    });

    setHierarchyUnits().then((value) async {
      while (hierarchyUnits == null ||
          hierarchyUnitsArray == null ||
          metadataCacheTracker['hierarchy'] == null) {
        await Future.delayed(Duration(milliseconds: 300));
        await setHierarchyUnits();
      }
    });

    setLabTestTypes().then((value) async {
      while (
          testTypes == null || metadataCacheTracker['labTestTypes'] == null) {
        await Future.delayed(Duration(milliseconds: 300));
        await setLabTestTypes();
      }
    });

    setLabTests().then((value) async {
      while (tests == null || metadataCacheTracker['labTests'] == null) {
        await Future.delayed(Duration(milliseconds: 300));
        await setLabTests();
      }
    });
  }

  bool allMetadataAvailable() {
    int genericMetaCount = genericMetaData.length;
    if (hierarchyUnits != null &&
        hierarchyUnitsArray != null &&
        testTypes != null &&
        countries != null &&
        tests != null &&
        genericMetaCount == genericMetaDataList.length) {
      return true;
    }
    return false;
  }

  List<HierarchyUnit> getUnitsByParentId(int parentId) {
    List<HierarchyUnit> units = [];
    hierarchyUnitsArray.forEach((element) {
      if (element.hierarchyId == parentId) {
        units.add(element);
      }
    });
    return units;
  }

  List<dynamic> getMetaFromString(String val) {
    String value = val.toLowerCase().split('/').last.replaceFirst("list", "");
    if (genericMetaData.containsKey(value)) {
      return genericMetaData[value];
    } else if (val.toLowerCase().contains('countries')) {
      return countries;
    } else if (val.toLowerCase().contains('listlaboratorytesttype')) {
      return testTypes;
    } else if (val.toLowerCase().contains('listlaboratorytests')) {
      return tests;
    } else if (val.toLowerCase().contains('listheirarchyunitsbyparentid')) {
      List<String> queries = value.split('?').last.split('&');
      int id;
      for (int x = 0; x < queries.length; x++) {
        if (queries[x].contains('parentid')) {
          id = int.parse(queries[x].split('=').last);
        }
      }

      if (id == null) {
        return null;
      }

      if (hierarchyUnitsArray == null) {
        return null;
      }

      List<HierarchyUnit> units = [];
      hierarchyUnitsArray.forEach((element) {
        if (element.hierarchyId == id) {
          units.add(element);
        }
      });
      return units;
    } else {
      return null;
    }
  }

  Future<void> setGenericMetaData(String name) async {
    try {
      if (genericMetaData[name] == null) {
        var temp = await MetaDB.getInstance().getMetadata(name);
        if (temp.length > 0) {
          genericMetaData.putIfAbsent(name, () => temp);
          notifyListeners();
        }
      }

      List<KpMetaData> metaTemp = await MetadataApi.getGenericMetaData(name);
      genericMetaData.putIfAbsent(name, () => metaTemp);
      metadataCacheTracker.putIfAbsent(name, () => true);
      await MetaDB.getInstance().addMetadata(name, metaTemp);
      print('$name fetch success');
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setLabTestTypes() async {
    try {
      if (testTypes == null) {
        var temp = await MetaDB.getInstance().getLabTestTypes('labTestTypes');
        if (temp.length > 0) {
          testTypes = temp;
          notifyListeners();
        }
      }
      testTypes = await MetadataApi.getLabTestTypes();
      metadataCacheTracker.putIfAbsent('labTestTypes', () => true);
      await MetaDB.getInstance().addLabTestTypes('labTestTypes', testTypes);
      print('labTestTypes fetch success');
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setLabTests() async {
    try {
      if (tests == null) {
        var temp = await MetaDB.getInstance().getLabTests('labTests');
        if (temp.length > 0) {
          tests = temp;
          notifyListeners();
        }
      }

      tests = await MetadataApi.getLabTests();
      metadataCacheTracker.putIfAbsent('labTests', () => true);
      await MetaDB.getInstance().addLabTests('labTests', tests);
      print('labTests fetch success');
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setCountries() async {
    try {
      if (countries == null) {
        var temp = await MetaDB.getInstance().getCountries('countries');
        if (temp.length > 0) {
          countries = temp;
          notifyListeners();
        }
      }

      countries = await MetadataApi.getCountries();
      metadataCacheTracker.putIfAbsent('countries', () => true);
      await MetaDB.getInstance().addCountries('countries', countries);
      print('countries fetch success');
      notifyListeners();
    } catch (err) {}
  }

  Future<void> setHierarchyUnits() async {
    try {
      if (hierarchyUnits == null || hierarchyUnitsArray == null) {
        var temp = await MetaDB.getInstance().getHierarchyUnits('hierarchy');
        var temp2 =
            await MetaDB.getInstance().getHierarchyUnits('hierarchyArray');
        if (temp.length > 0) {
          hierarchyUnits = temp;
          hierarchyUnitsArray = temp2;
          notifyListeners();
        }
      }

      Map<String, List<HierarchyUnit>> result =
          await MetadataApi.getHierarchyUnits();
      hierarchyUnits = [];
      hierarchyUnitsArray = [];
      result['tree'].forEach((val) {
        hierarchyUnits.add(val);
      });
      result['array'].forEach((val) {
        hierarchyUnitsArray.add(val);
      });
      metadataCacheTracker.putIfAbsent('hierarchy', () => true);
      await MetaDB.getInstance().addHierarchyUnits('hierarchy', hierarchyUnits);
      await MetaDB.getInstance()
          .addHierarchyUnits('hierarchyArray', hierarchyUnitsArray);
      print('hierarchy fetch success');
      notifyListeners();
    } catch (err) {}
  }
}
