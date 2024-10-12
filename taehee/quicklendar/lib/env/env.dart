import 'package:envied/envied.dart';
part 'env.g.dart';

@Envied(path: ".env")
abstract class Env {
  @EnviedField(varName: 'OPEN_AI_API_KEY') // .env 파일에 정의된 OpenAI API 키를 로드
  static const String openAiApiKey = _Env.openAiApiKey;

  @EnviedField(varName: 'GOOGLE_VISION_API_KEY') // .env 파일에 정의된 Google Vision API 키를 로드
  static const String googleVisionApiKey = _Env.googleVisionApiKey;
}
