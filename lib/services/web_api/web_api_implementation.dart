import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moolax/business_logic/models/rate.dart';
import 'web_api.dart';

// 1
class WebApiImpl implements WebApi {
  final _host = 'api.exchangeratesapi.io';
  final _path = 'vi/latest';
  // final Map<String, String> _headers = {'Accept': 'application/json'};
  final Map<String, String> _queryParams = {
    'access_key': 'ccbed5b3d3ae155a9cc5e54cc30b71a8',
    'date': '2022-03-26',
  };

  // 2
  List<Rate>? _rateCache;

  @override
  Future<List<Rate>> fetchExchangeRates() async {
    if (_rateCache == null) {
      print('getting rates from the web');

      final uri = Uri.parse('http://api.exchangeratesapi.io/v1/latest?access_key=ccbed5b3d3ae155a9cc5e54cc30b71a8');
      // Uri.http(_host, _path, _queryParams);
      final results = await http.get(uri);
      print(results.body);
      final jsonObject = json.decode(results.body);
      _rateCache = _createRateListFromRawMap(jsonObject);
    } else {
      print('getting rates from cache');
    }
    return _rateCache!;
  }

  List<Rate> _createRateListFromRawMap(Map jsonObject) {
    final Map rates = jsonObject['rates'];
    final String base = jsonObject['base'];
    List<Rate> list = [];
    list.add(Rate(baseCurrency: base, quoteCurrency: base, exchangeRate: 1.0));
    for (var rate in rates.entries) {
      if (base != rate.key) {
        list.add(Rate(
            baseCurrency: base,
            quoteCurrency: rate.key,
            exchangeRate: rate.value as double));
      }
    }
    return list;
  }
}
