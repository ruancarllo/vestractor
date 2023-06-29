# Vestractor

This software extracts resolution images of the main Brazilian entrance exams available on the ["Curso Objetivo"](https://www.curso-objetivo.br/vestibular/resolucao_comentada.aspx) platform, saving their urls in [YAML](https://wikipedia.org/wiki/YAML) or [JSON](https://wikipedia.org/wiki/JSON) files in an organized way.

## Prerequesites

To use Vetractor, you need to have [Dart SDK](https://dart.dev/get-dart) `v2.18.0` installed on your computer.

Run Dart binaries from a command line, using your favorite shell, whose `$PATH` variable should include Dart's `bin/` directory.

### Dependencies

Install the dependencies required by this software, whose versions are documented in the [pubspec.yaml](./pubspec.yaml) file, using the following command:

```shell
dart pub get
```

## Usage

With Dart installed and configured, run the [main.dart](./main.dart) file in your cli, followed by the necessary flags for each specific case of software operation.

```shell
dart run main.dart # flags
```

### Flags
- `--fetch`: Allows question data to be extracted from the internet.
- `--coverage`: Limits the number of universities, exams and questions that will be fetched. Accepts an integer parameter.
- `--save`: Saves extracted data in the [lib/rawdata](./lib/rawdata) directory. Accepts `yaml` and/or `json` parameters.

### Experimental flags
- `--disperse` (**:warning: not fully implemented**): Temporarily stores the bytes of each PDF file of the extracted exams. Requires data to have been saved in yaml file.

### Example

```shell
dart run main.dart --fetch --coverage=100 --save=yaml,json
```

## Compilation

Compile this software to an executable with the following command. Make sure there is a `dist/` directory in this project folder.

```shell
dart compile exe main.dart -o dist/vestractor
```