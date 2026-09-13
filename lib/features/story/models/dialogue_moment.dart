import '../../../core/constants.dart';

class DialogueOption {
  final String text;
  final String financialConsequence;
  final int xpDelta;
  final String? leadsToBadge;

  const DialogueOption({
    required this.text,
    required this.financialConsequence,
    required this.xpDelta,
    this.leadsToBadge,
  });
}

enum StoryPath { savings, investment, entrepreneur }

class DialogueMoment {
  final String momentId;
  final String promptText;
  final String speakerName;
  final List<DialogueOption> options;
  final StoryPath? pathHint;

  const DialogueMoment({
    required this.momentId,
    required this.promptText,
    required this.speakerName,
    required this.options,
    this.pathHint,
  });
}

const kDialogueMoments = <String, DialogueMoment>{
  'ch1_m1': DialogueMoment(
    momentId: 'ch1_m1',
    promptText: 'Mwansa has ZMW 500 left after paying bills. What should she do?',
    speakerName: 'Mwansa',
    pathHint: StoryPath.savings,
    options: [
      DialogueOption(
        text: 'Save ZMW 400 in a savings account',
        financialConsequence: 'You chose to save — balance grew by ZMW 500 after 6 months!',
        xpDelta: 30,
        leadsToBadge: kBadgeStorySaver,
      ),
      DialogueOption(
        text: 'Invest ZMW 400 in LUSE shares',
        financialConsequence: 'You chose to invest — portfolio gained 12% in 6 months.',
        xpDelta: 25,
        leadsToBadge: kBadgeStoryInvestor,
      ),
      DialogueOption(
        text: 'Start a small tomato stall at the market',
        financialConsequence: 'You started a business — earned ZMW 200 extra per month!',
        xpDelta: 20,
        leadsToBadge: kBadgeStoryEntrepreneur,
      ),
    ],
  ),
  'ch1_m2': DialogueMoment(
    momentId: 'ch1_m2',
    promptText: 'The market seller offers Mwansa a credit deal. What does she do?',
    speakerName: 'Market Seller',
    pathHint: StoryPath.savings,
    options: [
      DialogueOption(
        text: 'Decline and use her savings',
        financialConsequence: 'Paid cash — no interest charges, savings reduced by ZMW 200.',
        xpDelta: 25,
        leadsToBadge: kBadgeStorySaver,
      ),
      DialogueOption(
        text: 'Take the credit deal at 20% interest',
        financialConsequence: 'Took credit — paid back ZMW 240 total over 3 months.',
        xpDelta: 15,
        leadsToBadge: null,
      ),
      DialogueOption(
        text: 'Negotiate a bulk order for a discount',
        financialConsequence: 'Negotiated a 10% discount — smart business thinking!',
        xpDelta: 20,
        leadsToBadge: kBadgeStoryEntrepreneur,
      ),
    ],
  ),
  'ch1_m3': DialogueMoment(
    momentId: 'ch1_m3',
    promptText: 'Mwansa receives a ZMW 1,000 bonus. How does she use it?',
    speakerName: 'Mwansa',
    pathHint: null,
    options: [
      DialogueOption(
        text: 'Split equally: ZMW 500 save, ZMW 500 invest',
        financialConsequence: 'Diversified — savings grew and investments appreciated.',
        xpDelta: 30,
        leadsToBadge: kBadgeStoryInvestor,
      ),
      DialogueOption(
        text: 'Put it all into an emergency fund',
        financialConsequence: 'Emergency fund secured — peace of mind for 2 months.',
        xpDelta: 25,
        leadsToBadge: kBadgeStorySaver,
      ),
      DialogueOption(
        text: 'Reinvest into the tomato stall',
        financialConsequence: 'Expanded the stall — revenue doubled the next month!',
        xpDelta: 20,
        leadsToBadge: kBadgeStoryEntrepreneur,
      ),
    ],
  ),
  'ch2_m1': DialogueMoment(
    momentId: 'ch2_m1',
    promptText: 'A bank officer offers Mwansa a personal loan. What does she decide?',
    speakerName: 'Bank Officer',
    pathHint: null,
    options: [
      DialogueOption(
        text: 'Decline — her savings cover the need',
        financialConsequence: 'Avoided debt — savings sufficient, interest saved ZMW 150.',
        xpDelta: 30,
        leadsToBadge: kBadgeStorySaver,
      ),
      DialogueOption(
        text: 'Take a small loan to expand the business',
        financialConsequence: 'Loan leveraged for growth — revenue up 40% but repaying debt.',
        xpDelta: 25,
        leadsToBadge: kBadgeStoryEntrepreneur,
      ),
      DialogueOption(
        text: 'Use the loan to buy LUSE shares',
        financialConsequence: 'Risky investment — shares gained 20% but loan interest cost 15%.',
        xpDelta: 20,
        leadsToBadge: kBadgeStoryInvestor,
      ),
    ],
  ),
  'ch2_m2': DialogueMoment(
    momentId: 'ch2_m2',
    promptText: 'Insurance premium due — Mwansa\'s budget is tight this month.',
    speakerName: 'Mwansa',
    pathHint: StoryPath.savings,
    options: [
      DialogueOption(
        text: 'Pay the premium — keep the coverage',
        financialConsequence: 'Stayed insured — small budget strain but long-term security.',
        xpDelta: 30,
        leadsToBadge: kBadgeStorySaver,
      ),
      DialogueOption(
        text: 'Skip this month and catch up next month',
        financialConsequence: 'Skipped payment — policy lapsed, had to restart with penalties.',
        xpDelta: 10,
        leadsToBadge: null,
      ),
      DialogueOption(
        text: 'Find a cheaper policy and switch',
        financialConsequence: 'Switched provider — saved ZMW 50/month with equivalent cover.',
        xpDelta: 25,
        leadsToBadge: kBadgeStoryEntrepreneur,
      ),
    ],
  ),
  'ch2_m3': DialogueMoment(
    momentId: 'ch2_m3',
    promptText: 'Mwansa\'s friend proposes a joint business venture.',
    speakerName: 'Mwansa',
    pathHint: StoryPath.entrepreneur,
    options: [
      DialogueOption(
        text: 'Partner up — invest ZMW 800 each',
        financialConsequence: 'Partnership launched — shared risk, profits split fairly.',
        xpDelta: 25,
        leadsToBadge: kBadgeStoryEntrepreneur,
      ),
      DialogueOption(
        text: 'Decline — keep savings separate',
        financialConsequence: 'Kept savings intact — missed opportunity but avoided risk.',
        xpDelta: 20,
        leadsToBadge: kBadgeStorySaver,
      ),
      DialogueOption(
        text: 'Offer advice instead of capital',
        financialConsequence: 'Contributed expertise — no capital risk, earned a consulting fee.',
        xpDelta: 15,
        leadsToBadge: null,
      ),
    ],
  ),
  'ch3_m1': DialogueMoment(
    momentId: 'ch3_m1',
    promptText: 'An investor wants to buy into Mwansa\'s business.',
    speakerName: 'Investor',
    pathHint: StoryPath.investment,
    options: [
      DialogueOption(
        text: 'Accept — sell 30% equity for ZMW 5,000',
        financialConsequence: 'Got capital for growth but gave up 30% future profits.',
        xpDelta: 30,
        leadsToBadge: kBadgeStoryEntrepreneur,
      ),
      DialogueOption(
        text: 'Decline — grow organically',
        financialConsequence: 'Kept 100% ownership — slower growth, full control.',
        xpDelta: 25,
        leadsToBadge: kBadgeStorySaver,
      ),
      DialogueOption(
        text: 'Counter-offer: sell 15% for ZMW 3,000',
        financialConsequence: 'Negotiated better terms — partial capital with less dilution.',
        xpDelta: 30,
        leadsToBadge: kBadgeStoryInvestor,
      ),
    ],
  ),
  'ch3_m2': DialogueMoment(
    momentId: 'ch3_m2',
    promptText: 'LUSE shares are down 15% this week. Mwansa holds ZMW 2,000 in stocks.',
    speakerName: 'Mwansa',
    pathHint: StoryPath.investment,
    options: [
      DialogueOption(
        text: 'Hold — markets recover over time',
        financialConsequence: 'Held position — shares recovered 18% over the next quarter.',
        xpDelta: 30,
        leadsToBadge: kBadgeStoryInvestor,
      ),
      DialogueOption(
        text: 'Sell now to stop the loss',
        financialConsequence: 'Sold at a loss — locked in ZMW 300 loss, missed the recovery.',
        xpDelta: 10,
        leadsToBadge: null,
      ),
      DialogueOption(
        text: 'Buy more — it\'s a discount opportunity',
        financialConsequence: 'Bought the dip — doubled gains when price recovered.',
        xpDelta: 25,
        leadsToBadge: kBadgeStoryInvestor,
      ),
    ],
  ),
  'ch3_m3': DialogueMoment(
    momentId: 'ch3_m3',
    promptText: 'Tax filing deadline approaches. Mwansa is confused about deductions.',
    speakerName: 'Bank Officer',
    pathHint: null,
    options: [
      DialogueOption(
        text: 'Hire an accountant',
        financialConsequence: 'Paid ZMW 400 but got ZMW 800 refund — net gain ZMW 400.',
        xpDelta: 25,
        leadsToBadge: null,
      ),
      DialogueOption(
        text: 'File herself using ZRA guidelines',
        financialConsequence: 'Self-filed successfully — saved accountant fee, built knowledge.',
        xpDelta: 30,
        leadsToBadge: kBadgeStoryEntrepreneur,
      ),
      DialogueOption(
        text: 'Ask the bank officer for help',
        financialConsequence: 'Got basic guidance — filed correctly, no penalties.',
        xpDelta: 20,
        leadsToBadge: null,
      ),
    ],
  ),
  'ch4_m1': DialogueMoment(
    momentId: 'ch4_m1',
    promptText: 'Mwansa\'s business needs new equipment. She has 3 options.',
    speakerName: 'Mwansa',
    pathHint: StoryPath.entrepreneur,
    options: [
      DialogueOption(
        text: 'Buy new — ZMW 8,000 from savings',
        financialConsequence: 'New equipment — reliable, depleted emergency fund.',
        xpDelta: 20,
        leadsToBadge: kBadgeStorySaver,
      ),
      DialogueOption(
        text: 'Buy second-hand — ZMW 3,000',
        financialConsequence: 'Cost-effective — saved ZMW 5,000, slightly less reliable.',
        xpDelta: 25,
        leadsToBadge: kBadgeStoryEntrepreneur,
      ),
      DialogueOption(
        text: 'Lease — ZMW 500/month',
        financialConsequence: 'Leased — preserved capital, flexible upgrade path.',
        xpDelta: 30,
        leadsToBadge: kBadgeStoryInvestor,
      ),
    ],
  ),
  'ch4_m2': DialogueMoment(
    momentId: 'ch4_m2',
    promptText: 'Mwansa considers retirement planning at age 35.',
    speakerName: 'Mwansa',
    pathHint: StoryPath.savings,
    options: [
      DialogueOption(
        text: 'Start a pension contribution now',
        financialConsequence: 'ZMW 200/month from age 35 → ZMW 240,000 by retirement.',
        xpDelta: 35,
        leadsToBadge: kBadgeStorySaver,
      ),
      DialogueOption(
        text: 'Wait until business is more stable',
        financialConsequence: 'Delayed 5 years — pension pot 30% smaller at retirement.',
        xpDelta: 15,
        leadsToBadge: null,
      ),
      DialogueOption(
        text: 'Invest in property instead',
        financialConsequence: 'Property appreciates — alternative retirement asset built.',
        xpDelta: 25,
        leadsToBadge: kBadgeStoryInvestor,
      ),
    ],
  ),
  'ch4_m3': DialogueMoment(
    momentId: 'ch4_m3',
    promptText: 'Mwansa\'s final decision: what defines her financial legacy?',
    speakerName: 'Mwansa',
    pathHint: null,
    options: [
      DialogueOption(
        text: 'Build a community savings cooperative',
        financialConsequence: 'Founded a SACCO — helped 50 families build savings.',
        xpDelta: 40,
        leadsToBadge: kBadgeStorySaver,
      ),
      DialogueOption(
        text: 'Expand into a Zambian tech startup',
        financialConsequence: 'Launched a fintech — 500 users in year one.',
        xpDelta: 40,
        leadsToBadge: kBadgeStoryEntrepreneur,
      ),
      DialogueOption(
        text: 'Create a diversified investment portfolio',
        financialConsequence: 'Portfolio self-sustaining — passive income exceeds expenses.',
        xpDelta: 40,
        leadsToBadge: kBadgeStoryInvestor,
      ),
    ],
  ),
};
