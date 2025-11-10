import 'package:flutter/material.dart';

// extra fonts
const TextStyle displayXLL = TextStyle(
  fontSize: 58.0,
  fontWeight: FontWeight.w700,
);

const TextStyle labelLight = TextStyle(
  fontSize: 8.0,
  fontWeight: FontWeight.w400,
);

BoxShadow defaultShadow = BoxShadow(
  color: blue1.withValues(alpha: 0.20),
  blurRadius: 2.0,
  offset: const Offset(1.0, 1.0),
);

// colors
const green = Color(0xFF248731);
const red = Color(0xFFC52626);
const white = Color(0xFFFFFFFF);
const black = Color(0x00000000);

const blue1 = Color(0xFF00152D);
const blue2 = Color(0xFF002855);
const blue3 = Color(0xFF023B79);
const blue4 = Color(0xFF03478C);
const blue5 = Color(0xFF356CA3);
const blue6 = Color(0xFF7DA1C4);
const blue7 = Color(0xFFF1F5F9);

const grey1 = Color(0xFF666666);
const grey2 = Color(0xFFB9BABC);
const grey3 = Color(0xFFF4F4F4);

const category1 = Color(0xFFEDC31C);
const category2 = Color(0xFFF68428);
const category3 = Color(0xFFFF4754);
const category4 = Color(0xFFD336B6);
const category5 = Color(0xFF7236D3);
const category6 = Color(0xFF2675E3);
const category7 = Color(0xFF12BFCE);
const category8 = Color(0xFF12BA95);
const category9 = Color(0xFF0BC11D);
const category10 = Color(0xFFFF4754);
const category11 = Color(0xFFF26A52);
const category12 = Color(0xFFF36127);
const category13 = Color(0xFFB64C22);
const category14 = Color(0xFFF68428);
const category15 = Color(0xFFFC9619);
const category16 = Color(0xFFEBC35F);
const category17 = Color(0xFFD3DD16);
const category18 = Color(0xFFC3EE07);
const category19 = Color(0xFF94E30C);
const category20 = Color(0xFF5BE30C);
const category21 = Color(0xFF0BC11D);
const category22 = Color(0xFF109B37);
const category23 = Color(0xFF417388);
const category24 = Color(0xFF32A1A7);
const category25 = Color(0xFF13C9A2);
const category26 = Color(0xFF16DCB1);
const category27 = Color(0xFF11D6E1);
const category28 = Color(0xFF12BFCE);
const category29 = Color(0xFF16ADDF);
const category30 = Color(0xFF3284A7);
const category31 = Color(0xFF068DC7);
const category32 = Color(0xFF326AAF);
const category33 = Color(0xFF6B91C0);
const category34 = Color(0xFF3B90F9);
const category35 = Color(0xFF2675E3);
const category36 = Color(0xFF5819E0);
const category37 = Color(0xFF593F92);
const category38 = Color(0xFF8C6AD4);
const category39 = Color(0xFF7236D3);
const category40 = Color(0xFF9827E2);
const category41 = Color(0xFFB655F6);
const category42 = Color(0xFF6E3593);
const category43 = Color(0xFF7212B1);
const category44 = Color(0xFFAF12B1);
const category45 = Color(0xFFE31FE6);
const category46 = Color(0xFFD336B6);
const category47 = Color(0xFFF699E5);
const category48 = Color(0xFFCA0A7D);
const category49 = Color(0xFFEC3972);
const category50 = Color(0xFFD30547);
const category51 = Color(0xFFD41017);

const account1 = Color(0xFFFFB703);
const account2 = Color(0xFFFB8500);
const account3 = Color(0xFF356CA3);
const account4 = Color(0xFF8ECAE6);
const account5 = Color(0xFF3E9B12);

//dark colors

const darkGreen = Color(0xFF31B943);
const darkRed = Color(0xFFD83131);
const darkWhite = Color(0xFF181E25);
const darkBlack = Color(0xFFFFFFFF);

