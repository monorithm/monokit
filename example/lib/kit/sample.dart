import 'package:flutter/widgets.dart';
import 'package:monokit/monokit.dart';

import 'availability.dart';

/// Marketplace-flavoured sample data (Ghana). Keeps every demo in the product's
/// world — GH₵ prices, Accra locations, real-sounding posts — without being the
/// app. Real photography would live in `assets/`; here we render tasteful
/// gradient placeholders on the always-dark media canvas.

class Person {
  const Person(this.name, this.initials);
  final String name;
  final String initials;
}

const abbas = Person('Abbas Mohammed', 'AB');
const esi = Person('Esi Addo', 'EA');
const yaa = Person('Yaa Boateng', 'YB');

class FeedPost {
  const FeedPost({
    required this.title,
    required this.price,
    required this.location,
    required this.ageLabel,
    required this.reason,
    required this.condition,
    required this.seed,
    required this.seller,
    required this.description,
    this.wasPrice,
    this.availability = DemoAvailability.available,
    this.isLive = false,
  });

  final String title;
  final String price;
  final String? wasPrice;
  final String location;
  final String ageLabel;
  final String reason;
  final String condition;
  final int seed;
  final Person seller;
  final String description;
  final DemoAvailability availability;
  final bool isLive;

  Widget get media => SamplePhoto(seed: seed);
  Widget get thumb => SamplePhoto(seed: seed);
}

class Constraint {
  const Constraint(this.label, this.value);
  final String label;
  final String value;
}

class ThreadMessage {
  ThreadMessage({
    required this.text,
    required this.mine,
    this.receipt = MonoReceiptState.read,
    this.attachmentSeed,
  });

  factory ThreadMessage.mine(String text, MonoReceiptState receipt) =>
      ThreadMessage(text: text, mine: true, receipt: receipt);

  final String text;
  final bool mine;
  final MonoReceiptState receipt;
  final int? attachmentSeed;

  Widget? get attachment =>
      attachmentSeed == null ? null : SamplePhoto(seed: attachmentSeed!);
}

const List<FeedPost> sampleFeed = <FeedPost>[
  FeedPost(
    title: 'iPhone 13 · 128GB',
    price: 'GH₵ 4,800',
    wasPrice: 'GH₵ 5,400',
    location: 'Nima',
    ageLabel: '10 min ago',
    reason: 'Matches your search',
    condition: 'used',
    seed: 1,
    seller: abbas,
    description:
        'Clean iPhone 13, 128GB, battery health 89%. Comes with case and '
        'charger. Slight scratch on the frame, screen is flawless. Meet at '
        'Nima or I can deliver within Accra.',
  ),
  FeedPost(
    title: 'Home-cooked waakye · daily',
    price: 'GH₵ 25',
    location: 'Accra Central',
    ageLabel: '2 min ago',
    reason: 'Delivers to you',
    condition: 'new',
    seed: 2,
    seller: yaa,
    isLive: true,
    description:
        'Fresh waakye with all the sides. Delivering across Accra '
        'Central until 2pm. Message to reserve a plate.',
  ),
  FeedPost(
    title: 'Looking for: used baby stroller',
    price: 'Budget GH₵ 300',
    location: 'East Legon',
    ageLabel: '1 hr ago',
    reason: 'Nearby request',
    condition: 'used',
    seed: 3,
    seller: esi,
    availability: DemoAvailability.reserved,
    description:
        'Need a foldable stroller in good condition for a 6-month-old. '
        'Can pick up around East Legon this weekend.',
  ),
];

List<Constraint> parseConstraints(String query) {
  final q = query.toLowerCase();
  final constraints = <Constraint>[];
  if (q.contains('iphone') || q.contains('phone')) {
    constraints.add(const Constraint('Category', 'Phones'));
  }
  final priceMatch = RegExp(r'(\d[\d,]{2,})').firstMatch(q.replaceAll(' ', ''));
  if (q.contains('under') && priceMatch != null) {
    constraints.add(Constraint('Under', 'GH₵ ${priceMatch.group(1)}'));
  }
  if (q.contains('used') || q.contains('fairly used')) {
    constraints.add(const Constraint('Condition', 'Used'));
  }
  for (final place in const ['Accra', 'Nima', 'East Legon', 'Tema']) {
    if (q.contains(place.toLowerCase())) {
      constraints.add(Constraint('Location', place));
    }
  }
  return constraints;
}

List<FeedPost> searchSample(List<Constraint> constraints) {
  if (constraints.any((c) => c.value == 'GH₵ 000')) return const <FeedPost>[];
  final wantsPhones = constraints.any((c) => c.value == 'Phones');
  if (wantsPhones) {
    return sampleFeed.where((p) => p.title.contains('iPhone')).toList();
  }
  return sampleFeed;
}

List<ThreadMessage> sampleThread() => <ThreadMessage>[
  ThreadMessage(text: 'Hi! Is the iPhone still available?', mine: false),
  ThreadMessage.mine('Yes it is — clean 128GB.', MonoReceiptState.read),
  ThreadMessage(text: 'Great. Can you do GH₵ 4,500?', mine: false),
  ThreadMessage.mine(
    'I can do 4,700. Here is a photo of the back.',
    MonoReceiptState.delivered,
  ),
  ThreadMessage(
    text: 'Looks good. Where can we meet?',
    mine: false,
    attachmentSeed: 1,
  ),
];

/// A gradient placeholder standing in for real photography on the media canvas.
class SamplePhoto extends StatelessWidget {
  const SamplePhoto({super.key, required this.seed});
  final int seed;

  static const List<List<Color>> _gradients = <List<Color>>[
    <Color>[Color(0xFF0B3D2E), Color(0xFF041413)],
    <Color>[Color(0xFF14312B), Color(0xFF0A1A17)],
    <Color>[Color(0xFF1B2A33), Color(0xFF0A1114)],
    <Color>[Color(0xFF2A2320), Color(0xFF120E0C)],
  ];

  @override
  Widget build(BuildContext context) {
    final colors = _gradients[seed % _gradients.length];
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: const Center(
        child: MonoIcon(MonoIcons.image, size: 28, color: Color(0x33FFFFFF)),
      ),
    );
  }
}
