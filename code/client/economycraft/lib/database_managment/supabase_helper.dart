import 'package:economycraft/classes/admin_message.dart';
import 'package:economycraft/classes/buy_order.dart';
import 'package:economycraft/classes/companyShare.dart';
import 'package:economycraft/classes/company_info.dart';
import 'package:economycraft/classes/order.dart';
import 'package:economycraft/classes/player.dart';
import 'package:economycraft/classes/price_vs_time.dart';
import 'package:economycraft/classes/share.dart';
import 'package:economycraft/classes/company.dart';
import 'package:economycraft/classes/share_changes.dart';
import 'package:economycraft/database_managment/modules/supabase_admin.dart';
import 'package:economycraft/database_managment/modules/supabase_company.dart';
import 'package:economycraft/database_managment/modules/supabase_home.dart';
import 'package:economycraft/database_managment/modules/supabase_order.dart';
import 'package:economycraft/database_managment/modules/supabase_product.dart';
import 'package:economycraft/database_managment/modules/supabase_share.dart';
import 'package:economycraft/database_managment/modules/supabase_storage.dart';
import 'package:economycraft/database_managment/modules/supabase_player.dart';
import 'package:economycraft/database_managment/modules/supabase_versioning.dart';
import 'package:economycraft/database_managment/modules/supabase_wallet.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

import 'package:economycraft/classes/product.dart';
import 'package:fraction/fraction.dart';
import 'dart:math';

class SupabaseHelper {
  static final storage = SupabaseStorage();
  static final company = SupabaseCompany();
  static final order = SupabaseOrder();
  static final product = SupabaseProduct();
  static final share = SupabaseShare();
  static final player = SupabasePlayer();
  static final versioning = SupabaseVersioning();
  static final wallet = SupabaseWallet();
  static final admin = SupabaseAdmin();
  static final home = SupabaseHome();

  //
  //
  // SERVICE RELATED SUPABASE FUNCTIONS
  //
  //

  //
  //
  // USER RELATED SUPABASE FUNCTIONS
  //
  //
  //

  //
  //
  // COMPANY RELATED SUPABASE FUNCTIONS
  //
  //

  //
  //
  // PRODUCT RELATED SUPABASE FUNCTIONS
  //
  //

  //
  //
  // ORDER RELATED SUPABASE FUNCTIONS
  //
  //

  //
  //
  // SHARE RELATED SUPABASE FUNCTIONS
  //
  //

  //
  //
  // Homepage related functions
  //
  //

  //
  //
  // Wallet related functions
  //
  //

  //
  //
  // Admin related functions
  //
  //

  //
  //
  // Versioning
  //
  //
}
