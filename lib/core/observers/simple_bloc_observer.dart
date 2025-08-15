import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
  }

  @override
  void onEvent(BlocBase bloc, Object? event) {
    if (bloc is Bloc) {
      super.onEvent(bloc, event);
    }
    }

  @override
  void onTransition(BlocBase bloc, Transition transition) {
    if (bloc is Bloc) {
      super.onTransition(bloc, transition);
    }
   
    
    // Special logging for ExploreBloc
    if (bloc.runtimeType.toString().contains('ExploreBloc')) {
    
    }
    
    // Special logging for LocationBloc
    if (bloc.runtimeType.toString().contains('LocationBloc')) {
      print('   📍 [LOCATION_BLOC] Current: ${transition.currentState}');
      print('   📍 [LOCATION_BLOC] Event: ${transition.event}');
      print('   📍 [LOCATION_BLOC] Next: ${transition.nextState}');
    }
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
  
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
  }
}