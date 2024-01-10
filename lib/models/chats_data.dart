class ChatsData {
  String avatar;
  String title;
  String subTitle;
  int difficulty;
  int attempts;
  String assistantId;

  ChatsData({
    required this.avatar,
    required this.title,
    required this.subTitle,
    required this.difficulty,
    required this.attempts,
    required this.assistantId,
  });

  static List<ChatsData> getChats() {
    return [
      ChatsData(
        avatar: 'assets/images/55yo_back_pain.png',
        title: '55yo with back pain',
        subTitle: 'Sub 1',
        difficulty: 2,
        attempts: 1,
        assistantId: 'asst_oLP6zXce2HxRuR4dDPBDt3IM',
      ),
      ChatsData(
        avatar: 'assets/images/user_5.png',
        title: 'Chat 2',
        subTitle: 'Sub 2',
        difficulty: 3,
        attempts: 0,
        assistantId: '456',
      ),
      ChatsData(
        avatar: 'assets/images/user_2.png',
        title: 'Chat 3',
        subTitle: 'Sub 3',
        difficulty: 1,
        attempts: 2,
        assistantId: '789',
      ),
    ];
  }
}
