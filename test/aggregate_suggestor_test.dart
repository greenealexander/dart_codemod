// Copyright 2019 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

@TestOn('vm')
import 'package:codemod/codemod.dart';
import 'package:codemod/test.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class BaseSuggestor implements Suggestor {
  @override
  Stream<Patch> generatePatches(_) async* {}
}

class FooSuggestor extends BaseSuggestor {
  @override
  Stream<Patch> generatePatches(_) async* {
    yield FooPatch();
  }
}

class BarSuggestor extends BaseSuggestor {
  @override
  Stream<Patch> generatePatches(_) async* {
    yield BarPatch();
  }
}

class MockPatch extends Mock implements Patch {}

class FooPatch extends MockPatch {}

class BarPatch extends MockPatch {}

class ShouldBeSkippedPatch extends MockPatch {}

void main() {
  group('AggregateSuggestor', () {
    test('accepts a list of Suggestors', () {
      final foo = BaseSuggestor();
      final bar = BaseSuggestor();
      final aggregate = AggregateSuggestor([foo, bar]);
      expect(aggregate.aggregatedSuggestors, [foo, bar]);
    });

    test('accepts an iterable of Suggestors', () {
      final foo = BaseSuggestor();
      final bar = BaseSuggestor();
      final aggregate = AggregateSuggestor([foo, bar].map((s) => s));
      expect(aggregate.aggregatedSuggestors, [foo, bar]);
    });

    group('generatePatches()', () {
      test('should yield patches from each suggestor', () async {
        final aggregate = AggregateSuggestor([
          FooSuggestor(),
          BarSuggestor(),
        ]);
        final context = await fileContextForTest('test.dart', 'test');
        expect(aggregate.generatePatches(context),
            emitsInOrder([isA<FooPatch>(), isA<BarPatch>()]));
      });
    });
  });
}
