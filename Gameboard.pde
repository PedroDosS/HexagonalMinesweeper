import processing.sound.*;

public class GameBoard {
  private float[][] tileShape  = { {4, 2, -2, -4, -2, 2}, {0, 3.5, 3.5, 0, -3.5, -3.5} }; //The shape of the hexagons as defined by the Polygon Class
  private int tileCountX, tileCountY; //The amount of Tiles in the X and Y direction
  private int[] hoveredTile = {0, 0}; //Stores the index of whichever Tile is currently hovered over
  private Tile[][] tiles; //Grid of Tiles
  public boolean isWon = false, isLost = false;
  private int clickCount = 0, mineCount;
  public float rippleSpeed = 1;

  public GameBoard(int tileCountX, int tileCountY, float tileScale, int mineCount) {
    this.tileCountX = tileCountX;
    this.tileCountY = tileCountY;

    tiles = new Tile[tileCountX][tileCountY];

    createTiles(tileScale);

    if (mineCount >= tileCountX * tileCountY) { //Makes sure that there aren't too many mines to spawn in (otherwise it could cause an infinite loop)
      this.mineCount = tileCountX * tileCountY - 1;
      println("WARNING: There are too many mines!");
    } else {
      this.mineCount = mineCount;
    }
  }

  public void drawSelf() {

    for (int j = 0; j < tileCountY; j++) {
      for (int i = 0; i < tileCountX; i++) {
        fill(#cccccc); //Colors the tiles gray by default
        if (tiles[i][j].isMarked) fill(#eeeeee); //Colors the marked tiles a lighter gray
        if (tiles[i][j].isPressed) fill(#999999); //Colors the pressed tiles a darker gray


        if (i == hoveredTile[0] && j == hoveredTile[1]) {  //Sets the color of the hovered tile
          fill(#7f00ff00);                                 //Sets it green by default
          if (tiles[i][j].isMarked) fill(#b3ffb2);          //Lightens if it the tile is marked
        }

        tiles[i][j].drawSelf();
        tiles[i][j].rippleTimer -= rippleSpeed;
      }
    }

    rippleEffect();
  }

  //Sets which tile is currently hovered, unselects all other tiles
  public void updateHover() {
    for (Tile[] tileRow : tiles) {
      for (Tile tile : tileRow) {
        tile.isHovered = false;
        tile.hasPropogatedThisTick = false;
      }
    }

    for (int j = 0; j < tileCountY; j++) {
      for (int i = 0; i < tileCountX; i++) {
        tiles[i][j].updateHover();
        if (tiles[i][j].isHovered) {
          hoveredTile[0] = i;
          hoveredTile[1] = j;
          return;
        }
      }
    }
  }

  //Clicks on the tiles, checks for a win
  public void click() {
    int pressedTiles = 0; //Used to check if all non-mine tiles are pressed
    tiles[hoveredTile[0]][hoveredTile[1]].rippleTimer = 15;

    if (clickCount == 0) {
      createMines(mineCount);
    }

    clickCount++;

    for (int j = 0; j < tileCountY; j++) {
      for (int i = 0; i < tileCountX; i++) {
        if (tiles[i][j].isHovered && !tiles[i][j].isPressed && !tiles[i][j].isMarked) {
          tiles[i][j].click();
          tilePressSFX.add(random(-0.4, 0.4));
          tilePressSFX.play();
          particleHandler.spawnConfetti(10, tiles[i][j].cX, tiles[i][j].cY);

          if (tiles[i][j].nearbyMines == 0 && !tiles[i][j].isMine) { //Propogates the empty "0" tiles
            propogateClick(i, j);
            multiPressSFX.play();
          }


          if (tiles[i][j].isMine) { //Loss Condition
            isLost = true;
            rippleSpeed = 0.4;
            loseSFX.play();
            return;
          }
        }

        if (tiles[i][j].isPressed) { //Counts the amount of pressed tiles
          pressedTiles++;
        }
      }
    }

    if (pressedTiles == tileCountX * tileCountY - mineCount) {
      isWon = true; //Win Condition
      winSFX.play();
      rippleSpeed = 1;
    }
  }



  //Propogates the click so that tiles near a "0" are also clicked
  private void propogateClick(int i, int j) {
    int[][] nearbyTiles = getNearbyTiles(i, j);



    for (int k = 0; k < nearbyTiles.length; k++) {
      int x = nearbyTiles[k][0], y = nearbyTiles[k][1];

      if (tileIsInBounds(x, y)) {     //Checks if the tile is in bounds
        tiles[x][y].click();          //Set the tile to be pressed

        if (!tiles[x][y].hasPropogatedThisTick) { //Checks if the tile isn't a mine and hasn't already been propogated (to prevent infinite loops)
          tiles[x][y].hasPropogatedThisTick = true;
          particleHandler.spawnConfetti(1, tiles[x][y].cX, tiles[x][y].cY); //Spawns in particles
          if (tiles[x][y].nearbyMines == 0) {
            propogateClick(x, y);          //Propogates the click into the nearby tiles
          }
        }
      }
    }
  }

  //Marks tiles with flags on them
  public void markTile() {
    for (int j = 0; j < tileCountY; j++) {
      for (int i = 0; i < tileCountX; i++) {
        if (tiles[i][j].isHovered && !tiles[i][j].isPressed) {          
          tiles[i][j].isMarked = !tiles[i][j].isMarked;
          if(tiles[i][j].isMarked) flagPlaceSFX.play();
          else flagRemoveSFX.play();
        }
      }
    }
  }

  //Initializes tiles, sets their position to be in the hexagon grid
  private void createTiles(float tileScale) throws RuntimeException {
    //Creates a dummy tile just to calculate how large the tiles are
    Tile testTile = new Tile(tileShape, 0, 0, tileScale);
    float tileWidth = testTile.maxX - testTile.minX;
    float tileHeight = testTile.maxY - testTile.minY;


    //Creates the grid of tiles, assigns them the correct X and Y positions based off their index.
    //Index specifications shown on this image: https://ibb.co/VCBFgBt
    for (int j = 0; j < tileCountY; j++) {
      for (int i = 0; i < tileCountX; i++) {
        tiles[i][j] = new Tile(tileShape, 50 + (i * tileWidth * 3 / 4), 50 + (j * tileHeight) + (i % 2 * (tileHeight / 2)), tileScale);
      }
    }
  }

  //Sets which tiles are mines, updates the tiles to know how many mines are nearby
  public void createMines(int mineCount) {
    for (int k = 0; k < mineCount; k++) {
      int i = int(random(0, tileCountX));
      int j = int(random(0, tileCountY));

      if (tiles[i][j].isMine) k--; //Sets a random tile to be a mine. If it's already a mine, it tries another random tile
      if (i == hoveredTile[0] && j == hoveredTile[1]) { //Makes sure that the first tile pressed is never a mine
        k--;
        continue;
      }
      tiles[i][j].isMine = true;
    }

    //Counts the amount of mines near a tile
    for (int j = 0; j < tileCountY; j++) {
      for (int i = 0; i < tileCountX; i++) {
        int nearbyMines = 0;
        int[][] nearbyTiles = getNearbyTiles(i, j);


        for (int k = 0; k < nearbyTiles.length; k++) { //Loops through the nearby tiles and checks if they're a mine
          int x = nearbyTiles[k][0];
          int y = nearbyTiles[k][1];
          if (tileIsInBounds(x, y) && tiles[x][y].isMine) {
            nearbyMines++;
          }
        }

        tiles[i][j].nearbyMines = nearbyMines;
      }
    }
  }

  //Returns the index of the 6 adjacent tiles
  private int[][] getNearbyTiles(int i, int j) {

    //                     North      South    North-West          South-West     North-East            South-East
    int[][] nearbyTiles = { {i, j+1}, {i, j-1}, {i-1, j-((i+1)%2)}, {i-1, j+(i%2)}, {i+1, j-((i+1)%2)}, {i+1, j+(i%2)}  };

    return nearbyTiles;
  }

  //Checks if the tile index is valid
  private boolean tileIsInBounds(int i, int j) {
    return i >= 0 && j >= 0 && i < tileCountX && j < tileCountY;
  }


  //Controlls the rippling of the tiles when the game is over
  private void rippleEffect() {
    for (int j = 0; j < tileCountY; j++) {
      for (int i = 0; i < tileCountX; i++) {
        if (tiles[i][j].rippleTimer > 9.8 && tiles[i][j].rippleTimer < 10.2) { //Checks range so that this value isn't skipped
          int[][] nearbyTiles = getNearbyTiles(i, j);

          for (int k = 0; k < nearbyTiles.length; k++) { //Loops through the nearby tiles and checks if they're a mine
            int x = nearbyTiles[k][0];
            int y = nearbyTiles[k][1];
            if (tileIsInBounds(x, y) && tiles[x][y].rippleTimer < 0 && (isWon || isLost)) {
              tiles[x][y].rippleTimer = 15;
            }
          }
        }
      }
    }
  }
}
