class ChatsData {
  String avatar;
  String title;
  String subTitle;
  int difficulty;
  int attempts;
  String assistantId;
  String advisorId; //ie which will provide feedback on interaction

  ChatsData({
    required this.avatar,
    required this.title,
    required this.subTitle,
    required this.difficulty,
    required this.attempts,
    required this.assistantId,
    required this.advisorId,
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
        advisorId: 'asst_YEv4v9UdwtTd4NoJzh3iwHw7',
      ),
      ChatsData(
        avatar: 'assets/images/user_5.png',
        title: 'Chat 2',
        subTitle: 'Sub 2',
        difficulty: 3,
        attempts: 0,
        assistantId: '456',
        advisorId: '234',
      ),
      ChatsData(
        avatar: 'assets/images/user_2.png',
        title: 'Chat 3',
        subTitle: 'Sub 3',
        difficulty: 1,
        attempts: 2,
        assistantId: '789',
        advisorId: '235',
      ),
    ];
  }
}
