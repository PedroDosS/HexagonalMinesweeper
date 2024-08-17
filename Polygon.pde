public class Polygon {
  private float[][] unitPoly;
  protected float[][] transPoly;
  protected float angle, scale, cX, cY;
  protected float minX , minY, maxX, maxY;

  public Polygon(float[][] unitPoly, float cX, float cY, float angle, float scale) {
    this.unitPoly = unitPoly;                         //The unit polygon is the polygon before any transformations. (0,0) is the center of transformation. It is defined as { {xCoords}, {yCoords} }
    this.transPoly = new float[unitPoly.length][2];   //The transformation polygon is the polygon after the transformations
    checkIfValidPolygon(unitPoly);
    this.angle = angle;
    this.scale = scale;
   this.cX = cX;
   this.cY = cY;
   
   updateTransformation(); //Computes the transformations once
  }

  //Draws the polygon
  public void drawSelf() {
    updateTransformation(); //Recomputes transformations, applies them to transPoly

    beginShape();
    for (int i = 0; i < transPoly[0].length; i++) { //Makes a vertext at each point in the polygon
      vertex(transPoly[0][i], transPoly[1][i]);
    }
    vertex(transPoly[0][0], transPoly[1][0]);       // Closes off the polygon
    endShape();
  }

  //Applies rotation, scale, and translation to the unit polygon, stores in transPoly
  private void updateTransformation() {
    transPoly = unitPoly;
    transPoly = rotatePoly(unitPoly, angle);
    transPoly = scalePoly(transPoly, scale);
    transPoly = translatePoly(transPoly, cX, cY);
    
    minX = min(transPoly[0]);
    minY = min(transPoly[1]);
    maxX = max(transPoly[0]);
    maxY = max(transPoly[1]);
  }

  //Rotates the polygons at angle a CW
  private float[][] rotatePoly(float[][] poly1, float a) {
    float[][] poly2 = new float[2][poly1[0].length];

    for (int i = 0; i < poly1[0].length; i++) { //Matrix transformation formula from https://en.wikipedia.org/wiki/Rotation_matrix
      poly2[0][i] = (poly1[0][i] * cos(a)) - (poly1[1][i] * sin(a)); // X coords of rotated polygon
      poly2[1][i] = (poly1[0][i] * sin(a)) + (poly1[1][i] * cos(a)); // Y coords of rotated polygon
    }

    return poly2;
  }


  //Scales the polygon by a factor of s
  private float[][] scalePoly(float[][] poly, float s) {
    
    for (int i = 0; i < poly[0].length; i++) {
      poly[0][i] *= s; // X coords of scaled polygon
      poly[1][i] *= s; // Y coords of scaled polygon
    }

    return poly;
  }

  //Translate the polygon by offset = <x, y>.
  private float[][] translatePoly(float[][] poly1, float offsetX, float offsetY) {
    float[][] poly2 = new float[2][poly1[0].length];

    for (int i = 0; i < poly1[0].length; i++) {
      poly2[0][i] = poly1[0][i] + offsetX; // X coords of translated polygon
      poly2[1][i] = poly1[1][i] + offsetY; // Y coords of translated polygon
    }

    return poly2;
  }
  
  //Makes sure that the Polygon has valid coordinate points
  private void checkIfValidPolygon(float[][] poly) throws RuntimeException{
    if(poly.length != 2) throw new RuntimeException("Polygon formatted incorrectly. Must be { xPositions[], yPositions[] }");
    if(poly[0].length != unitPoly[1].length) throw new RuntimeException("Polygon formatted incorrectly. The amount of X coordinates does not match Y coordinates");
  }
}
