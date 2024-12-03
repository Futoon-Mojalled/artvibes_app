// artworks.dart
class Artworks {
  static final List<Map<String, dynamic>> artworks = [
    {
      "imagePath": "assets/images/artwork7.jpg",
      "name": "Colourful Garden",
      "artist": "Liam Harlow",
      "description":
          "The painting depicts a vibrant sunflower field leading to a cozy countryside house, capturing the warmth and charm of nature.",
      "price": 2200,
    },
    {
      "imagePath": "assets/images/artwork8.jpg", 
      "name": "Ocean",
      "artist": "Lee Waters",
      "description":
          "The piece captures the dynamic movement of the ocean's waves, blending vibrant shades of blue to evoke a sense of tranquility and depth.",
      "price": 1900
    },
    {
      "imagePath": "assets/images/artwork1.jpg",
      "name": "Camels",
      "artist": "Rashid Al-Dosari",
      "description":
          "This painting portrays a lively desert scene, with camels and traders in traditional attire, capturing the essence of desert life and cultural heritage.",
      "price": 1400
    },
    {
      "imagePath": "assets/images/artwork2.jpg",
      "name": "Brown House",
      "artist": "Edward Griffin",
      "description":
          "This watercolor painting captures the timeless charm of an old English house, showcasing its classic architecture and well-kept garden.",
      "price": 1100
    },
    {
      "imagePath": "assets/images/artwork5.jpg",
      "name": "Purple",
      "artist": "Emiko Fujita",
      "description":
          "This abstract piece features a harmonious blend of purple hues, creating a textured and dynamic composition that evokes a sense of mystery and depth.",
      "price": 2100
    },
    {
      "imagePath": "assets/images/artwork4.png",
      "name": "Van Gogh",
      "artist": "Sophie Lemoine",
      "description":
          "This vibrant and bold portrait captures the essence of Van Gogh's iconic style, with dynamic brushstrokes and a playful use of color, bringing his artistry to life.",
      "price": 2500
    },
    {
      "imagePath": "assets/images/artwork3.jpg",
      "name": "White Dress Girl",
      "artist": "Clara Schmidt",
      "description":
          "This delicate watercolor painting captures a moment of innocence, with a young girl in a white dress gently picking flowers, immersed in the peaceful beauty of nature.",
      "price": 2300
    },
    {
      "imagePath": "assets/images/artwork6.jpg",
      "name": "Energy",
      "artist": "Johann Becker",
      "description":
          "This abstract piece uses vibrant blue, yellow, and black hues to evoke a sense of movement and power, symbolizing the dynamic force of energy.",
      "price": 1700
    },
    // Add more artwork details as needed
  ];

  // Method to get the list of artworks
  static List<Map<String, dynamic>> getArtworks() {
    return artworks;
  }
}
