import processing.sound.*;

public class Tile extends Polygon {
  private float cX, cY;
  private boolean isPressed = false;
  public boolean isMine = false, isHovered, hasPropogatedThisTick = false, isMarked = false;
  public int nearbyMines;
  public float rippleTimer = 0;
  private boolean hasExploded = false;


  public Tile(float[][] shape, float cX, float cY, float size) {
    super(shape, cX, cY, 0, size);

    this.cX = cX;
    this.cY = cY;
  }

  public void drawSelf() {
    //Draws the hexagon Shape
    super.drawSelf();

    //Draws the ripple effect ontop of it
    if (rippleTimer > 0 || hasExploded) {
      if (gameBoard.isWon) fill(200, 255, 200, 12.75 * rippleTimer);
      else if (gameBoard.isLost) {
        fill(255, 100, 100, 12.75 * rippleTimer);
         if(isMine && !hasExploded) hasExploded = true;
      }
      
      if(hasExploded) fill(#7dff0000);
      
      super.drawSelf();
    }


    textAlign(LEFT);
    if (isPressed) {
      if (!isMine) {
        fill(#000000);
        textSize(25);
        text(nearbyMines, cX - 6, cY + 8); //Draws the amount of nearby mines
      } else {
        fill(#ff0000);
        circle(cX, cY, 5);  //Draws the mine dot
      }
    } else if (isMarked) {
      image(flagImg, cX, cY, 30, 30); //Draws the flag
    }
  }


  public void click() {
    isPressed = true;
  }

  //Lets the tile know if the mouse is hovering over it;
  public void updateHover() {
    //Bounding box check
    if (mouseX < minX || mouseX > maxX || mouseY < minY || mouseY > maxY) {
      isHovered = false;
      return;
    }

    //Hexagon point check based on http://www.playchilla.com/how-to-check-if-a-point-is-inside-a-hexagon
    //Math Calculations: https://ibb.co/PzCwbBB
    float h = (maxX - cX) / 2;
    float v = maxY - cY;
    float mouseX2 = Math.abs(mouseX - cX) + cX;    //mouseX reflected into Q2 (relative to center of hexagon)
    float mouseY2 = Math.abs(mouseY - cY) + cY;    //mouseY reflected into Q2 (relative to center of hexagon)

    isHovered = (-v * (mouseX2 - cX - h)) + (-h * (mouseY2 - cY - v)) >= 0; //Math explanation on ibb.co link
  }
}
