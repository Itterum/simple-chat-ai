import 'package:uuid/uuid.dart';

String generateShortId() =>
    const Uuid().v4().replaceAll('-', '').substring(0, 8);