const darkBlue1 = Color(0xFFE3E5E8);
const darkBlue2 = Color(0xFF002247);
const darkBlue3 = Color(0xFF012C5A);
const darkBlue4 = Color(0xFF033D78);
const darkBlue5 = Color(0xFF2C5987);
const darkBlue6 = Color(0xFF6C94BC);
const darkBlue7 = Color(0xFF181E25);

const darkGrey1 = Color(0xFFA8AAAC);
const darkGrey2 = Color(0xFFC6C7C8);
const darkGrey3 = Color(0xFF181E25);
const darkGrey4 = Color(0xFF2E3338);

const darkCategory1 = Color(0xFFE3B912);
const darkCategory2 = Color(0xFFF6740C);
const darkCategory3 = Color(0xFFFA3240);
const darkCategory4 = Color(0xFFBF2AA4);
const darkCategory5 = Color(0xFF672BC7);
const darkCategory6 = Color(0xFF1B6BD9);
const darkCategory7 = Color(0xFF0FB1C0);
const darkCategory8 = Color(0xFF0EB38F);
const darkCategory9 = Color(0xFF0AAF1A);
const darkCategory10 = Color(0xFFFA3240);
const darkCategory11 = Color(0xFFE65E48);
const darkCategory12 = Color(0xFFE75720);
const darkCategory13 = Color(0xFFA5431E);
const darkCategory14 = Color(0xFFE77820);
const darkCategory15 = Color(0xFFED8A15);
const darkCategory16 = Color(0xFFDDB556);
const darkCategory17 = Color(0xFFC4CE13);
const darkCategory18 = Color(0xFFB5DC06);
const darkCategory19 = Color(0xFF87D10B);
const darkCategory20 = Color(0xFF52D10B);
const darkCategory21 = Color(0xFF0AAF1A);
const darkCategory22 = Color(0xFF0E8A31);
const darkCategory23 = Color(0xFF3A677A);
const darkCategory24 = Color(0xFF2D9199);
const darkCategory25 = Color(0xFF11B794);
const darkCategory26 = Color(0xFF14CAA3);
const darkCategory27 = Color(0xFF0FC4CF);
const darkCategory28 = Color(0xFF0FB1C0);
const darkCategory29 = Color(0xFF149FD1);
const darkCategory30 = Color(0xFF2D7899);
const darkCategory31 = Color(0xFF057FB5);
const darkCategory32 = Color(0xFF2E5FA1);
const darkCategory33 = Color(0xFF6083B2);
const darkCategory34 = Color(0xFF3582E7);
const darkCategory35 = Color(0xFF1B6BD9);
const darkCategory36 = Color(0xFF4F15CE);
const darkCategory37 = Color(0xFF4F3784);
const darkCategory38 = Color(0xFF7D5FC6);
const darkCategory39 = Color(0xFF672BC7);
const darkCategory40 = Color(0xFF8A20D4);
const darkCategory41 = Color(0xFFA54BE8);
const darkCategory42 = Color(0xFF623085);
const darkCategory43 = Color(0xFF6610A3);
const darkCategory44 = Color(0xFF9F10A3);
const darkCategory45 = Color(0xFFD51BD8);
const darkCategory46 = Color(0xFFBF2AA4);
const darkCategory47 = Color(0xFFE88BD7);
const darkCategory48 = Color(0xFFB8096F);
const darkCategory49 = Color(0xFFDE3366);
const darkCategory50 = Color(0xFFC1043F);
const darkCategory51 = Color(0xFFC20E14);

const darkAccount1 = Color(0xFFE0A30C);
const darkAccount2 = Color(0xFFDC7807);
const darkAccount3 = Color(0xFF33679B);
const darkAccount4 = Color(0xFF61B4DB);
const darkAccount5 = Color(0xFF398F10);
