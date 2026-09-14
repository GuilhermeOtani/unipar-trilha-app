import 'package:flutter/painting.dart';

/// Paleta bruta do kit Unipar Trail Code.
///
/// Este é o único arquivo do app que declara valores hexadecimais. Widgets e
/// páginas não devem importar esta classe: consuma os tokens semânticos de
/// `AppColors`.
abstract final class AppPalette {
  // Paleta canônica da prancha de marca do Canva.
  static const greenLight = Color(0xFF86CB92);
  static const green = Color(0xFF71B46D);
  static const blue = Color(0xFF404E7C);
  static const indigo = Color(0xFF251F47);
  static const plum = Color(0xFF260F26);

  // Cores operacionais observadas nas telas (design-tokens/colors.json).
  static const navy950 = Color(0xFF0E082E);
  static const navy900 = Color(0xFF14183B);
  static const cyan = Color(0xFF1BB2E1);
  static const purple = Color(0xFF4A299A);
  static const successSurface = Color(0xFF143B21);
  static const dangerSurface = Color(0xFF34203B);
  static const textSoft = Color(0xFF9398C2);
  static const textLight = Color(0xFFE6EAED);
  static const navActive = Color(0xFFAE76FE);
  static const statusError = Color(0xFFFA777D);
  static const statusSuccess = Color(0xFF00BF15);
  static const notification = Color(0xFFF14538);
  static const white = Color(0xFFFFFFFF);

  // Derivadas por amostragem de pixels das telas 1–7 (FE-002). Não constam
  // no kit exportado; ver DESIGN_SYSTEM.md, seção "Tokens derivados".
  static const royal = Color(0xFF202A6D);
  static const steel = Color(0xFF3579A7);
  static const sky = Color(0xFF6EBBFC);
  static const ocean = Color(0xFF103F5B);
  static const plumDeep = Color(0xFF1F0C1F);
  static const track = Color(0xFF201C4C);
  static const violetBorder = Color(0xFF7050C6);
  static const selectedSurface = Color(0xFF533898);
  static const successBorder = Color(0xFF50C66A);
  static const dangerBorder = Color(0xFFB05B70);
  static const progressFill = Color(0xFF0BD43D);
  static const mauve = Color(0xFF824D82);
  static const cobalt = Color(0xFF3D56AF);
  static const slate = Color(0xFF262A54);

  // Home (tela 1), amostradas no FE-002 refinado.
  static const lime = Color(0xFF9EFE78);
  static const lilac = Color(0xFFB882FF);
  static const aqua = Color(0xFF68FBFB);
  static const orchid = Color(0xFFCE94FF);
  static const lavender = Color(0xFF7370BF);
  static const iris = Color(0xFF7F63FF);
  static const indigoDeep = Color(0xFF131942);
  static const denim = Color(0xFF263481);
  static const dusk = Color(0xFF7177A8);
  static const haze = Color(0xFF79A5C1);
  static const plumNight = Color(0xFF150815);

  // Telas 2–7, amostradas no FE-002 refinado.
  static const azure = Color(0xFF47B1FF);
  static const azureLight = Color(0xFF55B5FF);
  static const mint = Color(0xFF72DD76);
  static const codeAqua = Color(0xFF01ECF9);
  static const pewter = Color(0xFFA4A5A6);
  static const scrollTrack = Color(0xFF5B6E9E);
  static const scrollThumb = Color(0xFF9EA5C7);
  static const abyss = Color(0xFF1D3872);
  static const black = Color(0xFF000000);

  // Cores de marca dos cursos (ícones da tela 7 e card XAMPP da tela 3).
  static const brandSpring = Color(0xFF6DB33F);
  static const brandXampp = Color(0xFFFB7A24);
  static const brandJs = Color(0xFFF7DF1E);
  static const brandHibernate = Color(0xFF59666C);
}
