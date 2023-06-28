# Vestractor

This software extracts resolution images of the main Brazilian entrance exams available on the ["Curso Objetivo"](https://www.curso-objetivo.br/vestibular/resolucao_comentada.aspx) platform.

## Prerequesites

To use Vetractor, you need to have [Dart SDK](https://dart.dev/get-dart) `v2.18.0` installed on your computer.

Run Dart binaries from a command line, using your favorite shell, whose `$PATH` variable should include Dart's `bin` directory.

## Usage

With Dart installed and configured, run the [main.dart](./main.dart) file in your cli, followed by the necessary flags for each specific case of software operation.

```sh
	dart run main.dart # flags
```

### Flags
- `--fetch`: Allows question data to be extracted from the internet.
- `--coverage`: Limits the number of universities, exams and questions that will be fetched. Accepts an integer parameter.
- `--save`: Saves extracted data in the [lib/rawdata](./lib/rawdata) directory. Accepts `yaml` and/or `json` parameters.

### Example

```sh
	dart run main.dart --fetch --coverage=100 --save=yaml,json
```