library utils;

import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:html/dom.dart';

Future<Document> fetchDOM(Uri url) async {
	String html = (await http.get(url)).body;
	return parse(html);
}

Uri complementURL(Uri directory, String path) {
	List<String> parts = directory.toString().split('/')..removeLast();
	return Uri.parse(parts.join('/') + '/' + path);
}

String? stringifyURL(Uri? url) {
	if (url != null) return '"' + url.toString() + '"';
	else return null;
}