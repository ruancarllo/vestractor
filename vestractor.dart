import 'dart:io';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

void main() async {
  final vestractor = Vestractor('https://www.curso-objetivo.br/vestibular/resolucao_comentada.aspx');

  await vestractor.getUniversities();
  await vestractor.saveData();
}

class Vestractor {
  final String entrypoiint;
  final List<University> universities = [];

  Vestractor(this.entrypoiint);

  getUniversities() async {
    final entrypointResponse = await http.get(Uri.parse(this.entrypoiint));

    if (entrypointResponse.statusCode == 200) {
      final entrypointDocument = parser.parse(entrypointResponse.body);
      final universityAnchors = entrypointDocument.querySelectorAll('a');

      stdout.write('\x1b[33mAdd all universities\x1b[0m [\x1b[32my\x1b[0m/\x1b[31mn\x1b[0m]: ');
      final addAllUniversities = stdin.readLineSync()?.toLowerCase() == 'y';

      for (final universityAnchor in universityAnchors) {
        final universityName = universityAnchor.text;
        final universityHref = universityAnchor.attributes['href'];
        final universityTitle = universityAnchor.attributes['title'];

        if (universityName != '' && universityHref != null && universityTitle != null && universityTitle.startsWith('Resolução Comentada')) {
          bool addUniversity = false;

          if (!addAllUniversities) {
            stdout.write('\x1b[33mAdd university\x1b[0m \x1b[36m${universityName}\x1b[0m [\x1b[32my\x1b[0m/\x1b[31mn\x1b[0m]: ');
            addUniversity = stdin.readLineSync()?.toLowerCase() == 'y';
          }

          if (addAllUniversities || addUniversity) {
            final university = University(universityName, joinURLs(entrypoiint, universityHref));
            this.universities.add(university);
          }
        }
      }
    } else {
      print('\x1b[31mError\x1b[0m in fetching \x1b[36mentrypoint\x1b[0m');
    }

    for (final university in universities) {
      await university.getExams();

      for (final exam in university.exams) {
        await exam.getQuestions();
      }
    }
  }

  saveData() async {
    if (!await Directory('data').exists()) {
      await Directory('data').create();
    }

    for (final universitiy in this.universities) {
      final encodedUniversity = jsonEncode(universitiy);

      final universityFile = File('data/${universitiy.name}.json');
      await universityFile.writeAsString(encodedUniversity);
    }
  }
}

class University {
  final String name;
  final String url;
  final List<Exam> exams = [];

  University(this.name, this.url);

  getExams() async {
    final universityResponse = await http.get(Uri.parse(this.url));

    if (universityResponse.statusCode == 200) {
      final universityDocument = parser.parse(universityResponse.body);
      final examAnchors = universityDocument.querySelectorAll('a');

      stdout.write('\x1b[33mAdd all exams\x1b[0m for \x1b[36m${this.name}\x1b[0m [\x1b[32my\x1b[0m/\x1b[31mn\x1b[0m]: ');
      final addAllExams = stdin.readLineSync()?.toLowerCase() == 'y';

      for (final examAnchor in examAnchors) {
        final examName = examAnchor.text;
        final examHref = examAnchor.attributes['href'];
        final examTitle = examAnchor.attributes['title'];

        if (examName != '' && examHref != null && examTitle != null && examHref.endsWith('?img=01') && examTitle.contains('Resolução Comentada')) {
          bool addExam = false;

          if (!addAllExams) {
            stdout.write('\x1b[33mAdd exam\x1b[0m \x1b[36m${examName}\x1b[0m for \x1b[36m${this.name}\x1b[0m [\x1b[32my\x1b[0m/\x1b[31mn\x1b[0m]: ');
            addExam = stdin.readLineSync()?.toLowerCase() == 'y';
          }

          if (addAllExams || addExam) {
            final exam = Exam(examName, joinURLs(url, examHref));
            this.exams.add(exam);
          }
        }
      }
    } else {
      print('\x1b[31mError\x1b[0m in fetching \x1b[36${this.name}\x1b[0m');
    }
  }

  Map<String, dynamic> toJson() {
    return {'name': this.name, 'url': this.url, 'exams': this.exams};
  }
}

class Exam {
  final String name;
  final String url;
  final List<Question> questions = [];

  Exam(this.name, this.url);

  getQuestions() async {
    final examResponse = await http.get(Uri.parse(this.url));

    if (examResponse.statusCode == 200) {
      final examDocument = parser.parse(examResponse.body);
      final questionAnchorsAndHeadings = examDocument.querySelectorAll('.questao-gabarito, h2');

      String? currentArea = null;

      for (final questionAnchorOrHeading in questionAnchorsAndHeadings) {
        if (questionAnchorOrHeading.localName == 'h2') {
          currentArea = questionAnchorOrHeading.text.trim();
        }

        if (questionAnchorOrHeading.localName == 'a') {
          final questionName = questionAnchorOrHeading.attributes['data-questao'];
          final questionAlternative = questionAnchorOrHeading.attributes['data-alternativa'];
          final questionURL = questionAnchorOrHeading.attributes['data-url'];

          if (questionName != null && questionURL != null) {
            final question = Question(currentArea, questionName, questionAlternative, questionURL);
            this.questions.add(question);
          }
        }
      }
    } else {
      print('\x1b[31mError\x1b[0m in fetching \x1b[36${this.name}\x1b[0m');
    }
  }

  Map<String, dynamic> toJson() {
    return {'name': this.name, 'url': this.url, 'questions': this.questions};
  }
}

class Question {
  final String name;
  final String url;
  final String? area;
  final String? alternative;

  Question(this.area, this.name, this.alternative, this.url);

  Map<String, dynamic> toJson() {
    return {'name': this.name, 'url': this.url, 'area': this.area, 'alternative': this.alternative};
  }
}

String joinURLs(String anterior, String posterior) {
  final lastPathPattern = RegExp(r'[^\/]+$');
  return anterior.toString().replaceAll(lastPathPattern, '') + posterior;
}
