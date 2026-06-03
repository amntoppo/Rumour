import 'package:equatable/equatable.dart';

// ─── State ────────────────────────────────────────────────────────────────────

class RoomCodeFormState extends Equatable {
  const RoomCodeFormState({this.digits = const []});

  static const int codeLength = 6;

  final List<String> digits;

  /// The joined room code string.
  String get code => digits.join();

  /// True when exactly [codeLength] digits have been entered.
  bool get isComplete => digits.length == codeLength;

  RoomCodeFormState copyWith({List<String>? digits}) {
    return RoomCodeFormState(digits: digits ?? this.digits);
  }

  @override
  List<Object?> get props => [digits];
}
