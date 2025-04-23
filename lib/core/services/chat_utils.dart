class ChatUtils {
  static String getChatId(String uid1, String uid2) =>
      uid1.hashCode <= uid2.hashCode ? '${uid1}_$uid2' : '${uid2}_$uid1';
}
