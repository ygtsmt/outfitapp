// HUG VIDEOS

const String classicHugPrompt =
    'Two real people, a man and a woman (or two friends), standing and embracing each other in a warm, classic hug. Their arms are around each other’s shoulders and back. They are standing upright, close together, in a natural indoor or outdoor setting. Their facial expressions show comfort, love, or friendship. The lighting is realistic and soft. The background is slightly blurred (bokeh) to keep focus on the hug.';
const String runningHugPrompt =
    'A realistic emotional scene of two people hugging after one has run toward the other. One person is slightly lifted from the ground, legs off the floor, arms wrapped tightly around the other. The other person stands firm and catches them warmly. The setting could be an airport, train station, or a sunset field. Facial expressions are joyful and emotional. Motion blur on legs can be applied to show dynamic action.';
const String backHugPrompt =
    'Two realistic people in a standing pose, where one is hugging the other from behind. The person in the front looks slightly surprised or emotional, while the one behind is gently smiling or resting their head on the other’s shoulder. The scene is calm, intimate, and slightly romantic. Background could be a park, a home interior, or a soft-lighted street.';
const String funnyHugPrompt =
    'A humorous and exaggerated scene of two real people hugging in a funny way. One person may have jumped and clung onto the other dramatically, or both might be falling over while hugging. Facial expressions are exaggerated: one person wide-eyed or pretending to faint, the other shocked or laughing. The background can be casual – like a living room or street. Slight cartoonish touch on facial emotion, but with realistic body texture and lighting.';
const String negativePromptForHugVideos =
    "blurry, low quality, low resolution, deformed face, deformed hands, extra limbs, missing fingers, bad anatomy, unrealistic proportions, distorted body parts, cloned people, multiple heads, creepy eyes, unnatural lighting, overly saturated colors, exaggerated cartoon style, bad posture, glitch, artifacts, grainy, pixelated, floating limbs, bad perspective";

// KISS VIDEOS
const String frenchKissPrompt =
    "Two people engaging in a passionate French kiss, eyes closed, lips gently touching, realistic expressions of intimacy, soft lighting, romantic atmosphere, close-up cinematic shot, slightly blurred background, photorealistic style, natural skin textures, gentle head tilt and hand placement";
const String generalKissPrompt =
    "A couple sharing a sweet romantic kiss, natural setting, soft lighting, close-up view, gentle emotion in their faces, subtle smile, smooth skin details, realistic photo-based lighting and shadow, calm and cinematic mood";
const String kissMeAiPrompt =
    "A person is kissed on the lips by someone of the opposite gender, romantic mood, gentle facial contact, close-up cinematic framing, realistic lighting and skin texture, soft expression, intimate moment";
const String cheekKissPrompt =
    "One person kissing the other on the cheek, smiling warmly, head slightly tilted, visible joy and affection, realistic human emotion, photorealistic skin texture, close-up shot with cinematic composition, soft lighting, romantic yet playful atmosphere";

const String polloTwerkPrompt =
    "Realistic person , wearing a crop top and shorts, turns their back to the camera and starts twerking. Smooth, rhythmic hip movements match an upbeat hip-hop beat. Camera is positioned behind at waist level, capturing realistic body motion. Soft lighting, wooden floor, and wall mirrors reflect the movement subtly. Natural shadows and slight handheld camera shake add realism.";
List<String> prompts = [
  // Gerçekçi (realistic) promptlar
  "Ultra realistic portrait of a Turkish woman with green eyes, natural lighting, DSLR photo",
  "A high-resolution close-up of hands holding fresh strawberries, soft background blur",
  "A luxury modern house at sunset with a pool, viewed from the backyard, cinematic lighting",
  "Realistic photo of a rainy street in Paris, reflection on wet cobblestones, warm tones",
  "Beautiful elderly man with deep wrinkles smiling, close-up face, Leica style photo",
  "A fashion model posing in Istanbul street, golden hour lighting, realistic lens flare",
  "Close-up photo of a barista pouring latte art, shallow depth of field, creamy tones",
  "Realistic night photo of a car driving through neon-lit city street, cinematic angle",
  "Realistic photo of a golden retriever in a sunflower field during golden hour",
  "Candid photo of a couple walking by the sea, wind blowing hair, authentic smiles",
  "Realistic food photo of Turkish breakfast spread on a wooden table, soft sunlight",
  "Macro shot of dew drops on a green leaf, ultra detailed, nature photography style",
  "A Turkish bazaar with realistic lighting, warm colors, people browsing rugs",
  "Portrait of a teenage boy looking into the camera, natural freckles, soft lighting",
  "A beach in Antalya at sunset, calm waves, clear water, photo-realistic quality",

  // Yaratıcı / Konseptual / Fantastik promptlar (ama hâlâ Flux ile uyumlu)
  "A dreamy surreal landscape with a floating island and a giant tree, soft lighting",
  "Futuristic Istanbul skyline with flying cars and digital signs, dusk atmosphere",
  "A fairy sitting on a mushroom under moonlight, glowing wings, cinematic detail",
  "Anime-style girl sitting in a cozy cafe, steam from coffee, warm ambiance",
  "A robot playing violin in a misty forest, emotional tone, cinematic colors",
  "Ancient ruins overtaken by nature, vines and trees growing over old stone, fantasy style",
  "A glowing jellyfish floating in the night sky above a calm ocean, surreal concept",
  "A knight in shining armor standing in front of a glowing portal, epic lighting",
  "Cyberpunk alley with neon signs, rainy pavement, lone figure walking",
  "A magical library with floating books and candles, enchanted ambiance",
  "Concept art of a floating train moving through the clouds, dreamy lighting",
  "A giant cat sitting on top of a skyscraper, whimsical scale, city at night",
  "A futuristic astronaut meditating on a distant planet, stars and calm glow",
  "A digital goddess made of circuit patterns and light, looking into camera",
  "Low-poly style landscape with pastel colors, stylized sun and trees"
];
