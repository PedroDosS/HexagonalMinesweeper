//Made by Pedro dos Santos
import processing.sound.*;

PImage flagImg;

SoundFile winSFX;
SoundFile loseSFX;
SoundFile tilePressSFX;
SoundFile flagPlaceSFX;
SoundFile flagRemoveSFX;
SoundFile explosionSFX;
SoundFile multiPressSFX;

//Creates a 15x10 board with size 6 hexagons
GameBoard gameBoard;
ParticleHandler particleHandler = new ParticleHandler();

void setup() {
  size(600, 600);

  flagImg = loadImage("flag.png");
  imageMode(CENTER);

  winSFX = new SoundFile(this, "sfx/win.wav");
  loseSFX = new SoundFile(this, "sfx/lose.wav");
  tilePressSFX = new SoundFile(this, "sfx/tilePress.wav");
  flagPlaceSFX = new SoundFile(this, "sfx/flagPlace.wav");
  flagRemoveSFX = new SoundFile(this, "sfx/flagRemove.wav");
  explosionSFX = new SoundFile(this, "sfx/explosion.wav");
  multiPressSFX = new SoundFile(this, "sfx/multiPress.wav");

  gameBoard = new GameBoard(15, 10, 6, 30);
}

void draw() {
  background(#2DF1FA);
  gameBoard.drawSelf();

  textAlign(CENTER);
  textSize(50);

  if (gameBoard.isLost == true) {
    fill(#ff0000);
    text("You lose!", width/2, 535);
    fill(#ffffff);
    text("You lose!", width/2 - 3, 532);
  }

  if (gameBoard.isWon == true) {
    fill(#00ff00);
    text("You win!", width/2, 535);
    fill(#ffffff);
    text("You win!", width/2 - 3, 532);
  }


  particleHandler.drawParticles();
}

void mouseMoved() {
  gameBoard.updateHover();
}

void mousePressed() {
  if (!gameBoard.isWon && !gameBoard.isLost) {
    if (mouseButton == LEFT) {
      gameBoard.click();
    } else if (mouseButton == RIGHT) {
      gameBoard.markTile();
    }
  }
}

void keyPressed() {
  if (key == ENTER && (gameBoard.isLost || gameBoard.isWon)) setup();
}
