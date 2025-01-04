// Mocks generated by Mockito 5.4.5 from annotations
// in geneva_libraries_app/test/widget_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:geneva_libraries_app/models/library.dart' as _i4;
import 'package:geneva_libraries_app/services/library_service.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [LibraryService].
///
/// See the documentation for Mockito's code generation for more information.
class MockLibraryService extends _i1.Mock implements _i2.LibraryService {
  @override
  _i3.Future<List<_i4.Library>> loadLibrarySchedules() => (super.noSuchMethod(
        Invocation.method(
          #loadLibrarySchedules,
          [],
        ),
        returnValue: _i3.Future<List<_i4.Library>>.value(<_i4.Library>[]),
        returnValueForMissingStub:
            _i3.Future<List<_i4.Library>>.value(<_i4.Library>[]),
      ) as _i3.Future<List<_i4.Library>>);
}
