// lib/features/mini_games/data/mini_game_data.dart

class ExpenseCard {
  final String label;
  final double amount;
  final bool isNeed; // true = Need, false = Want

  const ExpenseCard({
    required this.label,
    required this.amount,
    required this.isNeed,
  });
}

class FlipPair {
  final String term;
  final String definition;
  final String id;

  const FlipPair({required this.term, required this.definition, required this.id});
}

// 5 rounds of Budget Blitz (5 cards each)
const List<List<ExpenseCard>> kBudgetBlitzRounds = [
  [
    ExpenseCard(label: 'Rent', amount: 2500, isNeed: true),
    ExpenseCard(label: 'Airtime', amount: 50, isNeed: false),
    ExpenseCard(label: 'Groceries', amount: 800, isNeed: true),
    ExpenseCard(label: 'ZESCO Bill', amount: 320, isNeed: true),
    ExpenseCard(label: 'Netflix', amount: 120, isNeed: false),
  ],
  [
    ExpenseCard(label: 'School Fees', amount: 1200, isNeed: true),
    ExpenseCard(label: 'New Shoes', amount: 450, isNeed: false),
    ExpenseCard(label: 'Water Bill', amount: 180, isNeed: true),
    ExpenseCard(label: 'Restaurant', amount: 350, isNeed: false),
    ExpenseCard(label: 'Medicine', amount: 200, isNeed: true),
  ],
  [
    ExpenseCard(label: 'Transport', amount: 600, isNeed: true),
    ExpenseCard(label: 'Hair Salon', amount: 250, isNeed: false),
    ExpenseCard(label: 'Food Market', amount: 950, isNeed: true),
    ExpenseCard(label: 'Mobile Data', amount: 100, isNeed: true),
    ExpenseCard(label: 'Gym Membership', amount: 300, isNeed: false),
  ],
  [
    ExpenseCard(label: 'Medical Insurance', amount: 400, isNeed: true),
    ExpenseCard(label: 'Movie Tickets', amount: 150, isNeed: false),
    ExpenseCard(label: 'Charcoal', amount: 80, isNeed: true),
    ExpenseCard(label: 'Designer Bag', amount: 1800, isNeed: false),
    ExpenseCard(label: 'Internet Bill', amount: 220, isNeed: true),
  ],
  [
    ExpenseCard(label: 'Nshima & Relish', amount: 120, isNeed: true),
    ExpenseCard(label: 'Cigarettes', amount: 90, isNeed: false),
    ExpenseCard(label: 'Loan Repayment', amount: 700, isNeed: true),
    ExpenseCard(label: 'Evening Out', amount: 500, isNeed: false),
    ExpenseCard(label: 'Zamtel SIM', amount: 50, isNeed: true),
  ],
];

// 8 Investment Flip pairs
const List<FlipPair> kInvestmentFlipPairs = [
  FlipPair(id: 'compound', term: 'Compound Interest', definition: 'Interest on interest — earnings grow exponentially'),
  FlipPair(id: 'inflation', term: 'Inflation', definition: 'General rise in prices, reducing purchasing power'),
  FlipPair(id: 'diversify', term: 'Diversification', definition: 'Spreading investments to reduce risk'),
  FlipPair(id: 'liquidity', term: 'Liquidity', definition: 'How quickly an asset can be converted to cash'),
  FlipPair(id: 'amortize', term: 'Amortization', definition: 'Paying off debt in regular installments over time'),
  FlipPair(id: 'bull', term: 'Bull Market', definition: 'A rising stock market with investor confidence'),
  FlipPair(id: 'bear', term: 'Bear Market', definition: 'A falling stock market with widespread pessimism'),
  FlipPair(id: 'networth', term: 'Net Worth', definition: 'Total assets minus total liabilities'),
];
