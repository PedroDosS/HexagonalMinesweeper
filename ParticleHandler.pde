public class ParticleHandler {
  private ArrayList<Particle> particles = new ArrayList<Particle>();

  final float[][] hexShape = { {4, 2, -2, -4, -2, 2}, {0, 3.5, 3.5, 0, -3.5, -3.5} };
  final float[][] squareShape = { {-3, -3, 3, 3}, {-3, 3, 3, -3} };
  final float[][] bowShape = { {-3, -3, 3, 3}, {-3, 3, -3, 3} };
  final float[][] rectShape = { {-5, 5, 5, -5}, {-3, -3, 3, 3} };
  
 

  public ParticleHandler() {
  }

  public void spawnConfetti(int particleCount, float x, float y) {
    for (int i = 0; i < particleCount; i ++) {
      int rand = int(random(0, 4));
      float[][] shape;

      //Gives the particles a random shape
      switch(rand) {
      case 0:
        shape = hexShape;
        break;
      case 1:
        shape = squareShape;
        break;
      case 2:
        shape = bowShape;
        break;
      default:
        shape = rectShape;        
      }
       
      //Gives the particles some spawn variation so they don't all spawn dead center of the tile
      float pX = x + random(-10, 10);
      float pY = y + random(-10, 10);

       
      particles.add(new Particle(shape, pX, pY, hsvToColor(random(0, 360), 75, 100)));
    }
  }

  public void drawParticles() {
    for (int i = particles.size() - 1; i >= 0; i--) { //Iterates backwards to prevent errors
      Particle p = particles.get(i);

      if (p.shouldBeRemoved()) { //Removes the particles once offscreen to prevent lag
        particles.remove(i);
        continue;
      }

      p.drawSelf();
    }
  }
  

  //Turns a color specified in HSV (hue, saturation value), to an rgb color
  private color hsvToColor(float H, float S, float V) {

    H %= 360;
    S = min(S, 100) / 100;
    V = min(V, 100) / 100;

    float C = V * S;
    float X = C * (1 - abs(((H / 60) % 2 ) - 1));
    float M = V - C;

    float r_p, g_p, b_p;

    if (0 <= H && H < 60) { //Red
      r_p = C;
      g_p = X;
      b_p = 0;
    } else if (60 <= H && H < 120) { //Yellow
      r_p = X;
      g_p = C;
      b_p = 0;
    } else if (120 <= H && H < 180) { //Green
      r_p = 0;
      g_p = C;
      b_p = X;
    } else if (180 <= H && H < 240) { //Cyan
      r_p = 0;
      g_p = X;
      b_p = C;
    } else if (240 <= H && H < 300) { //Blue
      r_p = X;
      g_p = 0;
      b_p = C;
    } else { //Magenta
      r_p = C;
      g_p = 0;
      b_p = X;
    }

    int r = (int)((r_p + M) * 255);
    int g = (int)((g_p + M) * 255);
    int b = (int)((b_p + M) * 255);

    return color(r, g, b);
  }
}
