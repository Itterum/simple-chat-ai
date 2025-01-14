import 'package:uuid/uuid.dart';

generateShortId() => const Uuid().v4().replaceAll('-', '').substring(0, 8);
