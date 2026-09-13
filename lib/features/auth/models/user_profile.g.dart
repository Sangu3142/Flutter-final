// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 0;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserProfile(
      uid: fields[0] as String,
      name: fields[1] as String,
      username: fields[2] as String,
      passwordHash: fields[3] as String,
      incomeCategory: fields[4] as String,
      financialGoals: (fields[5] as List).cast<String>(),
      riskAppetite: fields[6] as String,
      xp: fields[7] as int,
      zamCoins: fields[8] as int,
      currentLevel: fields[9] as int,
      unlockedLevels: (fields[10] as List?)?.cast<int>(),
      badges: (fields[11] as List?)?.cast<String>(),
      streak: fields[12] as int,
      lastActiveStr: fields[13] as String?,
      totalSavingsZMW: fields[14] as double,
      earnedBadges: (fields[15] as List?)?.cast<String>(),
      completedQuizIds: (fields[16] as List?)?.cast<String>(),
      totalQuizXP: fields[17] as int,
      unlockedChapterIds: (fields[18] as List?)?.cast<int>(),
      lastSeasonalEventId: fields[19] as String?,
      walletBalance: fields[20] as int,
      avatarId: fields[21] as String,
      storyChoicesRaw: (fields[22] as Map?)?.cast<dynamic, dynamic>(),
      zamuLevel: fields[23] as int,
      spinLastDate: fields[24] as String?,
      bonusSpinsAvailable: fields[25] as int,
      loginBonusDay: fields[26] as int,
      loginBonusLastDate: fields[27] as String?,
      xpBoostExpiry: fields[28] as String?,
      monthlyChallengeDoneMonth: fields[29] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(30)
      ..writeByte(0)
      ..write(obj.uid)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.username)
      ..writeByte(3)
      ..write(obj.passwordHash)
      ..writeByte(4)
      ..write(obj.incomeCategory)
      ..writeByte(5)
      ..write(obj.financialGoals)
      ..writeByte(6)
      ..write(obj.riskAppetite)
      ..writeByte(7)
      ..write(obj.xp)
      ..writeByte(8)
      ..write(obj.zamCoins)
      ..writeByte(9)
      ..write(obj.currentLevel)
      ..writeByte(10)
      ..write(obj.unlockedLevels)
      ..writeByte(11)
      ..write(obj.badges)
      ..writeByte(12)
      ..write(obj.streak)
      ..writeByte(13)
      ..write(obj.lastActiveStr)
      ..writeByte(14)
      ..write(obj.totalSavingsZMW)
      ..writeByte(15)
      ..write(obj.earnedBadges)
      ..writeByte(16)
      ..write(obj.completedQuizIds)
      ..writeByte(17)
      ..write(obj.totalQuizXP)
      ..writeByte(18)
      ..write(obj.unlockedChapterIds)
      ..writeByte(19)
      ..write(obj.lastSeasonalEventId)
      ..writeByte(20)
      ..write(obj.walletBalance)
      ..writeByte(21)
      ..write(obj.avatarId)
      ..writeByte(22)
      ..write(obj.storyChoicesRaw)
      ..writeByte(23)
      ..write(obj.zamuLevel)
      ..writeByte(24)
      ..write(obj.spinLastDate)
      ..writeByte(25)
      ..write(obj.bonusSpinsAvailable)
      ..writeByte(26)
      ..write(obj.loginBonusDay)
      ..writeByte(27)
      ..write(obj.loginBonusLastDate)
      ..writeByte(28)
      ..write(obj.xpBoostExpiry)
      ..writeByte(29)
      ..write(obj.monthlyChallengeDoneMonth);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
