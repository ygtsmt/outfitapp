import 'dart:math';

class PromptSuggestionsService {
  static const List<String> promptSuggestions = [
    // Nature & Landscapes
    "A serene mountain lake at sunset with golden reflections on the water. Pine trees silhouetted against the orange sky.",
    "A magical forest with glowing mushrooms and fireflies dancing between ancient oak trees. Soft moonlight filtering through the canopy.",
    "A vast desert landscape with sand dunes stretching to the horizon. A lone camel caravan making its way across the golden sands.",
    "A tropical beach with crystal clear turquoise water and white sand. Palm trees swaying in the gentle breeze under a perfect blue sky.",
    "A snowy mountain peak piercing through clouds. Majestic eagles soaring above the pristine white landscape.",

    // Fantasy & Magic
    "A mystical castle floating in the clouds with rainbow bridges connecting to other floating islands. Dragons flying around the towers.",
    "A magical library with books that glow and float in mid-air. A wise wizard reading ancient spells under a starlit ceiling.",
    "A fairy garden with tiny houses built into flower petals. Colorful butterflies and magical creatures playing among the blossoms.",
    "A steampunk city with brass gears and steam pipes everywhere. Airships flying between towering clockwork buildings.",
    "A crystal cave filled with glowing gems and underground waterfalls. Mysterious shadows dancing on the crystalline walls.",

    // Animals & Wildlife
    "A majestic lion with a golden mane sitting regally on a rocky outcrop. The African savanna stretching endlessly behind him.",
    "A family of dolphins leaping joyfully through ocean waves. Sunlight creating rainbows in the spray around them.",
    "A colorful peacock displaying its magnificent tail feathers in a royal garden. Marble fountains and blooming roses in the background.",
    "A wise old owl perched on a moonlit branch. Its large eyes glowing with ancient knowledge in the dark forest.",
    "A playful panda cub rolling in a field of bamboo. Cherry blossoms falling gently around the peaceful scene.",

    // Urban & Modern
    "A bustling city street at night with neon lights reflecting on wet pavement. People with umbrellas walking under the colorful glow.",
    "A modern art gallery with abstract paintings and sculptures. Visitors contemplating the creative works in the minimalist white space.",
    "A cozy coffee shop with warm lighting and exposed brick walls. Steam rising from freshly brewed coffee cups on wooden tables.",
    "A rooftop garden in the middle of a concrete jungle. Green plants and flowers thriving high above the busy city streets.",
    "A vintage bookstore with towering shelves and ladder access. Dusty sunlight streaming through tall windows onto old leather-bound books.",

    // Space & Sci-Fi
    "A space station orbiting a distant planet with multiple moons. Astronauts in space suits working on the exterior of the station.",
    "An alien landscape with purple vegetation and two suns in the sky. Strange creatures with bioluminescent features exploring the terrain.",
    "A futuristic city with flying cars and holographic advertisements. Neon lights creating a cyberpunk atmosphere in the urban night.",
    "A space explorer discovering an ancient alien temple on a distant planet. Mysterious hieroglyphs glowing with otherworldly energy.",
    "A peaceful space colony with domed habitats and hydroponic gardens. Earth visible as a blue marble in the star-filled sky."
  ];

  /// Gets a random prompt suggestion from the list
  static String getRandomPrompt() {
    final random = Random();
    final index = random.nextInt(promptSuggestions.length);
    return promptSuggestions[index];
  }

  /// Gets multiple random prompts (useful for future features)
  static List<String> getRandomPrompts(int count) {
    final random = Random();
    final shuffled = List<String>.from(promptSuggestions)..shuffle(random);
    return shuffled.take(count).toList();
  }
}







