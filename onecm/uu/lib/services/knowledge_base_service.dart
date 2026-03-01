/// A bundled pediatric knowledge-base article.
class Article {
  final String id;
  final String title;
  final String category; // sleep, feeding, development, health, safety, behavior
  final String summary;
  final String content; // full article text
  final int minAgeMonths;
  final int maxAgeMonths;
  final List<String> tags;

  const Article({
    required this.id,
    required this.title,
    required this.category,
    required this.summary,
    required this.content,
    required this.minAgeMonths,
    required this.maxAgeMonths,
    required this.tags,
  });
}

/// Pure logic service for the pediatric knowledge base.
///
/// Provides a pre-populated library of evidence-based parenting articles
/// across six categories: Sleep, Feeding, Development, Health, Safety,
/// and Behavior, covering ages 0-36 months. Supports search and filtering.
class KnowledgeBaseService {
  /// Return every bundled article.
  List<Article> getAllArticles() => _allArticles;

  /// Look up a single article by its unique [id]. Returns `null` if not found.
  Article? getArticleById(String id) {
    for (final a in _allArticles) {
      if (a.id == id) return a;
    }
    return null;
  }

  /// Return articles belonging to a single [category].
  List<Article> getArticlesByCategory(String category) {
    return _allArticles.where((a) => a.category == category).toList();
  }

  /// Return articles whose age range includes [ageMonths].
  List<Article> getArticlesForAge(int ageMonths) {
    return _allArticles.where((a) {
      return a.minAgeMonths <= ageMonths && a.maxAgeMonths >= ageMonths;
    }).toList();
  }

