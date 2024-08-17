public class Particle extends Polygon{
  private color col;
  private float vX, vY, vRot;
  
  final static float gravity = 0.6;

  public Particle(float[][] unitPoly, float cX, float cY, color col){
    super(unitPoly, cX, cY, random(0, TWO_PI), 2);
    
    this.col = col;
    this.vRot = random(-0.1, 0.1);
    
    //Assigns the particle a random velocity
    vX = random(-8, 8);
    vY = random(-14, -2);
  }
  
  private void update(){
    super.cX += vX;
    super.cY += vY;
    
    vY += gravity;
    super.angle += vRot;
  }
  
  public void drawSelf(){  
    update();
    
    fill(col);
    super.drawSelf();
  }
  
  public boolean shouldBeRemoved(){
    if(super.scale < 0) return true; //Particle should be removed if it is too small
    if(super.maxX < -100 || super.minX > width + 100 || super.minY > height + 100) return true; //Particle should removed if it is offscreen
    return false;
  }
}
