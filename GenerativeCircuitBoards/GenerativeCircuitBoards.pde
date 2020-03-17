int[][] f;
int wdh;
int hgt;
int s;
PVector o;

int[] clr = {
  #396b56,  //board
  #1e1412,  //chip
  #c37d46,#c37d46,  //cable
  #77452b,  //dark cable
  #183c47,  //dark board
  #183c47,  //light chip
  #c4ab7a,  //light cable
  #769594,  //board light
  #1e1412,  //hole
  };

int c = 0;
int border = 10;
ArrayList<PVector> pnts;
float alpha = 0;
boolean[] diag;
int frame = 0;

boolean SAVE_TO_PNG = false;

void setup() {
  size(1000,1000);
  textSize(50);
  noStroke();
  wdh = 100;
  hgt = 100;
  f = new int[wdh][hgt];
  s = 10;
  o = new PVector(0,0);
  
  //initialize board
  for(int x=0;x<wdh;x++) {
    for(int y=0;y<hgt;y++) {
      f[x][y] = 0;
    }
  }
  
  alpha = 0;
  pnts = new ArrayList<PVector>();
  
  //place chips and pins
  for(int x=0;x<wdh;x++) {
    for(int y=0;y<hgt;y++) {
      if(x>=5&&x<wdh-16&&y>=5&&y<hgt-16) {
        if(random(0,1)<0.005) {
          int bwdh = int(random(1,5))*2+1;
          int bhgt = int(random(1,5))*2+1;
          
          //keep distance between chips
          boolean wall = false;
          for(int i=-5;i<bwdh+5;i++) {
            for(int j=-5;j<bhgt+5;j++) {
              if(f[x+i][y+j] == 1) {
                wall = true;
              }
            }
          }
          
          if(wall) {
            continue;
          }
          
          for(int i=0;i<bwdh;i++) {
            for(int j=0;j<bhgt;j++) {
              f[x+i][y+j] = 1;
            }
          }
          
          //add pins
          int a = int(random(1,3));
          a = (random(0,1)<0.2)?3:a;
          int ax = a&1;
          int ay = a&2;
          
          for(int i=-ax;i<bwdh+ax;i++) {
            for(int j=-ay;j<bhgt+ay;j++) {
              if((i+1)%2==0 && (j+1)%2==0 &&
                 f[x+i][y+j]==0 && getMoore(x+i,y+j,1,1) > 1) {
                f[x+i][y+j] = 3;
              }
            }
          }
        }
      }
    }
  }
  diag = new boolean[(wdh+hgt)*2];
  baseStyle();
  frameCount = 0;
}

void draw() {
  background(0);
  for(int x=0;x<wdh;x++) {
    for(int y=0;y<hgt;y++) {
      fill(clr[f[x][y]]);
      rect(o.x+x*s,o.y+y*s,s,s);
    }
  }
  
  boolean change = false;
  if(frameCount < 20) {
    for(int o=0;o<100;o++) {
      if(processDraw() && !change) {
        change = true;
      }
    }
  } else if(frameCount == 20) {
    style();
  }
  if(frameCount >= 20) {
    restyle();
    change = true;
  }
  
  if(SAVE_TO_PNG && change) {
    save("../Results/frame"+frame+".png");
    frame++;
  }
  if(SAVE_TO_PNG && frameCount == 30) {
    mousePressed();
  }
}

void mousePressed() {
  setup();
}

void style() {
  for(int i=0;i<diag.length;i++) {
    diag[i] = false;
    if(random(0,1) < 0.1) {
      for(int j=0;j<4;j++) {
        if(i-j >= 0) {
          diag[i-j] = true;
        }
      }
    }
  }
  
  for(int x=0;x<wdh;x++) {
    for(int y=0;y<hgt;y++) {
      if(f[x][y] == 3) {
        f[x][y] = 2;
      }
      
      boolean shade = (y-1 >= 0 && x-1 >= 0 && f[x-1][y-1] == 1);
      if(shade) {
        if(f[x][y] == 0) {
          f[x][y] = 5;
        } else if(f[x][y] == 2) {
          f[x][y] = 4;
        }
      }
      boolean light_a = (y+1 < hgt && x+1 < wdh && f[x+1][y+1] == 1);
      boolean light_b = (y-1 >= 0 && x-1 >= 0 && 
        f[x-1][y-1] != 1 && f[x-1][y-1] != 6);
      if(light_a && light_b) {
        if(f[x][y] == 1) {
          f[x][y] = 6;
        }
      }
      
      if(f[x][y] == 2) {
        if(diag[x+y]) {
          f[x][y] = 7;
        }
      }
    }
  }
  baseStyle();
}

void baseStyle() {
  //draw holes
  for(int x=2;x<wdh;x+=wdh-6) {
    for(int y=2;y<hgt;y+=hgt-6) {
      for(int i=0;i<2;i++) {
        for(int j=0;j<2;j++) {
          f[x+i][y+j] = 9;
        }
      }
    }
  }
  //style board
  for(int x=0;x<wdh;x++) {
    for(int y=0;y<hgt;y++) {
      if(x==0 || y==0) {
        f[x][y] = 8;
      }
      if(x==wdh-1 || y==hgt-1) {
        f[x][y] = 5;
      }
    }
  }
  f[0][hgt-1] = 0;
  f[wdh-1][0] = 0;
}

