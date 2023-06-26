import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:html/dom.dart';
import 'package:yaml/yaml.dart';

import 'core/categories.dart';
import 'core/exports.dart';
import 'core/utils.dart';

Uri entrypoint = Uri.parse('https://www.curso-objetivo.br/vestibular/resolucao_comentada.aspx');

void main(List<String> args) async {
	bool fetch = false;
	bool disperse = false;
	num coverage = double.infinity;
	List<String> save = [];

	args.forEach((arg) {
		List<String> parts = arg.split('=');

		if (arg == '--fetch') fetch = true;
		if (arg == '--disperse') disperse = true;
		if (parts[0] == '--coverage') coverage = double.parse(parts[1]);
		if (parts[0] == '--save') save = parts[1].split(',');
	});

	late List<University> universities;
	late Output output;
	late File yamlFile;

	universities = [];
	
	if (fetch) {
		Document homeDOM = await fetchDOM(entrypoint);
		List<Element> homeAnchors = homeDOM.querySelectorAll('a');
		Iterable<Element> universityAnchors = homeAnchors.where((element) {
			String? title = element.attributes['title'];
			if (title != null) return title.startsWith('Resolução Comentada');
			else return false;
		});
		
		universityAnchors.forEach((element) {
			if (universities.length >= coverage) return;

			String name = element.text;
			String? href = element.attributes['href'];

			if (name != "" && href != null) {
				Uri origin = complementURL(entrypoint, href);
				final university = University(name, origin);
				universities.add(university);
			}
		});

		for (int u = 0; u < universities.length; u++) {
			Document universityDOM = await fetchDOM(universities[u].origin);
			List<Element> universityAnchors = universityDOM.querySelectorAll('a');
			Iterable<Element> examAnchors = universityAnchors.where((element) {
				String? title = element.attributes['title'];
				if (title != null) return title.contains('- Resolução Comentada -');
				else return false;
			});
																															
			examAnchors.forEach((element) {
				if (universities[u].exams.length >= coverage) return;
	
				String year = element.text;
				String? href = element.attributes['href'];
	
				if (year != "" && href != null) {
					Uri link = complementURL(universities[u].origin, href);
					final exam = Exam(year, link);
					universities[u].exams.add(exam);
				}
			});
	
			for (int e = 0; e < universities[u].exams.length; e++) {
				Document examDOM = await fetchDOM(universities[u].exams[e].link);
				List<Element> examAnchorsAndTitles = examDOM.querySelectorAll('a, h2');
				
				String actualArea = "";
				
				examAnchorsAndTitles.forEach((element) {
					if (element.localName == 'h2') actualArea = element.text;
					
					if (element.classes.contains('questao-gabarito')) {
						if (universities[u].exams[e].questions.length >= coverage) return;
	
						String? id = element.attributes['data-questao'];
						String? alternative = element.attributes['data-alternativa'];
						String? image = element.attributes['data-url'];
						
						if (actualArea != "" && id != null && alternative != null && image != null) {
							final question = Question(actualArea, id, alternative, image);
							universities[u].exams[e].questions.add(question);
						}
					}
	
					if (element.attributes['title'] == 'Resolução') {
						String? href = element.attributes['href'];
						
						if (href != null) {
							Uri resolution = complementURL(universities[u].exams[e].link, href);
							universities[u].exams[e].resolution = resolution;
						}
					}
				});
			}
		}
	}

	output = new Output('lib/rawdata', 'universities');

	if (save.isNotEmpty) {
		for (int u = 0; u < universities.length; u++) {
			final university = universities[u];
			
			var origin = stringifyURL(university.origin);
			
			output.writeLine('name', university.name, 1, startsList: true);
			output.writeLine('origin', origin, 1, addsList: true);
			output.writeLine('exams', null, 1, addsList: true);
	
			for (int e = 0; e < university.exams.length; e++) {
				final exam = university.exams[u];
				
				var link = stringifyURL(exam.link);
				var resolution = stringifyURL(exam.resolution);
				
				output.writeLine('year', exam.year, 3, startsList: true);
				output.writeLine('link', link, 3, addsList: true);
				output.writeLine('resolution', resolution, 3, addsList: true);
				output.writeLine('questions', null, 3, addsList: true);
	
				for (int q = 0; q < exam.questions.length; q++) {
					final question = exam.questions[q];
					var image = '"' + question.image.toString() + '"';
					
					output.writeLine('id', question.id, 5, startsList: true);
					output.writeLine('alternative', question.alternative, 5, addsList: true);
					output.writeLine('area', question.area, 5, addsList: true);
					output.writeLine('image', image, 5, addsList: true);
				}
			}
		}
	
		if (save.contains('yaml')) output.saveAsYAML();
		if (save.contains('json')) output.saveAsJSON();
	}

	yamlFile = File('${output.directory}/${output.filename}.yaml');

	if (disperse && yamlFile.existsSync()) {
		YamlMap yamlMap = loadYaml(yamlFile.readAsStringSync());
		Directory globalDirectory = Directory('lib/dispersed');
		
		if (!globalDirectory.existsSync()) globalDirectory.createSync(recursive: true);
		
		yamlMap['universities'].forEach((university) async {
			String universityPath = globalDirectory.path + '/' + university['name'];
			Directory universityDirectory = Directory(universityPath)..createSync(recursive: true);
			
			university['exams'].forEach((exam) async {
				String examPath = universityDirectory.path + '/' + exam['year'];
				Directory examDirectory = Directory(examPath)..createSync(recursive: true);

				if (exam['resolution'] == null) return;

				Uri pdfUri = Uri.parse(exam['resolution']);
				Response pdfResponse = await get(pdfUri);
				Uint8List pdfBytes = pdfResponse.bodyBytes;
			});
		});
	}
}