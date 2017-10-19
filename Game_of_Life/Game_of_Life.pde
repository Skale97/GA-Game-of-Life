int n = 200; //<>//
int k = 10;
int frmRate = 700;
int screenSize = 600;
int[][] board = new int[n][n];
int[][] save = new int[n][n];
Boolean b = true, print =true;
int rectSize = screenSize/n;
int sum = 0;
int liveCells = 0;
int lC1 = 100;
int lC2 = 0;
Boolean lC3 = false;
int gen = 0;
int generations = 0;
int[][][] seq = new int[k][k][k];
Boolean gameOver = false;
int[] fit = new int[k];
int fam = 0;

void setup() {
  size(800, 600);
  colorMode(RGB, 1);
  frameRate(frmRate);
  stroke(1);
  background(1);
  /*for (int i = 0; i<n*n; i++)
   board[i/n][i%n] = save[i/n][i%n] = (int)(random(1)+0.5);
   */
  for (int i = 0; i<k*k*k; i++) seq[i/k/k][i/k%k][i%k] = (int) (random(1) + 0.5);

  //for (int i = 0; i<500*500; i++) board[i/500][i%500] = (int) (random(1) + 0.5);
  loadBoard(0);

  background(1);
  stroke(0);
  fill(0);
}


void draw() { 
  //Change  genes
  if (gameOver) {
    gameOver = false;
    fit[gen] = generations-30;
    gen++;
    if (gen==k) {
      gen = 2;
      fam++;
      mutation();
    }
    loadBoard(gen);
  }

  //Update screen
  noStroke();
  background(1);
  for (int i = 0; i<n && print; i++)
    for (int j = 0; j<n; j++) {
      fill(board[i][j]);
      rect(i*rectSize, j*rectSize, rectSize, rectSize);
    }
  stroke(0);

  //Game of Life
  for (int i = 0; i<n; i++)
    for (int j = 0; j<n; j++) {
      for (int k = -1; k<=1 && i+k<n && i+k>=0; k++)
        for (int l = -1; l<=1 && j+l<n && j+l>=0; l++) {
          sum += board[i+k][j+l];
        }
      //Rules
      if (sum == 0 && j<n-2 && i-1>=0 && i+1<n) {
        save[i][j+1] = 0;
        if ((board[i-1][j+2]+board[i][j+2]+board[i+1][j+2]) == 3) 
          save[i][j+1] = 1;
        j++;
      } else if (sum == 3 && board[i][j] == 0) save[i][j] = 1;
      else if (sum == 3 || sum == 4 && board[i][j] == 1) save[i][j] = 1;
      else save[i][j] = 0;
      sum = 0;
    }

  //reset
  liveCells = 0;
  generations++;
  for (int i = 0; i<n*n; i++) 
    liveCells+=board[i/n][i%n] = save[i/n][i%n];

  //Game over condiotions
  if (liveCells == lC1 && generations >= 5) lC3 = true;
  if (lC3) lC2++;
  if (lC2>=30) {
    if (liveCells == lC1) {
      gameOver = true;
    }
    lC3 = false;
    lC2 = 0;
  }
  if (!lC3) lC1 = liveCells;

  //print info
  text("Family:\n" + fam, 650, 50);
  text("Generation:\n" + generations, 650, 100);
  text("Live cells:\n" + liveCells, 650, 150);
  text("Fit:\n" + (generations-30), 650, 200);
  text("Gen:\n" + gen, 650, 250);
  for (int i = 0; i<k; i++) text("Fit " + i + "  " + fit[i], 650, 300 + i*20);
}

void loadBoard(int g) {
  generations = 0;
  for (int i = 0; i<n*n; i++) board[i/n][i%n] = save[i/n][i%n] = 0;
  for ( int i = 0; i<k; i++)
    for (int j = 0; j<k; j++)
      board[n/2-k/2+i][n/2-k/2+j] = save[n/2-k/2+i][n/2-k/2+j] = seq[g][i][j];
}

void mutation() {
  int[] pos = new int[2];
  int max = 0;
  for (int j = 0; j<2; j++) {
    max = 0;
    for (int i = 0; i<k; i++) 
      if (fit[i]>max && !(j==1 && i==pos[0])) {
        max = fit[i];
        pos[j] = i;
      }
  }
  int[][]saveseq = new int[k][k];
  for (int j = 0; j<2; j++) {
    for (int i = 0; i<k*k; i++) saveseq[i/k][i%k] = seq[j][i/k][i%k];
    for (int i = 0; i<k*k; i++) seq[j][i/k][i%k] = seq[pos[j]][i/k][i%k];
    for (int i = 0; i<k*k; i++) seq[pos[j]][i/k][i%k] = saveseq[i/k][i%k];
    max = fit[pos[j]];
    fit[pos[j]] = fit[j];
    fit[j] = max;
  }

  for (int i = k/2; i<k; i++)
    for (int j = 0; j<k; j++)
      for (int k = 0; k<k; k++)
        seq[i][j][k] = seq[i-2][i][j];
  //random mutation
  for (int m = 0; m<(int) random(k*k)+1; m++) {
    int i = (int) (random(k-1) + 0.5);
    int j = (int) (random(k-1) + 0.5);
    seq[3][i][j]=(int)(random(1)+0.5);
  }
  //radi dobro
  int m = (int) (random(k-1)+0.5);
  for (int i = 0; i<k; i++) {
    seq[2][m][i] = seq[2][m][k-1-i];
  }
  /*  int k = (int) (random(3) + 0.5);
   int j = (int) (random(3) + 0.5);
   seq[3][k][j] = 0;
   */  //seq[3][k][j] = seq[1][k][j];
  //Cross over radi odlično
  if (fam%5==0) {
    m = (int) (random(4)+0.5);
    for (int i = 0; i<4; i++)
      for (int j = 0; j<4; j++) {
        if (i<m)
          seq[k-1][i][j] = seq[0][i][j];
        else
          seq[k-1][i][j] = seq[1][i][j];
      }
  }
  if (fam%15==0) {
    for (int i = 1; i<4; i++)
      for (int j = 0; j<4; j++)
        for (int o = 0; o<4; o++)
          seq[i][j][o] = (int)(random(1)+0.5);
  }
}


void keyPressed() {
  if (key == 'q') {
    frmRate++;
    frameRate(frmRate);
    println("Framerate: "+frmRate);
  } else if (key == 'a') {
    if (frmRate>1) frmRate--;
    frameRate(frmRate);
    println("Framerate: "+frmRate);
  } else if (key == 'r') {
    gameOver = true;
    //for (int i = 0; i<64; i++) seq[i/16][i/4%4][i%4] = (int) (random(1) + 0.5);
    println("Game reset");
  } else if (key == 'p') {
    println("Family " + fam + "  Gene " + gen + "  Fit " + fit[gen]);
    for (int i = 0; i<k; i++) {
      for (int j = 0; j<k; j++) {
        print(seq[gen][i][j] + " ");
      }
      println();
    }
  } else if (key == 's') {
    print =!print;
  }
}