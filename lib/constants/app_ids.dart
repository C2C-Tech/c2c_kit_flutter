enum C2cApp { maintenance, ppm, authenticator }

const String otpCodeHASH =
    'HASHSERHANHASHUMAR\$Turkiye&PakistanZanzibat129.A\$B';

extension C2cAppX on C2cApp {
  /// Value sent as the `Application-ID` request header.
  String get applicationId => name;
}
