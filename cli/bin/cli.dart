import 'dart:io';
import 'package:args/args.dart';
import 'package:fx_cli/src/create_module/module_creator.dart';

const String version = '0.0.1+4';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag('help', abbr: 'h', negatable: false, help: 'Print usage information.')
    ..addFlag('version', negatable: false, help: 'Print version.')
    ..addCommand('create')
      ..commands['create']!.addFlag('module', abbr: 'm', negatable: false, help: 'Create as module.')
      ..commands['create']!.addOption('platforms', help: 'Platforms for example app (android,ios,web,windows,macos,linux)', defaultsTo: 'android,ios')
    ..addCommand('validate');
}

void printUsage(ArgParser parser) {
  print('Usage: fx_cli <command> [arguments]');
  print('');
  print(parser.usage);
  print('');
  print('Commands:');
  print('  create <name> -m [--platforms=android,ios]    Create a Flutter module with example');
  print('  validate                                       Validate template.zip exists');
  print('');
  print('Options for create:');
  print('  --platforms    Platforms for example app (default: android,ios)');
  print('                 Available: android,ios,web,windows,macos,linux');
}

Future<void> createModule(String name, {String platforms = 'android,ios'}) async {
  await ModuleCreator.createModule(name, platforms: platforms);
}

Future<void> validateTemplate() async {
  await ModuleCreator.validateTemplate();
}





void main(List<String> arguments) async {
  final parser = buildParser();

  try {
    final results = parser.parse(arguments);

    if (results.flag('help')) {
      printUsage(parser);
      return;
    }

    if (results.flag('version')) {
      print('fx_cli version: $version');
      return;
    }

    final command = results.command;
    if (command?.name == 'create') {
      if (command!.rest.isEmpty) {
        print('Error: Module name required');
        printUsage(parser);
        return;
      }

      final moduleName = command.rest.first;
      if (command.flag('module')) {
        final platforms = command.option('platforms') ?? 'android,ios';
        await createModule(moduleName, platforms: platforms);
      } else {
        print('Error: Use -m flag to create module');
        printUsage(parser);
      }
    } else if (command?.name == 'validate') {
      await validateTemplate();
    } else {
      printUsage(parser);
    }
  } on FormatException catch (e) {
    print('Error: $e');
    printUsage(parser);
  } catch (e) {
    print('Error: $e');
    printUsage(parser);
  }
}
