import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:trivia/core/error/failures.dart';
import 'package:trivia/core/usecases/usecases.dart';
import 'package:trivia/core/util/input_converter.dart';
import 'package:trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:trivia/features/number_trivia/presentation/bloc/bloc.dart';
//import 'package:trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
//import 'package:trivia/features/number_trivia/presentation/bloc/number_trivia_state.dart';

class MockGetConcreteNumberTrivia extends Mock implements GetConcreteNumberTrivia{}
class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia{}
class MockInputConverter extends Mock implements InputConverter{}

void main(){

  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp((){
      mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
      mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
      mockInputConverter = MockInputConverter ();
      bloc = NumberTriviaBloc(
        concrete: mockGetConcreteNumberTrivia, 
        random: mockGetRandomNumberTrivia, 
        converter: mockInputConverter,
        );
  });

test('initialState should be Empty', () {
  // assert
  expect(bloc.initialState, equals(Empty()));
  
});

group('GetTriviaForConcreteNumber', (){
  // The event takes in a String
  final tNumberString = '1';
  // This is the successful output of the InputConverter
  final tNumberParsed = int.parse(tNumberString);
  // NumberTrivia instance is needed too, of course
  final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

  void setUpMockInputConverterSuccess() => when(mockInputConverter.stringToUnsignedInteger(any))
        .thenReturn(Left(InvalidInputFailure()));

  test(
    'should call the InputConverter to validate and convert the string to an unsigned integer', 
    () async {
      // arrange
        setUpMockInputConverterSuccess();
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
      //assert
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));

  });

  test(
    'should emit [Error] state when the input is invalid', 
    () async {
      //arrange
         when(mockInputConverter.stringToUnsignedInteger(any))
        .thenReturn(Left(InvalidInputFailure()));
      
      //assert - later (to insure that it already registerd )
      final expected = [
              // The initial state is always emitted first

          Empty(),
          Error(message: INVALID_INPUT_FAILURE_MESSAGE)];
      expectLater(bloc, emitsInOrder(expected));
      /*
      we don't use (bloc.state)  because ->
      because in v1.0.0 blocs extend Stream so there is no longer a state stream property. The state property now refers to the bloc's current state.
      https://github.com/felangel/bloc/issues/636
       */

      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));


    
  });

  test(
    'should get data from the concrete use case', 
    () async* {
      //arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
        .thenAnswer((_) async => Right(tNumberTrivia));
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(any));
      //assert
      verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));

  });

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        // assert later
        final expected = [
          Empty(),
          Loading(),
          Loaded(trivia: tNumberTrivia),
        ];
        expectLater(bloc.state, emitsInOrder(expected));
        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
      },
    );



test(
  'should emit [Loading, Error] when getting data fails', 
  () async {
        //arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
        .thenAnswer((_) async => Left(ServerFailure()));
      //assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ];
      expectLater(bloc.state, emitsInOrder(expected));
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
   });


test(
  'should emit [Loading, Error] with a proper message for the error when getting data fails', 
  () async {
        //arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
        .thenAnswer((_) async => Left(CacheFailure()));
      //assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ];
      expectLater(bloc.state, emitsInOrder(expected));
      //act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));
   });


});

//------//

group('GetTriviaForRandomNumber', (){
  // NumberTrivia instance is needed too, of course
  final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');



  test(
    'should get data from the random use case', 
    () async* {
      //arrange
        when(mockGetRandomNumberTrivia(any))
        .thenAnswer((_) async => Right(tNumberTrivia));
      //act
      bloc.add(GetTriviaForRandomNumber());
      await untilCalled(mockGetRandomNumberTrivia(any));
      //assert
      verify(mockGetRandomNumberTrivia(NoParams()));

  });

    test(
      'should emit [Loading, Loaded] when data is gotten successfully',
      () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        // assert later
        final expected = [
          Empty(),
          Loading(),
          Loaded(trivia: tNumberTrivia),
        ];
        expectLater(bloc, emitsInOrder(expected));
        // act
        bloc.add(GetTriviaForRandomNumber());
      },
    );



test(
  'should emit [Loading, Error] when getting data fails', 
  () async {
        //arrange
        when(mockGetRandomNumberTrivia(any))
        .thenAnswer((_) async => Left(ServerFailure()));
      //assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE),
      ];
      expectLater(bloc, emitsInOrder(expected));
      //act
      bloc.add(GetTriviaForRandomNumber());
   });


test(
  'should emit [Loading, Error] with a proper message for the error when getting data fails', 
  () async {
        //arrange
        when(mockGetRandomNumberTrivia(any))
        .thenAnswer((_) async => Left(CacheFailure()));
      //assert later
      final expected = [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE),
      ];
      expectLater(bloc, emitsInOrder(expected));
      //act
      bloc.add(GetTriviaForRandomNumber());
   });


});

}

/*
There were core api changes introduced into 1.0.0:
bloc.state.listen -> bloc.listen
bloc.currentState -> bloc.state
bloc.dispatch -> bloc.add
bloc.dispose -> bloc.close

Check out https://link.medium.com/qnfMcEcW00 for more details.
https://github.com/felangel/bloc/issues/603
 */