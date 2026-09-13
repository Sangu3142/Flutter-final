/// life_event.dart
/// Purpose: Pure Dart model + pool of 30 life events for the Random Life
///          Events Engine. No Hive — the pool is immutable app constants.
library;

enum LifeEventCategory { family, business, financial, health, community }

enum LifeEventEffect {
  walletGain,
  walletLoss,
  happinessGain,
  happinessLoss,
  complianceGain,
  complianceLoss,
  healthGain,
  healthLoss,
  none,
}

class LifeEventChoice {
  const LifeEventChoice({
    required this.label,
    required this.description,
    required this.effect,
    this.effectAmount = 0,
    required this.lesson,
  });

  final String label;
  final String description;
  final LifeEventEffect effect;
  final int effectAmount;
  final String lesson;
}

class LifeEvent {
  const LifeEvent({
    required this.id,
    required this.category,
    required this.emoji,
    required this.title,
    required this.narrative,
    required this.choices,
  });

  final int id;
  final LifeEventCategory category;
  final String emoji;
  final String title;
  final String narrative;
  final List<LifeEventChoice> choices;
}

// ─────────────────────────────────────────────────────────────────────────────
// 30-Event Pool
// ─────────────────────────────────────────────────────────────────────────────

const List<LifeEvent> kLifeEvents = [
  // ── FINANCIAL ────────────────────────────────────────────────────────────
  LifeEvent(
    id: 0,
    category: LifeEventCategory.financial,
    emoji: '💸',
    title: 'Unexpected Hospital Bill',
    narrative:
        'Your child falls sick and the clinic charges ZMW 350. Your emergency fund '
        'is thin. How do you handle it?',
    choices: [
      LifeEventChoice(
        label: 'Pay from savings',
        description: 'Dip into your wallet — responsible but painful.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 350,
        lesson: 'Emergency funds exist for moments like this. A 3-month buffer prevents debt.',
      ),
      LifeEventChoice(
        label: 'Take a Shylock loan',
        description: 'Borrow quickly but at 30% interest.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 100,
        lesson: 'Informal lenders charge extreme interest. Always avoid Shylock borrowing.',
      ),
      LifeEventChoice(
        label: 'Use NHIMA card',
        description: 'Your NHIMA cover absorbs most of the cost.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 5,
        lesson: 'Health insurance like NHIMA drastically reduces out-of-pocket medical costs.',
      ),
    ],
  ),
  LifeEvent(
    id: 1,
    category: LifeEventCategory.financial,
    emoji: '📉',
    title: 'Kwacha Weakens Overnight',
    narrative:
        'The ZMW drops 8% against the dollar. Imported goods now cost more. '
        'Your monthly food bill will rise. What do you do?',
    choices: [
      LifeEventChoice(
        label: 'Buy local produce instead',
        description: 'Switch to Zambian-grown staples and save money.',
        effect: LifeEventEffect.walletGain,
        effectAmount: 80,
        lesson: 'Buying local shields you from currency fluctuations and supports Zambian farmers.',
      ),
      LifeEventChoice(
        label: 'Stock up before prices rise',
        description: 'Spend now to avoid higher prices later.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 200,
        lesson: 'Hedging against inflation by bulk-buying can be smart if you have storage.',
      ),
      LifeEventChoice(
        label: 'Do nothing — worry later',
        description: 'Ignore it and absorb the cost hit.',
        effect: LifeEventEffect.happinessLoss,
        effectAmount: 5,
        lesson: 'Ignoring macroeconomic signals leads to budget shock. Stay financially aware.',
      ),
    ],
  ),
  LifeEvent(
    id: 2,
    category: LifeEventCategory.financial,
    emoji: '🎰',
    title: 'Get-Rich-Quick Scheme',
    narrative:
        'A friend tells you to invest ZMW 500 in a scheme that promises 200% '
        'returns in 2 weeks. It sounds too good to be true.',
    choices: [
      LifeEventChoice(
        label: 'Invest — double your money!',
        description: 'Risk it all on the scheme.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 500,
        lesson: 'If it sounds too good to be true, it is. Ponzi schemes always collapse.',
      ),
      LifeEventChoice(
        label: 'Decline politely',
        description: 'Trust your instincts and protect your savings.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 3,
        lesson: 'Legitimate investments offer 8–25% annual returns — not 200% in 2 weeks.',
      ),
      LifeEventChoice(
        label: 'Report to SEC Zambia',
        description: 'Alert regulators to protect others.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 8,
        lesson: 'The Securities and Exchange Commission Zambia regulates investments. Report fraud.',
      ),
    ],
  ),
  LifeEvent(
    id: 3,
    category: LifeEventCategory.financial,
    emoji: '💳',
    title: 'Mobile Money Fraud Alert',
    narrative:
        'You receive an SMS: "Your MoMo PIN is expired. Reply with PIN to reactivate." '
        'What do you do?',
    choices: [
      LifeEventChoice(
        label: 'Reply with your PIN',
        description: 'Trust the message — it looks official.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 300,
        lesson: 'Never share your PIN. MTN and Airtel will NEVER ask for it via SMS.',
      ),
      LifeEventChoice(
        label: 'Delete and ignore',
        description: 'Recognise the phishing attempt.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 5,
        lesson: 'Vishing and smishing are growing in Zambia. Always verify via official numbers.',
      ),
      LifeEventChoice(
        label: 'Call your provider directly',
        description: 'Verify through the official helpline.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 10,
        lesson: 'Direct verification is the gold standard for handling suspicious messages.',
      ),
    ],
  ),
  LifeEvent(
    id: 4,
    category: LifeEventCategory.financial,
    emoji: '🏦',
    title: 'Interest Rate Hike',
    narrative:
        'Bank of Zambia raises the policy rate to 13.5%. Your loan repayments '
        'will increase by ZMW 120 per month. How do you adapt?',
    choices: [
      LifeEventChoice(
        label: 'Renegotiate the loan terms',
        description: 'Visit the bank and ask for a fixed-rate option.',
        effect: LifeEventEffect.walletGain,
        effectAmount: 60,
        lesson: 'Fixed-rate loans protect you from rate hikes. Always ask your bank about options.',
      ),
      LifeEventChoice(
        label: 'Cut leisure spending',
        description: 'Reduce non-essential expenses to absorb the increase.',
        effect: LifeEventEffect.happinessLoss,
        effectAmount: 5,
        lesson: 'Budget flexibility — having discretionary spending to cut — is a financial buffer.',
      ),
      LifeEventChoice(
        label: 'Default on one payment',
        description: 'Skip a month hoping things improve.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 200,
        lesson: 'Loan defaults attract penalties and damage your credit score. Always communicate first.',
      ),
    ],
  ),
  // ── FAMILY ───────────────────────────────────────────────────────────────
  LifeEvent(
    id: 5,
    category: LifeEventCategory.family,
    emoji: '🎓',
    title: 'School Fees Deadline Tomorrow',
    narrative:
        "Your child's school fees of ZMW 450 are due tomorrow. You forgot to plan for it.",
    choices: [
      LifeEventChoice(
        label: 'Pay from your wallet',
        description: 'Prioritise education — pay immediately.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 450,
        lesson: 'Education is the highest-return investment. Budget school fees as a fixed monthly expense.',
      ),
      LifeEventChoice(
        label: 'Ask a relative to lend you',
        description: 'Borrow interest-free from family.',
        effect: LifeEventEffect.happinessLoss,
        effectAmount: 3,
        lesson: 'Family lending can damage relationships. A dedicated school fees savings envelope prevents this.',
      ),
      LifeEventChoice(
        label: 'Explain to the school and pay next week',
        description: 'Communicate transparently with the school.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 2,
        lesson: 'Open communication buys goodwill. But planning ahead eliminates the need entirely.',
      ),
    ],
  ),
  LifeEvent(
    id: 6,
    category: LifeEventCategory.family,
    emoji: '🎂',
    title: "Spouse's Birthday Surprise",
    narrative:
        "It's your spouse's birthday. They deserve something special, but you're "
        'on a tight budget.',
    choices: [
      LifeEventChoice(
        label: 'Spend ZMW 200 on a gift',
        description: 'Splurge a little to show you care.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 200,
        lesson: 'Planned gift budgets (ZMW 150–300/year) prevent surprise spending spikes.',
      ),
      LifeEventChoice(
        label: 'Cook a special meal at home',
        description: 'Thoughtful and budget-friendly.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 10,
        lesson: "Quality time often means more than expensive gifts. Plan experiences, not just purchases.",
      ),
      LifeEventChoice(
        label: 'Forget entirely',
        description: 'Hope they understand.',
        effect: LifeEventEffect.happinessLoss,
        effectAmount: 15,
        lesson: 'Relationships need investment — even small, planned gestures strengthen bonds.',
      ),
    ],
  ),
  LifeEvent(
    id: 7,
    category: LifeEventCategory.family,
    emoji: '🏠',
    title: 'Landlord Increases Rent',
    narrative:
        'Your landlord announces a 15% rent increase next month — ZMW 120 more. '
        'You have three weeks to decide.',
    choices: [
      LifeEventChoice(
        label: 'Accept and adjust budget',
        description: 'Stay and cut other expenses.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 120,
        lesson: 'Housing costs should stay under 30% of income. Track this ratio regularly.',
      ),
      LifeEventChoice(
        label: 'Negotiate with landlord',
        description: 'Make a case for a smaller increase.',
        effect: LifeEventEffect.walletGain,
        effectAmount: 60,
        lesson: 'Negotiation is a financial skill. Long-term tenants have leverage — use it.',
      ),
      LifeEventChoice(
        label: 'Find cheaper accommodation',
        description: 'Move to reduce long-term housing costs.',
        effect: LifeEventEffect.happinessLoss,
        effectAmount: 5,
        lesson: 'Moving has upfront costs but can save significantly in the long run.',
      ),
    ],
  ),
  LifeEvent(
    id: 8,
    category: LifeEventCategory.family,
    emoji: '👶',
    title: 'New Baby Announcement',
    narrative:
        'Your spouse shares exciting news — a baby is on the way! '
        'Estimated costs: ZMW 800 for antenatal care and delivery.',
    choices: [
      LifeEventChoice(
        label: 'Open a baby savings envelope',
        description: 'Start saving ZMW 100/week immediately.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 15,
        lesson: 'Planning for major life events well in advance is the cornerstone of good financial health.',
      ),
      LifeEventChoice(
        label: 'Use NHIMA for delivery costs',
        description: 'Check if your health cover includes maternity.',
        effect: LifeEventEffect.walletGain,
        effectAmount: 400,
        lesson: 'NHIMA covers maternity services. Always know what your health insurance includes.',
      ),
      LifeEventChoice(
        label: 'Worry about it later',
        description: 'Deal with it when the time comes.',
        effect: LifeEventEffect.happinessLoss,
        effectAmount: 10,
        lesson: 'Delaying financial planning for predictable events always leads to stress and debt.',
      ),
    ],
  ),
  LifeEvent(
    id: 9,
    category: LifeEventCategory.family,
    emoji: '🛠️',
    title: 'Roof Starts Leaking',
    narrative:
        'Heavy rains reveal a leaking roof. Repairs will cost ZMW 600. '
        'The rainy season is not over yet.',
    choices: [
      LifeEventChoice(
        label: 'Fix it immediately',
        description: 'Pay for repairs now to prevent worse damage.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 600,
        lesson: 'Deferred maintenance always costs more. A home maintenance fund of 1% of home value/year is ideal.',
      ),
      LifeEventChoice(
        label: 'Patch it temporarily',
        description: 'Spend ZMW 100 on a temporary fix.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 100,
        lesson: 'Temporary fixes can buy time, but the underlying issue must eventually be addressed.',
      ),
      LifeEventChoice(
        label: 'Ignore it — it is just a drip',
        description: 'Hope the rains stop soon.',
        effect: LifeEventEffect.happinessLoss,
        effectAmount: 10,
        lesson: 'Ignoring structural issues compounds costs exponentially over time.',
      ),
    ],
  ),
  // ── BUSINESS ─────────────────────────────────────────────────────────────
  LifeEvent(
    id: 10,
    category: LifeEventCategory.business,
    emoji: '📋',
    title: 'ZRA Tax Compliance Notice',
    narrative:
        'You receive a notice that your business has unpaid turnover tax for Q3. '
        'A penalty of ZMW 250 applies if not resolved within 14 days.',
    choices: [
      LifeEventChoice(
        label: 'Pay the penalty and file immediately',
        description: 'Clear the debt and get compliant.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 250,
        lesson: 'ZRA penalties compound. Filing on time — even if you cannot pay — reduces liability.',
      ),
      LifeEventChoice(
        label: 'Visit ZRA and explain your situation',
        description: 'Negotiate a payment plan.',
        effect: LifeEventEffect.complianceGain,
        effectAmount: 15,
        lesson: 'ZRA offers instalment plans. Voluntary disclosure often reduces penalties.',
      ),
      LifeEventChoice(
        label: 'Ignore the notice',
        description: 'Hope it goes away.',
        effect: LifeEventEffect.complianceLoss,
        effectAmount: 20,
        lesson: 'Ignoring ZRA notices leads to seizure of assets. Always respond within the stated deadline.',
      ),
    ],
  ),
  LifeEvent(
    id: 11,
    category: LifeEventCategory.business,
    emoji: '🤝',
    title: 'Big Client Opportunity',
    narrative:
        'A supermarket chain wants to stock your products but requires 30-day '
        'payment terms. You would need to produce upfront without payment for a month.',
    choices: [
      LifeEventChoice(
        label: 'Accept — it is a great opportunity',
        description: 'Stretch your cash flow to land the deal.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 200,
        lesson: 'Large clients often have long payment terms. Invoice financing or overdraft facilities can bridge the gap.',
      ),
      LifeEventChoice(
        label: 'Negotiate for 15-day terms',
        description: 'Counter-offer a shorter payment period.',
        effect: LifeEventEffect.walletGain,
        effectAmount: 150,
        lesson: 'Payment terms are negotiable. Shorter cycles improve cash flow significantly.',
      ),
      LifeEventChoice(
        label: 'Decline — too risky right now',
        description: 'Protect your cash position.',
        effect: LifeEventEffect.happinessLoss,
        effectAmount: 5,
        lesson: 'Knowing your cash flow limits is a strength. Overcommitting kills small businesses.',
      ),
    ],
  ),
  LifeEvent(
    id: 12,
    category: LifeEventCategory.business,
    emoji: '⚡',
    title: 'ZESCO Load Shedding Crisis',
    narrative:
        'Extended load shedding shuts down your equipment for 8 hours a day, '
        'cutting production by 40%.',
    choices: [
      LifeEventChoice(
        label: 'Rent a generator',
        description: 'ZMW 300/week keeps production running.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 300,
        lesson: 'Energy backup is a business continuity investment in Zambia — factor it into operating costs.',
      ),
      LifeEventChoice(
        label: 'Shift working hours to off-peak',
        description: 'Adapt your schedule to available power windows.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 5,
        lesson: 'Operational flexibility is a competitive advantage in challenging infrastructure environments.',
      ),
      LifeEventChoice(
        label: 'Pause operations temporarily',
        description: 'Wait for the situation to improve.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 400,
        lesson: 'Business downtime has hidden costs: lost orders, spoiled stock, staff idle time.',
      ),
    ],
  ),
  LifeEvent(
    id: 13,
    category: LifeEventCategory.business,
    emoji: '👷',
    title: 'Staff Member Resigns Suddenly',
    narrative:
        'Your best employee gives you one week notice. Replacing them could '
        'take a month and cost ZMW 400 in recruitment.',
    choices: [
      LifeEventChoice(
        label: 'Counter-offer a salary increase',
        description: 'Offer ZMW 200 more per month to retain them.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 200,
        lesson: 'Retention is cheaper than recruitment. Know your employees\' market rate.',
      ),
      LifeEventChoice(
        label: 'Accept and post on social media',
        description: 'Use free channels to find a replacement fast.',
        effect: LifeEventEffect.happinessLoss,
        effectAmount: 5,
        lesson: 'Social media recruitment (Facebook groups, LinkedIn) is free and effective in Zambia.',
      ),
      LifeEventChoice(
        label: 'Promote an internal candidate',
        description: 'Develop existing staff.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 8,
        lesson: 'Internal promotion boosts morale, reduces cost, and rewards loyalty.',
      ),
    ],
  ),
  LifeEvent(
    id: 14,
    category: LifeEventCategory.business,
    emoji: '🏛️',
    title: 'PACRA Annual Returns Due',
    narrative:
        'Your PACRA annual return filing is due. The fee is ZMW 150. '
        'Late filing incurs a ZMW 200 penalty.',
    choices: [
      LifeEventChoice(
        label: 'File and pay immediately',
        description: 'Stay compliant — it is worth it.',
        effect: LifeEventEffect.complianceGain,
        effectAmount: 34,
        lesson: 'PACRA compliance keeps your business legally recognised and protects you from closure orders.',
      ),
      LifeEventChoice(
        label: 'Defer until next week',
        description: 'You are busy — push it back.',
        effect: LifeEventEffect.complianceLoss,
        effectAmount: 10,
        lesson: 'Regulatory deadlines are non-negotiable. A compliance calendar prevents rushed filings.',
      ),
      LifeEventChoice(
        label: 'Use PACRA online portal',
        description: 'File digitally from your phone.',
        effect: LifeEventEffect.complianceGain,
        effectAmount: 34,
        lesson: 'PACRA\'s online portal makes filing easy. Digital tools save time and reduce errors.',
      ),
    ],
  ),
  // ── HEALTH ───────────────────────────────────────────────────────────────
  LifeEvent(
    id: 15,
    category: LifeEventCategory.health,
    emoji: '🏥',
    title: 'Malaria Strike',
    narrative:
        'You wake up with fever, joint pain, and a positive malaria test. '
        'Treatment at the clinic costs ZMW 180.',
    choices: [
      LifeEventChoice(
        label: 'Seek treatment immediately',
        description: 'Pay for proper medication.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 180,
        lesson: 'Delayed malaria treatment leads to cerebral malaria — always seek care within 24 hours.',
      ),
      LifeEventChoice(
        label: 'Use NHIMA at UTH',
        description: 'Use your health insurance cover.',
        effect: LifeEventEffect.healthGain,
        effectAmount: 10,
        lesson: 'NHIMA reduces out-of-pocket health costs dramatically. Register if you haven\'t.',
      ),
      LifeEventChoice(
        label: 'Self-medicate with painkillers',
        description: 'Buy painkillers and rest at home.',
        effect: LifeEventEffect.healthLoss,
        effectAmount: 15,
        lesson: 'Self-medication for malaria is dangerous. Artemisinin-based therapies require prescription.',
      ),
    ],
  ),
  LifeEvent(
    id: 16,
    category: LifeEventCategory.health,
    emoji: '🚶',
    title: 'Doctor Recommends Regular Exercise',
    narrative:
        'Your annual check-up reveals slightly high blood pressure. '
        'The doctor recommends 30 minutes of walking daily.',
    choices: [
      LifeEventChoice(
        label: 'Join a local running group',
        description: 'Free, social, and motivating.',
        effect: LifeEventEffect.healthGain,
        effectAmount: 10,
        lesson: 'Community exercise groups are free and build accountability. Health reduces medical costs.',
      ),
      LifeEventChoice(
        label: 'Ignore — you feel fine',
        description: 'Dismiss the advice.',
        effect: LifeEventEffect.healthLoss,
        effectAmount: 10,
        lesson: 'Prevention is 10x cheaper than cure. High blood pressure left untreated leads to stroke.',
      ),
      LifeEventChoice(
        label: 'Buy medication and skip exercise',
        description: 'Rely on pills instead of lifestyle change.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 150,
        lesson: 'Lifestyle intervention is more effective than medication for mild hypertension — and free.',
      ),
    ],
  ),
  LifeEvent(
    id: 17,
    category: LifeEventCategory.health,
    emoji: '🦷',
    title: 'Dental Emergency',
    narrative:
        'A severe toothache strikes on a Friday afternoon. The dentist quotes ZMW 350 for extraction.',
    choices: [
      LifeEventChoice(
        label: 'Pay and get it fixed',
        description: 'End the pain and prevent infection.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 350,
        lesson: 'Dental emergencies cost 5x more when delayed. Annual check-ups catch problems early.',
      ),
      LifeEventChoice(
        label: 'Use painkillers until Monday',
        description: 'Wait for public hospital rates.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 50,
        lesson: 'Public dental services cost less but have queues. Emergency funds bridge the gap.',
      ),
      LifeEventChoice(
        label: 'Visit UTH dental clinic',
        description: 'Access subsidised public dental care.',
        effect: LifeEventEffect.healthGain,
        effectAmount: 5,
        lesson: 'Public health facilities provide essential services at low cost. Know where they are.',
      ),
    ],
  ),
  // ── COMMUNITY ────────────────────────────────────────────────────────────
  LifeEvent(
    id: 18,
    category: LifeEventCategory.community,
    emoji: '⚰️',
    title: 'Funeral Contribution Request',
    narrative:
        'A colleague\'s parent has passed. The fundraising group is asking '
        'for ZMW 100 per member.',
    choices: [
      LifeEventChoice(
        label: 'Contribute ZMW 100',
        description: 'Support your community.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 100,
        lesson: 'Social contributions are an informal safety net in Zambia. Budget ZMW 100–200/month for community support.',
      ),
      LifeEventChoice(
        label: 'Contribute ZMW 50 — what you can',
        description: 'Give within your means.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 50,
        lesson: 'Honest partial contributions are respected. Overgiving leads to resentment and debt.',
      ),
      LifeEventChoice(
        label: 'Join a burial society instead',
        description: 'Formalise community support through a burial society.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 8,
        lesson: 'Burial societies pool resources systematically, reducing per-person burden during grief.',
      ),
    ],
  ),
  LifeEvent(
    id: 19,
    category: LifeEventCategory.community,
    emoji: '🌧️',
    title: 'Neighbourhood Flooding',
    narrative:
        'Heavy rains flood nearby streets. Three neighbours need temporary shelter. '
        'They ask to stay with you for a few days.',
    choices: [
      LifeEventChoice(
        label: 'Welcome them in',
        description: 'Offer shelter — it costs food and space.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 80,
        lesson: 'Community resilience is built through mutual aid. Your turn will come.',
      ),
      LifeEventChoice(
        label: 'Help them find a church shelter',
        description: 'Connect them to community resources.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 5,
        lesson: 'Knowing community resources — churches, Red Cross Zambia — creates safety nets without personal cost.',
      ),
      LifeEventChoice(
        label: 'Decline — no space',
        description: 'Prioritise your family\'s comfort.',
        effect: LifeEventEffect.happinessLoss,
        effectAmount: 5,
        lesson: 'Setting boundaries is valid. Knowing your capacity prevents burnout and resentment.',
      ),
    ],
  ),
  LifeEvent(
    id: 20,
    category: LifeEventCategory.community,
    emoji: '🗳️',
    title: 'Ward Development Fund',
    narrative:
        'Your ward councillor proposes a community development fund — ZMW 50/household '
        'to tar the road to your area.',
    choices: [
      LifeEventChoice(
        label: 'Contribute and attend the meeting',
        description: 'Invest in local infrastructure.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 50,
        lesson: 'Community infrastructure increases property values and quality of life. Participation matters.',
      ),
      LifeEventChoice(
        label: 'Ask for a council accountability report first',
        description: 'Demand transparency before contributing.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 5,
        lesson: 'Citizens have a right to ask how community funds are managed. Accountability prevents misuse.',
      ),
      LifeEventChoice(
        label: 'Free-ride — let others contribute',
        description: 'Benefit without contributing.',
        effect: LifeEventEffect.happinessLoss,
        effectAmount: 3,
        lesson: 'Free-riding erodes trust and weakens communities. Collective action requires participation.',
      ),
    ],
  ),
  LifeEvent(
    id: 21,
    category: LifeEventCategory.community,
    emoji: '🎓',
    title: 'Cousin Needs University Fee Help',
    narrative:
        'Your cousin passed university entry but cannot afford the ZMW 400 '
        'first semester fee. They ask you for help.',
    choices: [
      LifeEventChoice(
        label: 'Lend the money — they will pay back',
        description: 'Support education with a loan agreement.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 400,
        lesson: 'Lending to family works best with written agreements and realistic repayment timelines.',
      ),
      LifeEventChoice(
        label: 'Help apply for a HELSB loan',
        description: 'Guide them to the Higher Education Loans Board.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 10,
        lesson: 'HELSB provides government student loans in Zambia. Direct family to formal support first.',
      ),
      LifeEventChoice(
        label: 'Decline — you cannot afford it',
        description: 'Protect your financial position.',
        effect: LifeEventEffect.happinessLoss,
        effectAmount: 5,
        lesson: 'Financial boundaries with family are healthy. Your own stability comes first.',
      ),
    ],
  ),
  // ── MORE FINANCIAL ────────────────────────────────────────────────────────
  LifeEvent(
    id: 22,
    category: LifeEventCategory.financial,
    emoji: '📱',
    title: 'Phone Stolen at Market',
    narrative:
        'Your smartphone is snatched at Soweto market. Replacement cost: ZMW 800.',
    choices: [
      LifeEventChoice(
        label: 'Buy a new smartphone',
        description: 'Maintain productivity at full cost.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 800,
        lesson: 'Device insurance (ZMW 20/month) covers theft. Emergency funds prevent borrowing.',
      ),
      LifeEventChoice(
        label: 'Buy a basic feature phone for now',
        description: 'Spend ZMW 150 and rebuild later.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 150,
        lesson: 'Phased replacement is smart financial behaviour. Core function over premium features.',
      ),
      LifeEventChoice(
        label: 'Report theft and check insurance',
        description: 'Verify if your mobile money or bank covers theft.',
        effect: LifeEventEffect.walletGain,
        effectAmount: 300,
        lesson: 'Some Zambian banks offer mobile device protection. Always read your account benefits.',
      ),
    ],
  ),
  LifeEvent(
    id: 23,
    category: LifeEventCategory.financial,
    emoji: '🛵',
    title: 'Transport Strike',
    narrative:
        'Minibus operators strike for 3 days. Your commute now costs ZMW 40/day '
        'in taxi fares instead of ZMW 10.',
    choices: [
      LifeEventChoice(
        label: 'Absorb the extra cost',
        description: 'Pay taxis and continue working.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 90,
        lesson: 'Transport disruptions are recurring. A transport contingency fund prevents budget disruption.',
      ),
      LifeEventChoice(
        label: 'Work from home for 2 days',
        description: 'Avoid the commute cost entirely.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 5,
        lesson: 'Flexible work arrangements have real financial value. Negotiate them as part of employment.',
      ),
      LifeEventChoice(
        label: 'Carpool with a neighbour',
        description: 'Split taxi costs and save half.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 45,
        lesson: 'Carpooling reduces transport costs by 50%. Community solutions solve shared problems.',
      ),
    ],
  ),
  LifeEvent(
    id: 24,
    category: LifeEventCategory.financial,
    emoji: '💰',
    title: 'NAPSA Payout Notice',
    narrative:
        'You receive a letter from NAPSA — you are eligible for a partial benefit '
        'payout of ZMW 1,200 from contributions.',
    choices: [
      LifeEventChoice(
        label: 'Reinvest into a fixed deposit',
        description: 'Let money grow at 8% per annum.',
        effect: LifeEventEffect.walletGain,
        effectAmount: 1200,
        lesson: 'NAPSA payouts should be saved or invested — not spent on consumption. Compound growth is powerful.',
      ),
      LifeEventChoice(
        label: 'Pay off outstanding debt',
        description: 'Eliminate high-interest obligations first.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 15,
        lesson: 'Paying debt with windfalls is almost always the highest-return action available.',
      ),
      LifeEventChoice(
        label: 'Splurge on new furniture',
        description: 'Reward yourself after years of contributions.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 5,
        lesson: 'One-time windfalls rarely justify consumption. Long-term wealth requires investment discipline.',
      ),
    ],
  ),
  // ── MORE BUSINESS ─────────────────────────────────────────────────────────
  LifeEvent(
    id: 25,
    category: LifeEventCategory.business,
    emoji: '🔥',
    title: 'Competitor Opens Nearby',
    narrative:
        'A well-funded competitor opens 200 metres from your business. '
        'Sales drop 20% in the first week.',
    choices: [
      LifeEventChoice(
        label: 'Differentiate — focus on service quality',
        description: 'Compete on experience, not price.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 8,
        lesson: 'Competing on service quality and customer relationships outlasts price wars.',
      ),
      LifeEventChoice(
        label: 'Match their prices',
        description: 'Enter a price war.',
        effect: LifeEventEffect.walletLoss,
        effectAmount: 200,
        lesson: 'Price wars destroy margins for both sides. Only the customer wins. Differentiate instead.',
      ),
      LifeEventChoice(
        label: 'Partner with them on bulk orders',
        description: 'Collaborate rather than compete.',
        effect: LifeEventEffect.walletGain,
        effectAmount: 150,
        lesson: 'Co-opetition — cooperating with competitors — can create mutual benefits and larger markets.',
      ),
    ],
  ),
  LifeEvent(
    id: 26,
    category: LifeEventCategory.business,
    emoji: '📊',
    title: 'Bank Loan Approved',
    narrative:
        'Your application for a ZMW 5,000 business loan is approved at 18% p.a. '
        'Monthly repayments of ZMW 500 for 12 months.',
    choices: [
      LifeEventChoice(
        label: 'Invest in stock and equipment',
        description: 'Use funds productively to grow revenue.',
        effect: LifeEventEffect.walletGain,
        effectAmount: 300,
        lesson: 'Productive debt — borrowing to generate more income — is healthy. Consumer debt is not.',
      ),
      LifeEventChoice(
        label: 'Use it as working capital buffer',
        description: 'Keep cash flow smooth during slow months.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 10,
        lesson: 'A cash flow buffer reduces business stress and allows strategic decisions instead of reactive ones.',
      ),
      LifeEventChoice(
        label: 'Decline — fear of debt',
        description: 'Avoid all borrowing.',
        effect: LifeEventEffect.happinessLoss,
        effectAmount: 5,
        lesson: 'Not all debt is bad. Debt at lower interest than your business ROI creates wealth.',
      ),
    ],
  ),
  LifeEvent(
    id: 27,
    category: LifeEventCategory.business,
    emoji: '🌍',
    title: 'Export Opportunity',
    narrative:
        'A buyer from Zimbabwe wants to order ZMW 3,000 worth of your products. '
        'But you need to handle cross-border documentation.',
    choices: [
      LifeEventChoice(
        label: 'Accept and hire a clearing agent',
        description: 'Pay ZMW 200 for expert documentation help.',
        effect: LifeEventEffect.walletGain,
        effectAmount: 2800,
        lesson: 'Export markets dramatically increase business scale. Clearing agents handle COMESA paperwork.',
      ),
      LifeEventChoice(
        label: 'Decline — too complex for now',
        description: 'Focus on the domestic market.',
        effect: LifeEventEffect.happinessLoss,
        effectAmount: 3,
        lesson: 'COMESA trade agreements make cross-border trade simpler than perceived. Research before declining.',
      ),
      LifeEventChoice(
        label: 'Visit ZEMA and ZABS for guidance',
        description: 'Get free export advisory from government agencies.',
        effect: LifeEventEffect.complianceGain,
        effectAmount: 10,
        lesson: 'ZEMA and ZABS offer free export guidance to Zambian SMEs. Use public resources.',
      ),
    ],
  ),
  // ── MORE HEALTH & COMMUNITY ───────────────────────────────────────────────
  LifeEvent(
    id: 28,
    category: LifeEventCategory.health,
    emoji: '🧘',
    title: 'Work-Life Balance Crisis',
    narrative:
        'You have worked 14-hour days for 3 weeks. You feel exhausted, irritable, '
        'and unable to concentrate.',
    choices: [
      LifeEventChoice(
        label: 'Take a 3-day rest',
        description: 'Prioritise recovery over productivity.',
        effect: LifeEventEffect.healthGain,
        effectAmount: 15,
        lesson: 'Rest is productive. Burnout costs far more in lost output than a short break.',
      ),
      LifeEventChoice(
        label: 'Delegate tasks to your team',
        description: 'Develop others while protecting yourself.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 10,
        lesson: 'Delegation builds team capacity and is essential for business scalability.',
      ),
      LifeEventChoice(
        label: 'Push through — the business needs you',
        description: 'Sacrifice your wellbeing for the business.',
        effect: LifeEventEffect.healthLoss,
        effectAmount: 15,
        lesson: 'No business is worth your health. Owner burnout is the #1 cause of SME failure.',
      ),
    ],
  ),
  LifeEvent(
    id: 29,
    category: LifeEventCategory.community,
    emoji: '🌱',
    title: 'Urban Farming Collective',
    narrative:
        'Neighbours invite you to join a community vegetable garden. '
        'It costs ZMW 50 to join and 2 hours per week.',
    choices: [
      LifeEventChoice(
        label: 'Join the collective',
        description: 'Reduce food costs and build community ties.',
        effect: LifeEventEffect.walletGain,
        effectAmount: 100,
        lesson: 'Community food gardens reduce household food budgets by ZMW 100–300/month in urban Zambia.',
      ),
      LifeEventChoice(
        label: 'Start your own home garden',
        description: 'Grow vegetables independently at home.',
        effect: LifeEventEffect.happinessGain,
        effectAmount: 8,
        lesson: 'Even a small home garden cuts food costs. Tomatoes, rape, and beans thrive in Zambia.',
      ),
      LifeEventChoice(
        label: 'Decline — no time',
        description: 'Keep your schedule clear.',
        effect: LifeEventEffect.none,
        effectAmount: 0,
        lesson: 'Time is a resource. Evaluate each community commitment by its financial and social return.',
      ),
    ],
  ),
];
