/// challenge.dart
/// Purpose: Immutable static data model for Daily Challenge questions.
///          Defines [ChallengeType], [DailyChallenge], and the canonical list
///          [kDailyChallenges] of 30 Zambia-focused financial literacy questions.
/// Reads from: nothing (pure static data — never persisted)
/// Writes to: nothing
/// Navigation: none
library;

// ─────────────────────────────────────────────────────────────────────────────
// Types
// ─────────────────────────────────────────────────────────────────────────────

/// Determines which input widget the challenge screen renders.
enum ChallengeType { multipleChoice, trueFalse, numeric }

/// Immutable descriptor for a single daily challenge question.
class DailyChallenge {
  const DailyChallenge({
    required this.id,
    required this.question,
    required this.type,
    required this.options,
    required this.correctIndex,
    required this.correctNumeric,
    required this.numericTolerance,
    required this.explanation,
    required this.topic,
  });

  final String id;
  final String question;
  final ChallengeType type;

  /// Answer options — empty list for [ChallengeType.numeric].
  final List<String> options;

  /// Index of the correct option; -1 for [ChallengeType.numeric].
  final int correctIndex;

  /// Correct numeric answer; 0 for non-numeric types.
  final double correctNumeric;

  /// Accepted margin of error for numeric answers.
  final double numericTolerance;

  /// Explanation shown after the player submits their answer.
  final String explanation;

  /// Topic label displayed as a chip on the challenge card (e.g. 'Budgeting').
  final String topic;
}

// ─────────────────────────────────────────────────────────────────────────────
// Challenge Bank — 30 questions
// ─────────────────────────────────────────────────────────────────────────────