  /// Full-text search across title, summary, content, and tags.
  /// Returns an empty list for an empty [query].
  List<Article> searchArticles(String query) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    return _allArticles.where((a) {
      return a.title.toLowerCase().contains(q) ||
          a.summary.toLowerCase().contains(q) ||
          a.content.toLowerCase().contains(q) ||
          a.tags.any((t) => t.toLowerCase().contains(q));
    }).toList();
  }

  // ── Pre-populated article data ──────────────────────────────────────

  static const _allArticles = <Article>[
    // ── Sleep (4 articles) ──
    Article(
      id: 'sleep-safe-practices',
      title: 'Safe Sleep Practices for Newborns',
      category: 'sleep',
      summary:
          'Evidence-based guidelines to reduce SIDS risk and create a safe '
          'sleeping environment for your newborn.',
      content:
          'The American Academy of Pediatrics recommends that babies always '
          'be placed on their backs to sleep, on a firm, flat surface with no '
          'loose bedding, pillows, or stuffed animals. Room-sharing without '
          'bed-sharing is recommended for at least the first six months. Keep '
          'the room at a comfortable temperature and dress your baby in a '
          'sleep sack instead of blankets. Avoid products marketed as sleep '
          'positioners. Pacifier use at nap time and bedtime has been '
          'associated with a reduced risk of SIDS. Always ensure the crib '
          'meets current safety standards.',
      minAgeMonths: 0,
      maxAgeMonths: 3,
      tags: ['sids', 'safe sleep', 'newborn', 'crib safety', 'back to sleep'],
    ),
    Article(
      id: 'sleep-training-methods',
      title: 'Sleep Training Methods',
      category: 'sleep',
      summary:
          'An overview of gentle and structured sleep training approaches '
          'for babies who are developmentally ready.',
      content:
          'Sleep training can begin when your baby is around four to six '
          'months old and no longer needs nighttime feedings (consult your '
          'pediatrician). Common methods include graduated extinction '
          '(Ferber), where you check on your baby at increasing intervals; '
          'the chair method, where you sit nearby and gradually move further '
          'away over several nights; and fading, where you slowly reduce your '
          'involvement in the bedtime routine. Consistency is key with any '
          'method. Most babies show improvement within one to two weeks. '
          'A predictable bedtime routine (bath, book, song) signals that '
          'sleep time is approaching.',
      minAgeMonths: 4,
      maxAgeMonths: 12,
      tags: ['sleep training', 'ferber', 'bedtime routine', 'self-soothing'],
    ),
    Article(
      id: 'sleep-toddler-bedtime',
      title: 'Toddler Bedtime Routines',
      category: 'sleep',
      summary:
          'How to establish a calming bedtime routine that helps your toddler '
          'wind down and sleep through the night.',
      content:
          'Toddlers need approximately 11 to 14 hours of sleep per day, '
          'including naps. A consistent bedtime routine helps regulate their '
          'internal clock. Start winding down 30 minutes before bed: dim the '
          'lights, turn off screens, and engage in quiet activities like '
          'reading or gentle stretching. Offer a small, healthy snack if your '
          'child is hungry. Let your toddler choose between two pajama '
          'options to give them a sense of control. A nightlight and a '
          'favorite comfort object can ease separation anxiety. If your '
          'toddler resists bedtime, stay calm and return them to bed with '
          'minimal interaction.',
      minAgeMonths: 12,
      maxAgeMonths: 36,
      tags: ['toddler', 'bedtime routine', 'sleep schedule', 'nap transition'],
    ),
    Article(
      id: 'sleep-nap-transitions',
      title: 'Navigating Nap Transitions',
      category: 'sleep',
      summary:
          'When and how to drop naps as your baby grows from multiple naps '
          'to one nap per day.',
      content:
          'Most babies transition from three naps to two around six to nine '
          'months, and from two naps to one between 12 and 18 months. Signs '
          'your baby is ready include consistently fighting a nap, taking '
          'longer to fall asleep, or having a nap interfere with nighttime '
          'sleep. During transitions, you may need to temporarily move '
          'bedtime earlier to prevent overtiredness. Offer quiet rest time in '
          'place of the dropped nap. The transition typically takes two to '
          'four weeks. Watch your baby for sleepy cues rather than strictly '
          'following the clock.',
      minAgeMonths: 6,
      maxAgeMonths: 24,
      tags: ['naps', 'nap transition', 'sleep schedule', 'overtired'],
    ),

    // ── Feeding (4 articles) ──
    Article(
      id: 'feeding-breastfeeding-basics',
      title: 'Breastfeeding Basics',
      category: 'feeding',
      summary:
          'Getting started with breastfeeding, from latching techniques to '
          'feeding frequency in the first months.',
      content:
          'The World Health Organization recommends exclusive breastfeeding '
          'for the first six months of life. In the early days, feed your '
          'baby on demand, which is typically eight to twelve times in 24 '
          'hours. A good latch is essential: your baby\'s mouth should cover '
          'most of the areola, not just the nipple. Signs of effective '
          'feeding include audible swallowing, relaxed hands, and six or more '
          'wet diapers per day by day five. If you experience pain beyond '
          'initial tenderness, consult a lactation specialist. Skin-to-skin '
          'contact shortly after birth promotes bonding and supports '
          'breastfeeding success.',
      minAgeMonths: 0,
      maxAgeMonths: 6,
      tags: ['breastfeeding', 'latch', 'nursing', 'newborn feeding'],
    ),
    Article(
      id: 'feeding-introducing-solids',
      title: 'Introducing Solid Foods',
      category: 'feeding',
      summary:
          'When and how to introduce complementary foods alongside breast '
          'milk or formula.',
      content:
          'Most babies are ready for solid foods around six months of age, '
          'when they can sit with support, show interest in food, and have '
          'lost the tongue-thrust reflex. Start with single-ingredient '
          'purees such as iron-fortified cereal, sweet potato, or avocado. '
          'Introduce one new food every three to five days to watch for '
          'allergic reactions. Current research supports early introduction '
          'of common allergens like peanut (in age-appropriate forms) to '
          'reduce allergy risk. Offer a variety of textures as your baby '
          'develops chewing skills. Continue breastfeeding or formula feeding '
          'alongside solids until at least 12 months.',
      minAgeMonths: 4,
      maxAgeMonths: 12,
      tags: ['solids', 'puree', 'baby food', 'allergens', 'first foods'],
    ),
    Article(
      id: 'feeding-toddler-nutrition',
      title: 'Toddler Nutrition Guide',
      category: 'feeding',
      summary:
          'Balanced diet recommendations and practical tips for feeding '
          'toddlers aged one to three years.',
      content:
          'Toddlers need approximately 1,000 to 1,400 calories per day, '
          'spread across three meals and two snacks. Aim for a variety of '
          'fruits, vegetables, whole grains, protein, and dairy. Whole milk '
          'can replace formula or breast milk after 12 months; offer two to '
          'three cups per day. Iron-rich foods (beans, fortified cereals, '
          'lean meats) are especially important. Picky eating is normal at '
          'this age. Offer new foods alongside familiar favorites without '
          'pressure. Let your toddler self-feed to build motor skills. Avoid '
          'juice, sugary snacks, and foods that pose a choking hazard such as '
          'whole grapes, popcorn, and hot dog rounds.',
      minAgeMonths: 12,
      maxAgeMonths: 36,
      tags: ['toddler nutrition', 'picky eating', 'balanced diet', 'whole milk'],
    ),
    Article(
      id: 'feeding-bottle-weaning',
      title: 'Weaning from the Bottle',
      category: 'feeding',
      summary:
          'Strategies for transitioning your baby from bottle to cup around '
          'the first birthday.',
      content:
          'The AAP recommends weaning from the bottle by 12 to 18 months to '
          'protect dental health and prevent excess calorie intake. Start '
          'offering a sippy or straw cup with water at meals around six '
          'months so your baby gets used to it. Gradually replace one bottle '
          'feeding at a time with a cup, starting with the midday bottle. '
          'The bedtime bottle is often the last to go; replace it with a cup '
          'of milk during the bedtime routine, then brush teeth afterward. '
          'Expect some protest; consistency over one to two weeks usually '
          'resolves resistance.',
      minAgeMonths: 6,
      maxAgeMonths: 18,
      tags: ['bottle weaning', 'sippy cup', 'cup transition', 'dental health'],
    ),

    // ── Development (4 articles) ──
    Article(
      id: 'dev-tummy-time',
      title: 'The Importance of Tummy Time',
      category: 'development',
      summary:
          'Why tummy time matters and how to make it enjoyable for your baby '
          'from the first weeks of life.',
      content:
          'Tummy time strengthens your baby\'s neck, shoulder, and core '
          'muscles, laying the foundation for rolling, crawling, and '
          'sitting. Start with short sessions (three to five minutes) a few '
          'times a day right from birth. Place colorful toys within reach to '
          'encourage lifting and turning the head. Lie face-to-face with '
          'your baby for motivation. If your baby fusses, try tummy time on '
          'your chest or across your lap. Gradually increase duration as your '
          'baby gets stronger. By three to four months, aim for 20 to 30 '
          'minutes of tummy time spread throughout the day.',
      minAgeMonths: 0,
      maxAgeMonths: 6,
      tags: ['tummy time', 'motor development', 'neck strength', 'crawling'],
    ),
    Article(
      id: 'dev-first-words',
      title: 'Encouraging First Words',
      category: 'development',
      summary:
          'How to support your baby\'s language development from babbling to '
          'first meaningful words.',
      content:
          'Babies typically say their first words between 10 and 14 months, '
          'but language development starts much earlier. Talk to your baby '
          'throughout the day, narrating your activities. Respond to babbling '
          'as if it were conversation to reinforce communication. Read aloud '
          'daily, pointing to pictures and naming objects. Sing songs and '
          'nursery rhymes. Limit screen time, as face-to-face interaction is '
          'far more effective for language learning. If your baby is not '
          'babbling by nine months or has no words by 15 months, discuss this '
          'with your pediatrician.',
      minAgeMonths: 6,
      maxAgeMonths: 18,
      tags: ['first words', 'language', 'babbling', 'speech', 'reading'],
    ),
    Article(
      id: 'dev-potty-training',
      title: 'Potty Training Readiness',
      category: 'development',
      summary:
          'Signs your toddler is ready for potty training and strategies '
          'for a smooth transition.',
      content:
          'Most children show readiness signs between 18 and 36 months. '
          'Look for interest in the toilet, staying dry for two or more '
          'hours, discomfort with dirty diapers, ability to follow simple '
          'instructions, and the ability to pull pants up and down. Let your '
          'child pick out a potty chair. Establish a routine of sitting on '
          'the potty after meals and before bath. Use positive reinforcement '
          'such as stickers or praise. Avoid punishment for accidents. Night '
          'dryness often comes months after daytime training. Boys and girls '
          'develop readiness at similar ages on average.',
      minAgeMonths: 18,
      maxAgeMonths: 36,
      tags: ['potty training', 'toilet learning', 'readiness signs', 'toddler'],
    ),
    Article(
      id: 'dev-play-learning',
      title: 'Play-Based Learning Milestones',
      category: 'development',
      summary:
          'How play evolves from solitary exploration to imaginative and '
          'cooperative play in the first three years.',
      content:
          'Play is a child\'s primary way of learning. In the first few '
          'months, babies explore through sensory play: grasping, mouthing, '
          'and shaking objects. By six to nine months, cause-and-effect toys '
          'become fascinating. Around 12 months, functional play emerges '
          '(pushing a toy car, stacking blocks). Pretend play develops '
          'between 18 and 24 months (feeding a doll, talking on a toy '
          'phone). By 24 to 36 months, children begin parallel play alongside '
          'peers and gradually move toward cooperative play. Provide age-'
          'appropriate, open-ended toys and follow your child\'s interests.',
      minAgeMonths: 0,
      maxAgeMonths: 36,
      tags: ['play', 'learning', 'pretend play', 'cognitive development'],
    ),

    // ── Health (4 articles) ──
    Article(
      id: 'health-newborn-care',
      title: 'Newborn Care Essentials',
      category: 'health',
      summary:
          'Key health practices for the first month including umbilical cord '
          'care, bathing, and when to call the doctor.',
      content:
          'Keep the umbilical cord stump clean and dry; it typically falls '
          'off within one to three weeks. Give sponge baths until the stump '
          'separates. Dress your newborn in one more layer than you would '
          'wear. Normal newborn behavior includes frequent hiccups, sneezing, '
          'and irregular breathing during sleep. Contact your pediatrician if '
          'your baby has a rectal temperature above 100.4 F (38 C), refuses '
          'to feed, appears jaundiced (yellow skin or eyes), or seems '
          'unusually lethargic. Schedule the first well-baby visit within '
          'three to five days after discharge from the hospital.',
      minAgeMonths: 0,
      maxAgeMonths: 1,
      tags: ['newborn', 'umbilical cord', 'sponge bath', 'fever', 'jaundice'],
    ),
    Article(
      id: 'health-teething-relief',
      title: 'Teething Relief Strategies',
      category: 'health',
      summary:
          'Recognizing teething symptoms and safe methods to soothe your '
          'baby\'s discomfort.',
      content:
          'Most babies begin teething between four and seven months, though '
          'timing varies widely. Common signs include drooling, fussiness, '
          'gum swelling, and a desire to chew on objects. A low-grade fever '
          'under 101 F may occur but high fevers are not caused by teething. '
          'Offer a chilled (not frozen) teething ring or a clean, cold '
          'washcloth to chew on. Gently rub the gums with a clean finger. If '
          'your baby is very uncomfortable, ask your pediatrician about an '
          'age-appropriate dose of acetaminophen or ibuprofen (for babies '
          'over six months). Avoid numbing gels containing benzocaine and '
          'homeopathic teething tablets.',
      minAgeMonths: 4,
      maxAgeMonths: 12,
      tags: ['teething', 'gum pain', 'drooling', 'baby teeth'],
    ),
    Article(
      id: 'health-common-illnesses',
      title: 'Common Childhood Illnesses',
      category: 'health',
      summary:
          'What to know about colds, ear infections, and other frequent '
          'illnesses in babies and toddlers.',
      content:
          'Young children get an average of six to eight colds per year. '
          'Most are caused by viruses and resolve on their own within seven '
          'to ten days. Use saline drops and a bulb syringe to clear nasal '
          'congestion. A cool-mist humidifier can also help. Ear infections '
          'often follow colds; signs include ear tugging, irritability, and '
          'trouble sleeping. Hand-foot-and-mouth disease causes sores in the '
          'mouth and a rash on the hands and feet; it is contagious but '
          'usually mild. Seek medical attention for fevers above 100.4 F in '
          'babies under three months, difficulty breathing, signs of '
          'dehydration, or symptoms lasting more than ten days.',
      minAgeMonths: 0,
      maxAgeMonths: 36,
      tags: ['cold', 'ear infection', 'fever', 'illness', 'hand foot mouth'],
    ),
    Article(
      id: 'health-vaccination-schedule',
      title: 'Understanding the Vaccination Schedule',
      category: 'health',
      summary:
          'An overview of the recommended immunization timeline for babies '
          'and toddlers in the first three years.',
      content:
          'The CDC immunization schedule is designed to protect children when '
          'they are most vulnerable. Key vaccines in the first year include '
          'hepatitis B (at birth), DTaP, IPV, Hib, PCV13, and rotavirus '
          '(starting at two months). The MMR and varicella vaccines are given '
          'at 12 to 15 months, with boosters later. The flu vaccine is '
          'recommended annually starting at six months. Mild side effects '
          'like soreness at the injection site or a low-grade fever are '
          'normal. Serious reactions are extremely rare. Keeping your child '
          'on schedule ensures community immunity and protects those who '
          'cannot be vaccinated.',
      minAgeMonths: 0,
      maxAgeMonths: 36,
      tags: ['vaccines', 'immunization', 'cdc schedule', 'dtap', 'mmr'],
    ),

    // ── Safety (4 articles) ──
    Article(
      id: 'safety-babyproofing',
      title: 'Baby-Proofing Your Home',
      category: 'safety',
      summary:
          'A room-by-room guide to making your home safe for a mobile baby.',
      content:
          'Start baby-proofing before your baby begins crawling, typically '
          'around six months. Install safety gates at the top and bottom of '
          'stairs. Cover electrical outlets. Secure heavy furniture and TVs '
          'to the wall to prevent tip-overs. Use cabinet locks in the kitchen '
          'and bathroom. Keep small objects, coins, and batteries out of '
          'reach. Store medications, cleaning products, and sharp objects in '
          'locked cabinets. Place corner guards on sharp furniture edges. '
          'Ensure window blind cords are out of reach. Get on your hands and '
          'knees to see the world from your baby\'s perspective and identify '
          'hazards you might miss.',
      minAgeMonths: 4,
      maxAgeMonths: 18,
      tags: ['baby proofing', 'home safety', 'childproofing', 'safety gates'],
    ),
    Article(
      id: 'safety-car-seat',
      title: 'Car Seat Safety Guide',
      category: 'safety',
      summary:
          'Choosing, installing, and using car seats correctly from birth '
          'through the toddler years.',
      content:
          'Car crashes are a leading cause of injury in young children. Use '
          'a rear-facing car seat from birth until at least age two or until '
          'your child reaches the seat\'s maximum rear-facing height and '
          'weight limits. Ensure the seat is installed tightly (less than one '
          'inch of movement at the belt path). The harness should be snug '
          'with the chest clip at armpit level. Never place a rear-facing '
          'seat in front of an active airbag. Register your car seat with '
          'the manufacturer for recall notifications. Many fire stations and '
          'hospitals offer free car seat inspections. Replace any seat that '
          'has been in a moderate or severe crash.',
      minAgeMonths: 0,
      maxAgeMonths: 36,
      tags: ['car seat', 'rear facing', 'vehicle safety', 'installation'],
    ),
    Article(
      id: 'safety-choking-prevention',
      title: 'Choking Prevention and Response',
      category: 'safety',
      summary:
          'High-risk foods and objects, plus what to do if your baby or '
          'toddler starts choking.',
      content:
          'Choking is a leading cause of injury and death in children under '
          'four. High-risk foods include whole grapes, hot dogs, popcorn, '
          'nuts, raw carrots, chunks of cheese, and sticky foods like '
          'marshmallows. Cut food into small pieces (no larger than half an '
          'inch) and encourage your child to sit while eating. Keep small '
          'objects such as coins, button batteries, and deflated balloons out '
          'of reach. Learn infant CPR and the Heimlich maneuver for children. '
          'If a baby under one year is choking, give five back blows followed '
          'by five chest thrusts. For children over one, perform abdominal '
          'thrusts. Call emergency services immediately if the child cannot '
          'breathe or becomes unresponsive.',
      minAgeMonths: 4,
      maxAgeMonths: 36,
      tags: ['choking', 'food safety', 'cpr', 'heimlich', 'first aid'],
    ),
    Article(
      id: 'safety-water',
      title: 'Water Safety for Babies and Toddlers',
      category: 'safety',
      summary:
          'Preventing drowning at home and during recreational activities.',
      content:
          'Drowning can happen in as little as one inch of water and often '
          'occurs silently. Never leave a baby or toddler unattended near '
          'water, even for a moment. Empty buckets, wading pools, and '
          'bathtubs immediately after use. Install a four-sided fence with a '
          'self-closing, self-latching gate around home pools. Swim lessons '
          'can begin as early as one year, but they do not make a child '
          'drown-proof. Use Coast Guard-approved life jackets (not water '
          'wings) for boats and open water. Designate a Water Watcher at '
          'social gatherings to keep constant eyes on children near water.',
      minAgeMonths: 0,
      maxAgeMonths: 36,
      tags: ['water safety', 'drowning prevention', 'bath safety', 'pool safety'],
    ),

    // ── Behavior (4 articles) ──
    Article(
      id: 'behavior-colic',
      title: 'Colic Management',
      category: 'behavior',
      summary:
          'Understanding colic, soothing strategies, and when it typically '
          'resolves.',
      content:
          'Colic is defined as crying for more than three hours a day, three '
          'or more days a week, for three or more weeks in an otherwise '
          'healthy baby. It typically peaks around six weeks and resolves by '
          'three to four months. Soothing techniques include the five S\'s: '
          'swaddling, side or stomach position (while held, not for sleep), '
          'shushing, swinging, and sucking. White noise machines, car rides, '
          'and warm baths may also help. If you are breastfeeding, try '
          'eliminating dairy from your diet for two weeks to see if symptoms '
          'improve. Always place your baby safely in the crib and step away '
          'if you feel overwhelmed. Ask for help from family or friends.',
      minAgeMonths: 0,
      maxAgeMonths: 4,
      tags: ['colic', 'crying', 'soothing', 'five s', 'fussiness'],
    ),
    Article(
      id: 'behavior-tantrums',
      title: 'Understanding and Managing Tantrums',
      category: 'behavior',
      summary:
          'Why tantrums happen and evidence-based strategies for handling '
          'them calmly.',
      content:
          'Tantrums are a normal part of toddler development, peaking '
          'between 18 and 36 months. They occur because toddlers experience '
          'strong emotions but lack the language and self-regulation skills '
          'to express them. Stay calm and ensure your child is safe. '
          'Acknowledge their feelings ("I see you are upset") without giving '
          'in to unreasonable demands. Offer simple choices to restore a '
          'sense of control. Distraction works well for younger toddlers. '
          'After the tantrum, reconnect with a hug and briefly name the '
          'emotion. Prevent tantrums by maintaining routines, avoiding '
          'hunger and fatigue triggers, and giving warnings before '
          'transitions.',
      minAgeMonths: 12,
      maxAgeMonths: 36,
      tags: ['tantrums', 'toddler behavior', 'emotional regulation', 'meltdown'],
    ),
    Article(
      id: 'behavior-separation-anxiety',
      title: 'Separation Anxiety',
      category: 'behavior',
      summary:
          'Why separation anxiety develops and gentle strategies to help '
          'your baby cope.',
      content:
          'Separation anxiety typically appears around eight to ten months '
          'and can resurface around 18 months. It is a sign of healthy '
          'attachment and cognitive development, as your baby now understands '
          'that you exist even when out of sight but cannot yet grasp that '
          'you will return. Practice short separations and always say a '
          'brief, cheerful goodbye rather than sneaking away. Create a '
          'consistent goodbye ritual. Leave a comfort object that smells '
          'like you. When reuniting, be warm and reassuring. Avoid prolonged '
          'goodbyes, which can increase anxiety. Most children outgrow '
          'intense separation anxiety by 24 months.',
      minAgeMonths: 6,
      maxAgeMonths: 24,
      tags: ['separation anxiety', 'attachment', 'daycare', 'goodbye ritual'],
    ),
    Article(
      id: 'behavior-biting-hitting',
      title: 'Biting, Hitting, and Aggressive Behavior',
      category: 'behavior',
      summary:
          'Why toddlers bite and hit, and how to respond constructively.',
      content:
          'Biting and hitting are common in toddlers aged 12 to 36 months. '
          'These behaviors often stem from frustration, teething, '
          'overstimulation, or a desire to experiment with cause and effect. '
          'Respond calmly and firmly: "I will not let you hit. Hitting '
          'hurts." Remove your child from the situation briefly. Teach '
          'alternative expressions: "Use your words" or "You can stomp your '
          'feet if you are angry." Model gentle touch. Praise positive '
          'interactions. Avoid biting or hitting back, which teaches that '
          'aggression is acceptable. If the behavior is frequent and '
          'intense, rule out underlying causes such as ear infections or '
          'sleep deprivation and consult your pediatrician.',
      minAgeMonths: 10,
      maxAgeMonths: 36,
      tags: ['biting', 'hitting', 'aggression', 'toddler behavior', 'discipline'],
    ),
  ];
}
