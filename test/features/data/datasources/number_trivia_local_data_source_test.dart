import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trivia/core/error/exceptions.dart';
import 'package:trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:trivia/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../fixtures/fixture_reader.dart';
import 'package:matcher/matcher.dart';


class MockSharePreferences extends Mock implements SharedPreferences{}

void main() {
  
  NumberTriviaLocalDataSourceImpl dataSource;
  MockSharePreferences mockSharePreferences;

  setUp((){

      mockSharePreferences = MockSharePreferences();
      dataSource = NumberTriviaLocalDataSourceImpl(sharedPreferences: mockSharePreferences);


  });

  group('getLastNumberTrivia', (){  
      final tNumberTriviaModel = NumberTriviaModel.fromJson(json.decode(fixture('trivia_cached.json')));
    test(
          'should return NumberTrivia from SharedPreferences when there is one in the cache', 
          () async  {
            // arrange
            when(mockSharePreferences.getString(any)).thenReturn(fixture('trivia_cached.json'));

            // act
            final result = await dataSource.getLastNumberTrivia();

            //assert 
            verify(mockSharePreferences.getString(CACHED_NUMBER_TRIVIA));
            expect(result, equals(tNumberTriviaModel));
      
    });

test('should throw a CacheException when there is not a cached value', () {
  // arrange
  when(mockSharePreferences.getString(any)).thenReturn(null);
  // act
  // Not calling the method here, just storing it inside a call variable
  final call = dataSource.getLastNumberTrivia;
  // assert
  // Calling the method happens from a higher-order function passed.
  // This is needed to test if calling a method throws an exception.
  expect(() => call(), throwsA(TypeMatcher<CacheException>()));
});

  });

group('cachedNUmberTrivia', (){
final tNumberTriviaModel = NumberTriviaModel(number: 1, text: 'test number trivia');
  test(
    'should calls SharedPreferences to cache the data', 
  () async {
    // act 
      dataSource.cacheNumberTrivia(tNumberTriviaModel);

    //assert
    final expectJsonString = json.encode(tNumberTriviaModel.toJson());
    verify(mockSharePreferences.setString(CACHED_NUMBER_TRIVIA, expectJsonString));

  });

});

}