const List<DailyChallenge> kDailyChallenges = [

  // ── Budgeting ──────────────────────────────────────────────────────────────
  DailyChallenge(
    id: 'dc_001',
    question:
        'You earn ZMW 3,500 per month. Financial experts recommend spending no more than 30% on rent. What is the maximum rent you should pay?',
    type: ChallengeType.numeric,
    options: [],
    correctIndex: -1,
    correctNumeric: 1050,
    numericTolerance: 10,
    explanation:
        '30% of ZMW 3,500 = ZMW 1,050. Keeping rent at or below this leaves room for food, transport, savings, and emergencies.',
    topic: 'Budgeting',
  ),

  DailyChallenge(
    id: 'dc_002',
    question:
        'Which of the following is the BEST first step when you receive your monthly salary?',
    type: ChallengeType.multipleChoice,
    options: [
      'Pay for leisure and entertainment first',
      'Transfer your savings amount before spending anything else',
      'Wait until the end of the month to see what is left over',
      'Pay the largest bill first regardless of due date',
    ],
    correctIndex: 1,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        '"Pay yourself first" means transferring savings immediately on payday before any discretionary spending. This is the foundation of every successful savings plan.',
    topic: 'Budgeting',
  ),

  DailyChallenge(
    id: 'dc_003',
    question:
        'A household spends ZMW 800 on food, ZMW 1,200 on rent, ZMW 300 on transport, and ZMW 200 on airtime. Their income is ZMW 3,500. How much remains for savings?',
    type: ChallengeType.numeric,
    options: [],
    correctIndex: -1,
    correctNumeric: 1000,
    numericTolerance: 5,
    explanation:
        'Total expenses: 800 + 1,200 + 300 + 200 = ZMW 2,500. Remaining: 3,500 − 2,500 = ZMW 1,000. Ideally, this entire amount should be saved or invested.',
    topic: 'Budgeting',
  ),

  DailyChallenge(
    id: 'dc_004',
    question:
        'True or False: An emergency fund should cover at least 3 months of your essential living expenses.',
    type: ChallengeType.trueFalse,
    options: ['True', 'False'],
    correctIndex: 0,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'True. Financial advisors recommend 3–6 months of essential expenses in an emergency fund. This covers job loss, medical emergencies, or unexpected repairs without going into debt.',
    topic: 'Budgeting',
  ),

  // ── Mobile Money ───────────────────────────────────────────────────────────
  DailyChallenge(
    id: 'dc_005',
    question:
        'You send ZMW 500 via MTN MoMo every week for a year. The fee per transaction is ZMW 8. How much do you pay in fees over 52 weeks?',
    type: ChallengeType.numeric,
    options: [],
    correctIndex: -1,
    correctNumeric: 416,
    numericTolerance: 5,
    explanation:
        'ZMW 8 × 52 weeks = ZMW 416 per year in fees alone. Batching transactions into larger, less frequent transfers can significantly reduce this cost.',
    topic: 'Mobile Money',
  ),

  DailyChallenge(
    id: 'dc_006',
    question: 'Which strategy BEST reduces your annual Mobile Money fees?',
    type: ChallengeType.multipleChoice,
    options: [
      'Send money more frequently in smaller amounts',
      'Always use the maximum transaction limit',
      'Batch small payments into fewer, larger transactions',
      'Switch networks every month to get new-user promotions',
    ],
    correctIndex: 2,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'Mobile Money fees are typically charged per transaction, not as a percentage of amount. Sending ZMW 1,000 once costs far less in fees than sending ZMW 250 four times.',
    topic: 'Mobile Money',
  ),

  DailyChallenge(
    id: 'dc_007',
    question:
        'True or False: Keeping large sums of money in your Mobile Money wallet long-term is as safe and beneficial as a bank savings account.',
    type: ChallengeType.trueFalse,
    options: ['True', 'False'],
    correctIndex: 1,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'False. Mobile Money wallets generally earn no interest and offer less regulatory protection than a formal bank savings account. For long-term savings, a bank account or investment product is more appropriate.',
    topic: 'Mobile Money',
  ),

  // ── Savings & Compound Interest ────────────────────────────────────────────
  DailyChallenge(
    id: 'dc_008',
    question:
        'You save ZMW 200 per month for 12 months with no interest. How much do you have at the end of the year?',
    type: ChallengeType.numeric,
    options: [],
    correctIndex: -1,
    correctNumeric: 2400,
    numericTolerance: 0,
    explanation:
        'ZMW 200 × 12 months = ZMW 2,400. This is a linear savings calculation with no compound interest. Adding even a modest interest rate would grow this further.',
    topic: 'Savings',
  ),

  DailyChallenge(
    id: 'dc_009',
    question: 'Which of the following BEST describes compound interest?',
    type: ChallengeType.multipleChoice,
    options: [
      'Interest calculated only on the original principal each year',
      'A fixed fee charged by banks for holding your money',
      'Interest calculated on both the principal and previously earned interest',
      'The government tax on savings account earnings',
    ],
    correctIndex: 2,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'Compound interest means you earn interest on your interest. Over time this creates exponential growth — the core reason starting to save early makes such a large difference.',
    topic: 'Savings',
  ),

  DailyChallenge(
    id: 'dc_010',
    question:
        'Using the Rule of 72, approximately how many years does it take to double ZMW 1,000 at a 12% annual interest rate?',
    type: ChallengeType.numeric,
    options: [],
    correctIndex: -1,
    correctNumeric: 6,
    numericTolerance: 0.5,
    explanation:
        'Rule of 72: divide 72 by the interest rate. 72 ÷ 12 = 6 years. This quick mental calculation is a useful tool for comparing investment options.',
    topic: 'Savings',
  ),

  // ── Inflation ──────────────────────────────────────────────────────────────
  DailyChallenge(
    id: 'dc_011',
    question:
        'Zambia\'s annual inflation rate is approximately 12%. If a bag of mealie meal costs ZMW 150 today, approximately how much will it cost in one year?',
    type: ChallengeType.numeric,
    options: [],
    correctIndex: -1,
    correctNumeric: 168,
    numericTolerance: 2,
    explanation:
        'ZMW 150 × 1.12 = ZMW 168. This is why keeping money under a mattress or in a zero-interest wallet slowly destroys its purchasing power.',
    topic: 'Inflation',
  ),

  DailyChallenge(
    id: 'dc_012',
    question:
        'True or False: If your salary increases by 8% but inflation is 12%, your real purchasing power has increased.',
    type: ChallengeType.trueFalse,
    options: ['True', 'False'],
    correctIndex: 1,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'False. Your real purchasing power has DECREASED by approximately 4%. A salary increase only improves your standard of living if it exceeds the rate of inflation.',
    topic: 'Inflation',
  ),

  DailyChallenge(
    id: 'dc_013',
    question:
        'Which of the following is the BEST protection against inflation eroding your savings?',
    type: ChallengeType.multipleChoice,
    options: [
      'Keeping cash at home in a safe',
      'Spending all your money immediately before prices rise',
      'Investing in assets that grow at or above the inflation rate',
      'Borrowing money to buy consumer goods',
    ],
    correctIndex: 2,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'Assets such as property, stocks, or a well-run business tend to grow in value alongside or above inflation, preserving and growing your purchasing power over time.',
    topic: 'Inflation',
  ),

  // ── Debt ───────────────────────────────────────────────────────────────────
  DailyChallenge(
    id: 'dc_014',
    question:
        'You borrow ZMW 5,000 at 20% annual interest. How much interest do you owe after one year if you make no payments?',
    type: ChallengeType.numeric,
    options: [],
    correctIndex: -1,
    correctNumeric: 1000,
    numericTolerance: 5,
    explanation:
        'ZMW 5,000 × 20% = ZMW 1,000 in interest for one year. This means you would owe ZMW 6,000 at the end of the year if you made no payments.',
    topic: 'Debt',
  ),

  DailyChallenge(
    id: 'dc_015',
    question: 'Which repayment strategy saves the MOST total interest on a loan?',
    type: ChallengeType.multipleChoice,
    options: [
      'Pay only the minimum required amount each month',
      'Pay as much as you can afford each month above the minimum',
      'Skip payments when money is tight and pay double later',
      'Take a new loan to pay off the old one',
    ],
    correctIndex: 1,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'Paying more than the minimum reduces the principal faster, which reduces the interest charged in subsequent months. This is called aggressive repayment and can save thousands of Kwacha on large loans.',
    topic: 'Debt',
  ),

  DailyChallenge(
    id: 'dc_016',
    question:
        'True or False: Having a good credit history in Zambia can help you access lower interest rates on future loans.',
    type: ChallengeType.trueFalse,
    options: ['True', 'False'],
    correctIndex: 0,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'True. Credit bureaus in Zambia (such as Compuscan) track your repayment history. A strong record of on-time payments signals lower risk to lenders, which can qualify you for better rates.',
    topic: 'Debt',
  ),

  // ── Tax & PAYE ─────────────────────────────────────────────────────────────
  DailyChallenge(
    id: 'dc_017',
    question: 'What does PAYE stand for in Zambia?',
    type: ChallengeType.multipleChoice,
    options: [
      'Pay As You Earn',
      'Personal Annual Yearly Expense',
      'Public Agency for Youth Employment',
      'Proportional Annual Year-End tax',
    ],
    correctIndex: 0,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'PAYE — Pay As You Earn — is Zambia\'s income tax system where employers deduct tax from employees\' salaries each month and remit it directly to the Zambia Revenue Authority (ZRA).',
    topic: 'Tax',
  ),

  DailyChallenge(
    id: 'dc_018',
    question:
        'What is Zambia\'s standard VAT (Value Added Tax) rate as of 2024?',
    type: ChallengeType.multipleChoice,
    options: ['10%', '12.5%', '16%', '20%'],
    correctIndex: 2,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'Zambia\'s standard VAT rate is 16%. It applies to most goods and services. Certain basic food items and essential medicines are zero-rated or exempt.',
    topic: 'Tax',
  ),

  DailyChallenge(
    id: 'dc_019',
    question:
        'True or False: Every formal business in Zambia must register for a TPIN (Taxpayer Identification Number) with the ZRA.',
    type: ChallengeType.trueFalse,
    options: ['True', 'False'],
    correctIndex: 0,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'True. A TPIN is mandatory for all registered businesses and is required to open a business bank account, file tax returns, and participate in formal procurement tenders.',
    topic: 'Tax',
  ),

  DailyChallenge(
    id: 'dc_020',
    question:
        'What is Zambia\'s corporate income tax rate for most businesses as of 2024?',
    type: ChallengeType.multipleChoice,
    options: ['25%', '30%', '35%', '40%'],
    correctIndex: 2,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'The standard corporate income tax rate in Zambia is 35%. Certain sectors such as farming and manufacturing may qualify for reduced rates under ZRA incentive programmes.',
    topic: 'Tax',
  ),

  // ── NAPSA ──────────────────────────────────────────────────────────────────
  DailyChallenge(
    id: 'dc_021',
    question:
        'What percentage of a Zambian employee\'s gross salary is deducted for NAPSA contributions?',
    type: ChallengeType.multipleChoice,
    options: ['3%', '5%', '8%', '10%'],
    correctIndex: 1,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'NAPSA deducts 5% from the employee\'s gross salary. The employer also contributes a matching 5%. Both contributions are capped at ZMW 1,221.80 per month each (2024 rate).',
    topic: 'NAPSA',
  ),

  DailyChallenge(
    id: 'dc_022',
    question:
        'An employee earns ZMW 6,000 per month gross. How much is their NAPSA contribution (employee share only)?',
    type: ChallengeType.numeric,
    options: [],
    correctIndex: -1,
    correctNumeric: 300,
    numericTolerance: 2,
    explanation:
        'ZMW 6,000 × 5% = ZMW 300. Since ZMW 300 is below the monthly cap of ZMW 1,221.80, the full 5% applies.',
    topic: 'NAPSA',
  ),

  DailyChallenge(
    id: 'dc_023',
    question:
        'True or False: NAPSA contributions can be accessed by an employee at any time they need cash.',
    type: ChallengeType.trueFalse,
    options: ['True', 'False'],
    correctIndex: 1,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'False. NAPSA is a pension fund. Contributions can only be accessed upon retirement, permanent emigration, or death. Early withdrawal is not permitted under normal circumstances.',
    topic: 'NAPSA',
  ),

  // ── PACRA & Business ───────────────────────────────────────────────────────
  DailyChallenge(
    id: 'dc_024',
    question: 'What does PACRA stand for in Zambia?',
    type: ChallengeType.multipleChoice,
    options: [
      'Patents and Companies Registration Agency',
      'Public Accounts and Credit Regulatory Authority',
      'Provincial Agency for Commercial and Retail Affairs',
      'Private Assets and Capital Reserve Administration',
    ],
    correctIndex: 0,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'PACRA — Patents and Companies Registration Agency — is the Zambian government body responsible for registering businesses, trademarks, and patents.',
    topic: 'Business',
  ),

  DailyChallenge(
    id: 'dc_025',
    question:
        'True or False: A sole trader (one-person business) in Zambia must register with PACRA before legally operating.',
    type: ChallengeType.trueFalse,
    options: ['True', 'False'],
    correctIndex: 0,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'True. Any business operating under a name other than the owner\'s personal name must be registered with PACRA. Operating without registration can result in fines and legal complications.',
    topic: 'Business',
  ),

  DailyChallenge(
    id: 'dc_026',
    question:
        'What is the difference between gross profit and net profit?',
    type: ChallengeType.multipleChoice,
    options: [
      'They are the same thing',
      'Gross profit subtracts all expenses including tax; net profit only subtracts cost of goods',
      'Gross profit subtracts cost of goods sold from revenue; net profit also subtracts operating expenses and tax',
      'Net profit is always higher than gross profit',
    ],
    correctIndex: 2,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'Gross profit = Revenue minus Cost of Goods Sold. Net profit = Gross profit minus operating expenses, interest, and tax. Net profit is what the business owner actually keeps.',
    topic: 'Business',
  ),

  // ── Investment ─────────────────────────────────────────────────────────────
  DailyChallenge(
    id: 'dc_027',
    question:
        'Which of the following BEST describes diversification in investing?',
    type: ChallengeType.multipleChoice,
    options: [
      'Putting all your money into the single best-performing asset',
      'Spreading investments across different asset types to reduce risk',
      'Investing only in government bonds for guaranteed returns',
      'Changing your investments every month based on market news',
    ],
    correctIndex: 1,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'Diversification means spreading your money across different assets (e.g. property, stocks, agriculture, savings). If one investment loses value, others may gain, reducing your overall risk.',
    topic: 'Investment',
  ),

  DailyChallenge(
    id: 'dc_028',
    question:
        'True or False: Higher potential returns on an investment always come with higher risk.',
    type: ChallengeType.trueFalse,
    options: ['True', 'False'],
    correctIndex: 0,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'True. This is the fundamental risk-return trade-off in finance. Government bonds offer low but near-certain returns. Stocks and agriculture offer higher potential returns but can also lose value.',
    topic: 'Investment',
  ),

  // ── Financial Mindset ──────────────────────────────────────────────────────
  DailyChallenge(
    id: 'dc_029',
    question:
        'You receive an unexpected ZMW 2,000 windfall. Which allocation is MOST financially sound?',
    type: ChallengeType.multipleChoice,
    options: [
      'Spend it all immediately on celebration — you earned it',
      'Put it all into a chilimba group',
      'Split it: 50% to emergency fund, 30% to debt repayment, 20% to leisure',
      'Lend it all to family members',
    ],
    correctIndex: 2,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'Splitting a windfall addresses multiple financial priorities at once: building your safety net, reducing debt cost, and allowing yourself a small reward. Lending all of it risks losing both the money and the relationship.',
    topic: 'Mindset',
  ),

  DailyChallenge(
    id: 'dc_030',
    question:
        'True or False: A chilimba (informal savings group) can be a valid and effective savings tool for Zambians.',
    type: ChallengeType.trueFalse,
    options: ['True', 'False'],
    correctIndex: 0,
    correctNumeric: 0,
    numericTolerance: 0,
    explanation:
        'True. Chilimba groups provide social accountability and enforce regular saving habits. While they carry trust-based risks, many Zambians successfully use them to save for school fees, furniture, and small business capital.',
    topic: 'Mindset',
  ),
];