void restyle() {
  //draw copper highlights
  for(int x=0;x<wdh;x++) {
    for(int y=0;y<hgt;y++) {
      if(f[x][y] == 7) {
        f[x][y] = 2;
      }
      
      if(f[x][y] == 2) {
        float fac = (-sin(alpha)+1.0)/2.0;
        if(diag[x+y+int(fac*(wdh+hgt))]) {
          f[x][y] = 7;
        }
      }
    }
  }
  alpha += 0.01;
}

boolean processDraw() {
  //find all pins
  pnts.clear();
  for(int x=0;x<wdh;x++) {
    for(int y=0;y<hgt;y++) {
      if(f[x][y] == 3) {
        pnts.add(new PVector(x,y));
      }
    }
  }
  
  //select random starting pin
  PVector start = pnts.get(
    int(random(0,pnts.size())));
  ArrayList<PVector> ends = new ArrayList<PVector>();
  
  //find all end pins in range
  for(int i=0;i<pnts.size();i++) {
    float dist = dist(start.x,start.y,
                 pnts.get(i).x,
                 pnts.get(i).y);
    if(dist > 9 && dist < 50) {
      ends.add(pnts.get(i));
    }
  }
  
  if(ends.size() == 0) {
    return false;
  }
  
  PVector end = ends.get(
    int(random(0,ends.size())));
  
  f[int(end.x)][int(end.y)] = 4;
  
  //start backtracking "labyrinth" solver
  c = 0;
  if(!drawCable(int(start.x),int(start.y),end,0)) {
    f[int(start.x)][int(start.y)] = 3;
    f[int(end.x)][int(end.y)] = 3;
    return false;
  } else {
    f[int(end.x)][int(end.y)] = 2;
    return true;
  }
}

boolean drawCable(int sx, int sy,PVector end,int lvl) {
  f[sx][sy] = 2;
  c++;
  if(c > 50) { //force break from recursion
    return false;
  }
  
  //calculate right direction
  float d1 = end.x-sx;
  float d2 = end.y-sy;
  PVector t1 = new PVector(sign(d1),0);
  PVector t2 = new PVector(0,sign(d2));
  PVector t3 = new PVector(-t1.x,0);
  PVector t4 = new PVector(0,-t2.y);
  ArrayList<PVector> off = new ArrayList<PVector>();
  off.add(t1);
  off.add(t2);
  off.add(t3);
  off.add(t4);
  
  int[] ids = new int[4];
  if(abs(d1) != 0 && abs(d1) < abs(d2)) {
    ids[0] = 1;
  } else {
    ids[0] = 0;
  }
  
  ids[1] = 1-ids[0];
  ids[2] = 2+ids[0];
  ids[3] = 2+ids[1];
  
  //test directions
  for(int i=0;i<4;i++) {
    int px = int(sx+off.get(ids[i]).x);
    int py = int(sy+off.get(ids[i]).y);
    if(testDirection(px,py)) {
      if(drawCable(px,py,end,lvl+1)) {
        return true;
      } else {
        f[px][py] = 0;
      }
    } else if(px == int(end.x) &&
              py == int(end.y)) {
      return true;
    }
  }
  return false;
}

boolean testDirection(int px,int py) { //decisions on where cables can go
  if(px>=border&&px<wdh-border&&
     py>=border&&py<hgt-border) {
    if(getMoore(px,py,1,1) == 0) {
      if(getVonNeumann(px,py,2) <= 1) {
        if(getMoore(px,py,3,1) == 0) {
          if(getMoore(px,py,2,1) <= 2) {
            if(!getWrongMoore(px,py,2)) {
              if(f[px][py] == 0) {
                return true;
              }
            }
          }
        }
      }
    }
  }
  return false;
}

int getMoore(int x,int y,int t,int r) { //amount of tiles 't' in a Moore-neighborhood with radius r
  int res = 0;
  for(int i=-r;i<r+1;i++) {
    for(int j=-r;j<r+1;j++) {
      if(i*j != i+j) {
        int px = x+i;
        int py = y+j;
        if(goodCoords(px,py)) {
          if(f[px][py] == t) {
            res++;
          }
        }
      }
    }
  }
  return res;
}

int getVonNeumann(int x,int y,int t) { //amount of tiles 't' in a Von-Neumann-neighborhood
  int res = 0;
  for(int i=-1;i<2;i++) {
    for(int j=-1;j<2;j++) {
      if(abs(i+j) == 1) {
        int px = x+i;
        int py = y+j;
        if(goodCoords(px,py)) {
          if(f[px][py] == t) {
            res++;
          }
        }
      }
    }
  }
  return res;
}

boolean getWrongMoore(int x,int y,int t) { //don't allow cables connecting diagonally
  for(int i=-1;i<2;i++) {
    for(int j=-1;j<2;j++) {
      if(i!=0 && j!=0) {
        int px = x+i;
        int py = y+j;
        if(goodCoords(px,py)) {
          if(f[px][py] == t) {
            if(f[x][py] == t) {
            } else if(f[px][y] == t) {
            } else {
              return true;
            }
          }
        }
      }
    }
  }
  return false;
}

boolean goodCoords(int px,int py) { //"constrains" the coordinates to the size of the board
  return px>=0&&px<wdh&&py>=0&&py<hgt;
}

float sign(float f) { //why is this not a Processing standard?
  return (f<0)?-1:1;
}
