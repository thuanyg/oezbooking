import 'package:bloc/bloc.dart';
import 'package:oezbooking/core/utils/encryption_helper.dart';
import 'package:oezbooking/features/login/data/model/organizer.dart';
import 'package:oezbooking/features/login/domain/usecase/login_usecase.dart';
import 'package:oezbooking/features/login/presentation/bloc/login_event.dart';
import 'package:oezbooking/features/login/presentation/bloc/login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final LoginUseCase loginUseCase;
  Organizer? organizer;
  LoginBloc(this.loginUseCase) : super(LoginInitial()) {
    on<PressedLogin>(
      (event, emit)async {
        emit(LoginLoading());
        final organizer = await loginUseCase(event.email, event.password);
        if(organizer != null){
          this.organizer = organizer;
          emit(LoginSuccess(organizer));
        } else {
          emit(LoginFailed("Email or password is not correct!"));
        }
      },
    );
  }

  void reset(){
    organizer = null;
    emit(LoginInitial());
  }
}
