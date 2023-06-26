library exports;

import 'dart:io';
import 'dart:convert';

import 'package:yaml/yaml.dart';

class Output {
	static const int identationSpaces = 2;
	String directory;
	String filename;
	
	Output(this.directory, this.filename);

	late String lines = '${this.filename}:';

	File? yamlFile;
	File? jsonFile;

	void writeLine(String key, String? value, int identation, {
		bool startsList = false,
		bool addsList = false
	}) {
		this.lines += (
			'\n'
			+ ' ' * identation * Output.identationSpaces
			+ (startsList ? '- ' : '')
			+ (addsList ? ' ' * 2 : '')
			+ '$key:' + (value != null ? ' $value' : '')
		);
	}

	void saveAsYAML() {
		Directory directory = Directory(this.directory);
		if (!directory.existsSync()) directory.createSync(recursive: true);
		
		File yamlFile = File('${this.directory}/${this.filename}.yaml');
		yamlFile.writeAsStringSync(this.lines);
		
		this.yamlFile = yamlFile;
	}

	void saveAsJSON() {
		YamlMap yamlMap = loadYaml(this.lines);
		String jsonString = jsonEncode(yamlMap);
		
		Directory directory = Directory(this.directory);
		if (!directory.existsSync()) directory.createSync(recursive: true);
		
		File jsonFile = File('${this.directory}/${this.filename}.json');
		jsonFile.writeAsStringSync(jsonString);
		
		this.jsonFile = jsonFile;
	}
}