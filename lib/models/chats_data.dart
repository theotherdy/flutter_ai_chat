class ChatsData {
  int id;
  String avatar;
  String title;
  String subTitle;
  int difficulty;
  int attempts;
  String assistantId;
  String advisorId; //ie which will provide feedback on interaction
  String voice; //voice used by text to speech
  String instructions;
  List<ChatAttempt> pastAttempts; // Store past attempts

  ChatsData(
      {required this.id,
      required this.avatar,
      required this.title,
      required this.subTitle,
      required this.difficulty,
      required this.attempts,
      required this.assistantId,
      required this.advisorId,
      required this.voice,
      required this.instructions,
      this.pastAttempts = const []});

  static List<ChatsData> getChats() {
    return [
      ChatsData(
        id: 1,
        avatar: 'assets/images/55yo_back_pain.png', //history-taking
        title: '55yo with back pain',
        subTitle: 'History-taking',
        difficulty: 2,
        attempts: 0,
        assistantId:
            'asst_ul1WkfLOW8ubtJEYD0PeQ6k2', //'asst_oLP6zXce2HxRuR4dDPBDt3IM',
        advisorId: 'asst_YEv4v9UdwtTd4NoJzh3iwHw7',
        voice: 'onyx',
        instructions: 'Please take a patient history. Use a structured ' +
            'approach, such as SOCRATES, for a pain history.',
      ),
      ChatsData(
        id: 2,
        avatar: 'assets/images/50yowoman.png', //patient-centred consulting
        title: '50yo woman with chest pain',
        subTitle: 'Listening and Patient-centred consulting',
        difficulty: 2,
        attempts: 0,
        assistantId: 'asst_vn4QcvVQHuiqgHPyzNBrK4o2',
        advisorId: 'asst_RMtNGqIvuEmmKUhUfyTXYSnQ',
        voice: 'nova',
        instructions: 'You are a student in general practice and have been ' +
            'asked to see Alex Simpson. The patient has presented to the practice ' +
            'nurse/nurse practitioner and mentioned chest pains (not currently ' +
            'present). The practice Nurse/Practitioner has done some basic tests: ' +
            'pulse 90 regular, BP 150/95, temp 36.7.  ECG – no obvious signs of ' +
            'acute MI. \n The patient is not unwell, and no urgent action is required ' +
            'so they are able to talk to you before they see the duty doctor. \n\n' +
            'Active Listening \n' +
            'How do doctors show that they are actively listening? You may wish to consider: \n' +
            '•	Giving space and time - use of silence \n' +
            '•	Verbal encouragement and facilitation - neutral phrases early and later use repetition, paraphrasing and interpretation \n' +
            '•	non-verbal encouragement \n' +
            '•	picking up cues',
      ),
      ChatsData(
        id: 3,
        avatar: 'assets/images/47yowoman.png', //patient-centred consulting
        title: '47yo woman with abdominal pain',
        subTitle: 'Listening and Patient-centred consulting',
        difficulty: 2,
        attempts: 0,
        assistantId: 'asst_Ex9Ixe2e9bd441OFlG0HqwFM',
        advisorId: 'asst_RMtNGqIvuEmmKUhUfyTXYSnQ',
        voice: 'shimmer',
        instructions: 'You are asked to see Jo Heston who has abdominal pain. ' +
            'Useful phrases and ways to explore the patient\'s ideas: \n\n' +
            'Direct approach - how did that make you feel?  \n' +
            'Pick up cues - you say you have been worried?  \n' +
            'Repetition of cues with non-verbal encouragement.  \n' +
            'Picking up and checking out verbal cues \'You said that you  ' +
            'were worried that the pain might be something serious- was  ' +
            'there something in particular you were thinking of?\'',
      ),
      ChatsData(
        id: 4,
        avatar:
            'assets/images/53yoman.png', //explanation and shared decision-making
        title: '53yo man with abdominal pain',
        subTitle: 'Explanation and shared decision-making',
        difficulty: 2,
        attempts: 0,
        assistantId: 'asst_iCXpBuRmbfchy3tEgTiXXlG6',
        advisorId: 'asst_Hycn6zIFMWPMCBncJCFIGPgO',
        voice: 'fable',
        instructions: 'You are on an attachment in a GP surgery. Chris Watson ' +
            'has had 2 episodes of abdominal pain and you have received a copy ' +
            'of an ultrasound report showing 2 small stones in the gall bladder. \n\n' +
            'Please answer their questions. \n\n' +
            'Please then discuss the management options for this patient.',
      ),
    ];
  }
}

class ChatAttempt {
  DateTime date;
  int numberOfMessages;

  ChatAttempt({required this.date, required this.numberOfMessages});
}
