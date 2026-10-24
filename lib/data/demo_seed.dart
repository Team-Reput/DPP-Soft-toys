
library demo_seed;

final Map<String, dynamic> demoDppJson = {
  'issuccessful': true,
  'data': [
    {
      'o_status': true,
      'o_message': '',
      'details': {
        // ── "Toy" tab (Home screen) ──────────────────────────────────────
        'toy': {
          'chips': [
            {'emoji': '🧸', 'label': '10-inch pet toy'},
            {'emoji': '🍃', 'label': 'Forest Friends'},
            {'emoji': '✨', 'label': 'Soft plush'},
          ],
          'home_card_text':
              'Soft, squishy, and ready for gentle playtime and cosy naps '
                  'with your furry friend.',
          'made_of': [
            {'label': 'My fluffy outside', 'value': 'Polyester plush'},
            {'label': 'My cuddly stuffing', 'value': 'Polyester filling'},
            {
              'label': 'My little details',
              'value': 'Polyester embroidery + PP trims'
            },
          ],
          'passport_facts': [
            {'label': 'Style code', 'value': 'TB-10IN-001'},
            {'label': 'Made by', 'value': 'Avanti Overseas'},
            {'label': 'Made in', 'value': 'Noida, India'},
            {'label': 'Production month', 'value': 'April 2026'},
          ],
          'pet_parent_toggle_label': 'For pet parents · more product info',
          'pet_parent_rows': [
            {'label': 'Original dataset brand', 'value': 'Avanti Kids'},
            {
              'label': 'Pet-facing brand',
              'value': 'Avanti Paws (concept)'
            },
            {'label': 'Purchase order', 'value': 'PO-TB-1000'},
          ],
          'pet_parent_website': {
            'label': 'Brand website in dataset',
            'link_text': 'example.com ↗',
            'url': 'https://example.com',
          },
          'pet_parent_disclaimer':
              'Supplied supplier declarations and certificate references '
                  'are illustrative, not independently verified. Pet '
                  'suitability and product safety testing are not '
                  'established by these records.',
          'story': {
            'emoji': '🍄',
            'title': 'Made for wagging tails & curious paws',
            'text':
                'A soft, cute companion for gentle play, carrying, '
                    'cuddling, and cosy nap-time company. Follow the tabs '
                    'below to see how this pet toy came to life.',
          },
        },

        // ── "Planet" tab (Impact screen) ────────────────────────────────
        'impact': {
          'metrics': [
            {
              'icon': '☁️',
              'value': '69.54',
              'unit': 'kg CO₂e',
              'what': 'Reported carbon footprint per toy',
            },
            {
              'icon': '💧',
              'value': '101.99',
              'unit': 'L',
              'what': 'Reported water footprint per toy',
            },
            {
              'icon': '⚡',
              'value': '18.61',
              'unit': 'kWh',
              'what': 'Reported energy used per toy',
            },
            {
              'icon': '🌿',
              'value': '0.15',
              'unit': '%',
              'what': 'Reported renewable energy share',
            },
          ],
          'renewable_share_percent': 0.15,
          'non_renewable_share_percent': 99.85,
          'disclaimer':
              'Environmental values reproduced from the supplied April '
                  '2026 DPP summary, rounded for readability. No '
                  'comparative "eco-friendly" claim is made.',
        },

        // ── "Journey" tab ────────────────────────────────────────────────
        'journey': {
          'intro':
              "From soft materials to the last careful check, here's how "
                  'this little Forest Friend came together.',
          'stops': [
            {
              'emoji': '🧶',
              'title': '1. Gathering soft things',
              'description':
                  'Plush fabric, fluffy filling, and little trims are '
                      'sourced.',
              'place': '📍 Panipat · Faridabad · Delhi',
            },
            {
              'emoji': '✂️',
              'title': '2. Cutting toy shapes',
              'description':
                  'Plush fabric is cut into the pieces that will become '
                      'this teddy-shaped pet toy.',
              'place': '📍 Noida, Uttar Pradesh',
            },
            {
              'emoji': '🪡',
              'title': '3. Stitching & little details',
              'description': 'Soft shells are sewn and embroidered.',
              'place': '📍 Noida, Uttar Pradesh',
            },
            {
              'emoji': '☁️',
              'title': '4. Making it soft & squishy',
              'description':
                  'Fluffy polyester filling gives the toy its soft, '
                      'cuddle-friendly shape.',
              'place': '📍 Faridabad / Noida production stages',
            },
            {
              'emoji': '🧸',
              'title': '5. Putting it all together',
              'description':
                  'The toy is assembled and finished with its trims.',
              'place': '📍 Noida, Uttar Pradesh',
            },
            {
              'emoji': '🔎',
              'title': '6. A final safety look',
              'description':
                  'Quality checks help find toys that need fixing before '
                      'they leave for pets and pet parents.',
              'place': '📍 Noida, Uttar Pradesh',
            },
            {
              'emoji': '🎁',
              'title': '7. Ready to meet you!',
              'description':
                  'Packaging protects teddy for the next part of the '
                      'journey.',
              'place': '📍 Packaging supplier: Panipat, Haryana',
            },
          ],
        },

        // ── "Care" tab ───────────────────────────────────────────────────
        'care': {
          'intro': '',
          'items': [
            {
              'emoji': '🧽',
              'title': 'Spot clean',
              'description': 'Surface clean only · no bleach',
            },
            {
              'emoji': '🌬️',
              'title': 'Air dry',
              'description': 'Let the toy dry naturally',
            },
            {
              'emoji': '👀',
              'title': 'Watch play',
              'description': 'Supervise every play session',
            },
            {
              'emoji': '🪡',
              'title': 'Check often',
              'description': 'Inspect seams before play',
            },
          ],
          'retire_text':
              'If the toy becomes torn, sheds filling, or develops loose '
                  'trims, stop play and retire it. Keep detached pieces '
                  'away from pets.',
        },

        // ── "Brand" tab ──────────────────────────────────────────────────
        'brand': {
          'story': {
            'emoji': '🌼',
            'title': 'Meet Avanti Paws',
            'text':
                'A playful pet-facing name for this Forest Friends '
                    'passport. The source dataset names the brand Avanti '
                    'Kids; "Avanti Paws" is proposed branding, not a '
                    'confirmed legal brand change.',
          },
          'behind_the_brand': [
            {'label': 'Brand story', 'value': 'Illustrative test brand data'},
          ],
          'website': {
            'label': 'Brand website',
            'link_text': 'example.com ↗',
            'url': 'https://example.com',
          },
          'certs_intro':
              'The dataset lists illustrative certification references '
                  'from suppliers. Their validity and applicability have '
                  'not been independently verified.',
          'cert_chips': [
            {'emoji': '🌲', 'label': 'FSC chain-of-custody'},
            {'emoji': '🧵', 'label': 'GRS reference'},
            {'emoji': '📋', 'label': 'ISO 9001 reference'},
            {'emoji': '♻️', 'label': 'Recycled-content declarations'},
          ],
          'supporting_docs_text':
              'Material declarations, fiber and thread batch records, '
                  'inspection records and internal production records are '
                  'referenced in the source data. No document downloads or '
                  'certification verification links were supplied.',
          'take_back_headline': 'Not applicable.',
          'take_back_text':
              'No product take-back programme is listed in the supplied '
                  'data.',
          'take_back_end_of_life_text':
              'For an end-of-life mixed-material toy, check local disposal '
                  'rules. Do not place it in recycling unless your local '
                  'service accepts these materials.',
          'disclaimer':
              'Supplier references and brand story information are '
                  'illustrative. No pet-toy safety approval or '
                  'independently verified sustainability certification is '
                  'claimed.',
        },
      },
    },
  ],
};
