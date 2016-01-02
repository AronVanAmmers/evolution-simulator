/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/205807*@* */
/* !do not delete the line above, required for linking your tweak if you upload again */
// Last edited January 17, 2013, UNTIL I brought it back on June 19, 2015!

//These are the easy-to-edit variables.
final boolean USE_RANDOM_SEED = false;
// determines whether random factors will be determined by the preset seed.
//If this is false, the program will run differently every time.  If it's true, it will run exactly the same.
final int SEED = 38;
final float WINDOW_SIZE = 1.0; // window size multiplier.  If it's 1, the size is 1280x720.
// The seed that determines all random factors in the simulation. Same seed = same simulation results,
// different seed = different simulation results.  Make sure USE_RANDOM_SEED is true for this.
final float SORT_ANIMATION_SPEED = 5.0; // Determines speed of sorting animation.  Higher number is faster.
final float MINIMUM_NODE_SIZE = 0.1; // Note: all units are 20 cm.  Meaning, a value of 1 equates to a 20 cm node.
final float MAXIMUM_NODE_SIZE = 1;
final float MINIMUM_NODE_FRICTION = 0.0;
final float MAXIMUM_NODE_FRICTION = 1.0;
final float GRAVITY = 0.005; // higher = more friction.
final float AIR_FRICTION = 0.95; // The lower the number, the more friction.  1 = no friction.  Above 1 = chaos.
final float MUTABILITY_FACTOR = 1.05; // How fast the creatures mutate.  1 is normal.

// Minimum amount of nodes per creature. Creatures will never mutate below
// this amount of nodes.
final int CREATURE_MIN_NODES = 8;
// Minimum amount of muscles per creature. This isn't always respected as sometimes
// muscles have to be removed in case of an invalid structure (see checkForOverlap())
final int CREATURE_MIN_MUSCLES = 8;

// The amount of seconds the simulation runs and is counted for fitness.
final int SIMULATION_SECONDS = 30;

final boolean haveGround = true;  // true if the ground exists, false if no ground.

// Log debug messages
final boolean DEBUG = true;

// Speed for showing the creature previews. 1 = real time, 2 = 2x speed, etc. If preview animations
// are slow on your system, increase this value.
final int MINI_SIMULATION_SPEED = 2;

//Add rectangular obstacles by filling up this array of rectangles.  The parameters are x1, y1, x2, y2, specifying
// two opposite vertices.  NOTE: The units are 20 cm, so 1 = 20 cm, and 5 = 1 m.
// ALSO NOTE: y-values increase as you go down.  So 3 is in the air, and -3 is in the ground.  0 is the surface.
final Rectangle[] RECTANGLES = {
// Lower stairs
new Rectangle(2,-0.2,7,1),
new Rectangle(4,-0.4,9,1),
new Rectangle(6,-0.6,11,1),
new Rectangle(8,-0.8,13,1),
new Rectangle(10,-1,15,1),
new Rectangle(12,-1.2,17,1),
new Rectangle(14,-1.4,19,1),
new Rectangle(16,-1.6,21,1),
new Rectangle(18,-1.8,23,1),
new Rectangle(20,-2.0,25,1)
};

// Whether to randomize the rectangles
final boolean RANDOMIZE_RECTANGLES = true;
// Mutability factor for randomizing the rectangles.
final float RECTANGLES_MUTABILITY_FACTOR = 1.2;

float histMinValue = -1; //histogram information
float histMaxValue = 8;
int histBarsPerMeter = 10;

// Okay, that's all the easy to edit stuff.

final int FRAMES_PER_SECOND = 60;
final int SIMULATION_FRAMES = SIMULATION_SECONDS * FRAMES_PER_SECOND;

PFont font;
ArrayList<Float[]> percentile = new ArrayList<Float[]>(0);
ArrayList<Integer[]> barCounts = new ArrayList<Integer[]>(0);
ArrayList<Integer[]> speciesCounts = new ArrayList<Integer[]>(0);
ArrayList<Integer> topSpeciesCounts = new ArrayList<Integer>(0);
ArrayList<Creature> creatureDatabase = new ArrayList<Creature>(0);
ArrayList<Rectangle> rects = new ArrayList<Rectangle>(0);
// Historical rectangles in case of rectangles randomization. The index is the 
// generation number.
ArrayList<ArrayList<Rectangle>> rectsHistory = new ArrayList<ArrayList<Rectangle>>(0);
PGraphics graphImage;
PGraphics screenImage;
PGraphics popUpImage;
PGraphics segBarImage;
// 0 = 100th percentile
// 1 = 90th percentile
//     ...
// 8 = 20th percentile
// 9 = 10th percentile
// 10 = 9th percentile
// 11 = 8th percentile
//     ...
// 19 = 0th percentile
final float FRICTION = 4;
int minBar = int(histMinValue*histBarsPerMeter);
int maxBar = int(histMaxValue*histBarsPerMeter);
int barLen = maxBar-minBar;
int gensToDo = 0;
float cTimer = 60;

int windowWidth = 1280;
int windowHeight = 720;
int timer = 0;
float cam = 0;
int frames = 60;
int menu = 0;
// The current generation
int gen = -1;
float sliderX = 1170;
int genSelected = 0;
boolean drag = false;
boolean justGotBack = false;
int creatures = 0;
int creaturesTested = 0;
int fontSize = 0;
int[] fontSizes = {50,36,25,20,16,14,11,9};
int statusWindow = -4;
int overallTimer = 0;
boolean miniSimulation = false;
int creatureWatching = 0;
int simulationTimer = 0;
int[] creaturesInPosition = new int[1000];

float camzoom = 0.015;

float target;
float force;
float average;
int speed;
int id;
boolean stepbystep;
boolean stepbystepslow;
boolean slowDies;
int timeShow;
int[] p = {0,10,20,30,40,50,60,70,80,90,
100,200,300,400,500,600,700,800,900,910,920,930,940,950,960,970,980,990,999};

float inter(int a, int b, float offset){
  return float(a)+(float(b)-float(a))*offset;
}
float r(){
  return pow(random(-1,1),19);
}
int rInt(){
  return int(random(-0.01,1.01));
}
class Rectangle{
  float x1, y1, x2, y2;
  Rectangle(float tx1, float ty1, float tx2, float ty2){
    x1 = tx1;
    y1 = ty1;
    x2 = tx2;
    y2 = ty2;
  }
}
class Node{
  float x, y, vx, vy, m, f;
  Node(float tx, float ty, float tvx, float tvy, float tm, float tf){
    x = tx;
    y = ty;
    vx = tvx;
    vy = tvy;
    m = tm;
    f = tf;
  }
  void applyForces(int i){
    Node ni = n.get(i);
    ni.vx *= AIR_FRICTION;
    ni.vy *= AIR_FRICTION;
    ni.y += ni.vy;
    ni.x += ni.vx;
  }
  void applyGravity(int i){
    Node ni = n.get(i);
    ni.vy += GRAVITY;
  }
  void hitWalls(int index){
    Node ni = n.get(index);
    float dif = ni.y+ni.m/2;
    if(dif >= 0 && haveGround){
      ni.y = -ni.m/2;
      ni.vy = 0;
      ni.x -= ni.vx*ni.f;
      if(ni.vx > 0){
        ni.vx -= ni.f*dif*FRICTION;
        if(ni.vx < 0){
          ni.vx = 0;
        }
      }else{
        ni.vx += ni.f*dif*FRICTION;
        if(ni.vx > 0){
          ni.vx = 0;
        }
      }
    }
    for(int i = 0; i < rects.size(); i++){
      Rectangle r = rects.get(i);
      boolean flip = false;
      float px, py;
      int section = 0;
      if(abs(ni.x-(r.x1+r.x2)/2) <= (r.x2-r.x1+ni.m)/2 && abs(ni.y-(r.y1+r.y2)/2) <= (r.y2-r.y1+ni.m)/2){
        if(ni.x >= r.x1 && ni.x < r.x2 && ni.y >= r.y1 && ni.y < r.y2){
          float d1 = ni.x-r.x1;
          float d2 = r.x2-ni.x;
          float d3 = ni.y-r.y1;
          float d4 = r.y2-ni.y;
          if(d1 < d2 && d1 < d3 && d1 < d4){
            px = r.x1;
            py = ni.y;
            section = 3;
          }else if(d2 < d3 && d2 < d4){
            px = r.x2;
            py = ni.y;
            section = 5;
          }else if(d3 < d4){
            px = ni.x;
            py = r.y1;
            section = 1;
          }else{
            px = ni.x;
            py = r.y2;
            section = 7;
          }
          flip = true;
        }else{
          if(ni.x < r.x1){
            px = r.x1;
            section = 0;
          }else if(ni.x < r.x2){
            px = ni.x;
            section = 1;
          }else{
            px = r.x2;
            section = 2;
          }
          if(ni.y < r.y1){
            py = r.y1;
            section += 0;
          }else if(ni.y < r.y2){
            py = ni.y;
            section += 3;
          }else{
            py = r.y2;
            section += 6;
          }
        }
        float distance = dist(ni.x,ni.y,px,py);
        float rad = ni.m/2;
        float wallAngle = 0;
        if(distance <= 0.00000001){ // distance is zero, can't use atan2
          if(section <= 2){
            wallAngle = PI/4.0 + section*PI/4.0;
          }else if(section >= 6){
            wallAngle = 5*PI/4.0 + (8-section)*PI/4.0;
          }else if(section == 3){
            wallAngle = PI;
          }else if(section == 5 || section == 4){
            wallAngle = 0;
          }
          flip = false;
        }else{
          wallAngle = atan2(py-ni.y,px-ni.x);
        }
        if(flip){
          wallAngle += PI;
        }
        if(distance < rad || flip){
          dif = rad-distance;
          float multi = rad/distance;
          if(flip){
            multi = -multi;
          }
          ni.x = (ni.x-px)*multi+px;
          ni.y = (ni.y-py)*multi+py;
          float veloAngle = atan2(ni.vy,ni.vx);
          float veloMag = dist(0,0,ni.vx,ni.vy);
          float relAngle = veloAngle-wallAngle;
          float relY = sin(relAngle)*veloMag*dif*FRICTION;
          ni.vx = -sin(relAngle)*relY;
          ni.vy = cos(relAngle)*relY;
        }
      }
    }
  }
  Node copyNode(){
    return (new Node(x,y,0,0,m,f));
  }
  Node modifyNode(float mutability){
    float newX = x+r()*0.5*mutability*MUTABILITY_FACTOR;
    float newY = y+r()*0.5*mutability*MUTABILITY_FACTOR;
    float newM = m+r()*0.1*mutability*MUTABILITY_FACTOR;
    newM = min(max(newM,MINIMUM_NODE_SIZE),MAXIMUM_NODE_SIZE);
    float newF = f+r()*0.1*mutability*MUTABILITY_FACTOR;
    newF = min(max(newF,MINIMUM_NODE_FRICTION),MAXIMUM_NODE_FRICTION);
    return (new Node(newX,newY,0,0,newM,newF));//max(m+r()*0.1,0.2),min(max(f+r()*0.1,0),1)
  }
}
class Muscle{
  int period, c1, c2;
  float contractTime,contractLength, extendTime, extendLength;
  float thruPeriod;
  boolean contracted;
  float rigidity;
  Muscle(int tperiod, int tc1, int tc2, float tcontractTime,
  float textendTime, float tcontractLength, float textendLength, boolean tcontracted, float trigidity){
    period  = tperiod;
    c1 = tc1;
    c2 = tc2;
    contractTime = tcontractTime;
    extendTime = textendTime;
    contractLength = tcontractLength;
    extendLength = textendLength;
    contracted = tcontracted;
    rigidity = trigidity;
  }
  void applyForce(int i, float target){
    Node ni1 = n.get(c1);
    Node ni2 = n.get(c2);
    float distance = dist(ni1.x,ni1.y,ni2.x,ni2.y);
    float angle = atan2(ni1.y-ni2.y,ni1.x-ni2.x);
    force = min(max(1-(distance/target),-0.4),0.4);
    ni1.vx += cos(angle)*force*rigidity/ni1.m;
    ni1.vy += sin(angle)*force*rigidity/ni1.m;
    ni2.vx -= cos(angle)*force*rigidity/ni2.m;
    ni2.vy -= sin(angle)*force*rigidity/ni2.m;
  }
  Muscle copyMuscle(){
    return new Muscle(period,c1,c2,contractTime,extendTime,
    contractLength,extendLength,contracted,rigidity);
  }
  Muscle modifyMuscle(int nodeNum,float mutability){
    int newc1 = c1;
    int newc2 = c2;
    if(random(0,1)<0.02*mutability*MUTABILITY_FACTOR){
      newc1 = int(random(0,nodeNum));
    }
    if(random(0,1)<0.02*mutability*MUTABILITY_FACTOR){
      newc2 = int(random(0,nodeNum));
    }
    float newR = min(max(rigidity*(1+r()*0.9*mutability*MUTABILITY_FACTOR),0.01),0.08);
    float maxMuscleChange = 1+0.025/newR;
    float newCL = min(max(contractLength+r()*mutability*MUTABILITY_FACTOR,0.4),2);
    float newEL = min(max(extendLength+r()*mutability*MUTABILITY_FACTOR,0.4),2);
    float newCL2 = min(newCL,newEL);
    float newEL2 = min(max(newCL,newEL),newCL2*maxMuscleChange);
    float newCT = contractTime;
    float newET = extendTime;
    if(random(0,1) < 0.5){ //contractTime is changed
      newCT = ((contractTime-extendTime)*r()*mutability*MUTABILITY_FACTOR+newCT+1)%1;
    }else{ //extendTime is changed
      newET = ((extendTime-contractTime)*r()*mutability*MUTABILITY_FACTOR+newET+1)%1;
    }
    return new Muscle(max(period+rInt(),0),
    newc1,newc2,newCT,newET,newCL2,newEL2,isItContracted(newCT,newET),newR);
  }
}
class Creature{
  ArrayList<Node> n;
  ArrayList<Muscle> m;
  float d;
  int id;
  boolean alive;
  float creatureTimer;
  float mutability;
  Creature(int tid, ArrayList<Node> tn, ArrayList<Muscle> tm, float td, boolean talive, float tct, float tmut){
    id = tid;
    m = tm;
    n = tn;
    d = td;
    alive = talive;
    creatureTimer = tct;
    mutability = tmut;
  }
  Creature modified(int id){
    Creature modifiedCreature = new Creature(id,
    new ArrayList<Node>(0),new ArrayList<Muscle>(0),0,true,
    creatureTimer+r()*16*mutability*MUTABILITY_FACTOR,min(mutability*MUTABILITY_FACTOR*random(0.8,1.25),2));
    for(int i = 0; i < n.size(); i++){
      modifiedCreature.n.add(n.get(i).modifyNode(mutability));
    }
    for(int i = 0; i < m.size(); i++){
      modifiedCreature.m.add(m.get(i).modifyMuscle(n.size(),mutability));
    }
    if(random(0,1) < 0.04*mutability*MUTABILITY_FACTOR || n.size() <= CREATURE_MIN_NODES - 1){ //Add a node
      modifiedCreature.addRandomNode();
    }
    if(random(0,1) < 0.04*mutability*MUTABILITY_FACTOR){ //Add a muscle
      modifiedCreature.addRandomMuscle(-1,-1);
    }
    if(random(0,1) < 0.04*mutability*MUTABILITY_FACTOR && modifiedCreature.n.size() >= CREATURE_MIN_NODES + 1){ //Remove a node
      modifiedCreature.removeRandomNode();
    }
    if(random(0,1) < 0.04*mutability*MUTABILITY_FACTOR && modifiedCreature.m.size() >= CREATURE_MIN_MUSCLES + 1){ //Remove a muscle
      modifiedCreature.removeRandomMuscle();
    }
    modifiedCreature.checkForOverlap();
    modifiedCreature.checkForLoneNodes();
    return modifiedCreature;
  }
  void checkForOverlap(){
    ArrayList<Integer> bads = new ArrayList<Integer>();
    for(int i = 0; i < m.size(); i++){
      for(int j = i+1; j < m.size(); j++){
        if(m.get(i).c1 == m.get(j).c1 && m.get(i).c2 == m.get(j).c2){
          bads.add(i);
        }else if(m.get(i).c1 == m.get(j).c2 && m.get(i).c2 == m.get(j).c1){
          bads.add(i);
        }else if(m.get(i).c1 == m.get(i).c2){
          bads.add(i);
        }
      }
    }
    for(int i = bads.size()-1; i >= 0; i--){
      int b = bads.get(i)+0;
      if(b < m.size()){
        m.remove(b);
      }
    }
  }
  void checkForLoneNodes(){
    if(n.size() >= 3){
      for(int i = 0; i < n.size(); i++){
        int connections = 0;
        int connectedTo = -1;
        for(int j = 0; j < m.size(); j++){
          if(m.get(j).c1 == i){
            connections++;
            connectedTo = m.get(j).c2;
          }else if(m.get(j).c2 == i){
            connections++;
            connectedTo = m.get(j).c1;
          }
        }
        if(connections <= 1){
          int newConnectionNode = floor(random(0,n.size()));
          while(newConnectionNode == i || newConnectionNode == connectedTo){
            newConnectionNode = floor(random(0,n.size()));
          }
          addRandomMuscle(i,newConnectionNode);
        }
      }
    }
  }
  void addRandomNode(){
    int parentNode = floor(random(0,n.size()));
    float ang1 = random(0,2*PI);
    float distance = sqrt(random(0,1));
    float x = n.get(parentNode).x+cos(ang1)*0.5*distance;
    float y = n.get(parentNode).y+sin(ang1)*0.5*distance;
    n.add(new Node(x,y,0,0,random(MINIMUM_NODE_SIZE,MAXIMUM_NODE_SIZE),
    random(MINIMUM_NODE_FRICTION,MAXIMUM_NODE_FRICTION))); //random(0.1,1),random(0,1)
    int nextClosestNode = 0;
    float record = 100000;
    for(int i = 0; i < n.size()-1; i++){
      if(i != parentNode){
        float dx = n.get(i).x-x;
        float dy = n.get(i).y-y;
        if(sqrt(dx*dx+dy*dy) < record){
          record = sqrt(dx*dx+dy*dy);
          nextClosestNode = i;
        }
      }
    }
    addRandomMuscle(parentNode,n.size()-1);
    addRandomMuscle(nextClosestNode,n.size()-1);
  }
  void addRandomMuscle(int tc1, int tc2){
    if(tc1 == -1){
      tc1 = int(random(0,n.size()));
      tc2 = tc1;
      while(tc2 == tc1 && n.size() >= 2){
        tc2 = int(random(0,n.size()));
      }
    }
    float rlength1 = random(0.5,1.5);
    float rlength2 = random(0.5,1.5);
    float rtime1 = random(0,1);
    float rtime2 = random(0,1);
    if(tc1 != -1){
      float distance = dist(n.get(tc1).x,n.get(tc1).y,n.get(tc2).x,n.get(tc2).y);
      float ratio = random(0.01,0.2);
      rlength1 = distance*(1-ratio);
      rlength2 = distance*(1+ratio);
    }
    m.add(new Muscle(int(random(1,3)),tc1,tc2,rtime1,rtime2,
    min(rlength1,rlength2),max(rlength1,rlength2),isItContracted(rtime1,rtime2),random(0.02,0.08)));
  }
  void removeRandomNode(){
    int choice = floor(random(0,n.size()));
    n.remove(choice);
    int i = 0;
    while(i < m.size()){
      if(m.get(i).c1 == choice || m.get(i).c2 == choice){
        m.remove(i);
      }else{
        i++;
      }
    }
    for(int j = 0; j < m.size(); j++){
      if(m.get(j).c1 >= choice){
        m.get(j).c1--;
      }
      if(m.get(j).c2 >= choice){
        m.get(j).c2--;
      }
    }
  }
  void removeRandomMuscle(){
    int choice = floor(random(0,m.size()));
    m.remove(choice);
  }
  Creature copyCreature(int newID){
    ArrayList<Node> n2 = new ArrayList<Node>(0);
    ArrayList<Muscle> m2 = new ArrayList<Muscle>(0);
    for(int i = 0; i < n.size(); i++){
      n2.add(n.get(i).copyNode());
    }
    for(int i = 0; i < m.size(); i++){
      m2.add(m.get(i).copyMuscle());
    }
    if(newID == -1){
      newID = id;
    }
    return new Creature(newID,n2,m2,d,alive,creatureTimer,mutability);
  }
}
void drawGround(int toImage){
  if(toImage == 0){
    noStroke();
    fill(0,130,0);
    if(haveGround) rect(0,windowHeight*0.8,windowWidth,windowHeight*0.2);
    for(int i = 0; i < rects.size(); i++){
      Rectangle r = rects.get(i);
      rect(r.x1/camzoom-cam/camzoom+windowWidth/2,r.y1/camzoom+windowHeight*0.8,(r.x2-r.x1)/camzoom,(r.y2-r.y1)/camzoom);
    }
  }else if(toImage == 2){
    popUpImage.noStroke();
    popUpImage.fill(0,130,0);
    if(haveGround) popUpImage.rect(0,360,450,90);
    float ww = 450;
    float wh = 450;
    for(int i = 0; i < rects.size(); i++){
      Rectangle r = rects.get(i);
      popUpImage.rect(r.x1/camzoom-cam/camzoom+ww/2,r.y1/camzoom+wh*0.8,(r.x2-r.x1)/camzoom,(r.y2-r.y1)/camzoom);
    }
  }
}
void drawNode(Node ni, float x, float y,int toImage){
  color c = color(512-int(ni.f*512),0,0);
  if(ni.f <= 0.5){
    c = color(255,255-int(ni.f*512),255-int(ni.f*512));
  }
  if(toImage == 0){
    fill(c);
    noStroke();
    ellipse(ni.x/camzoom+x,ni.y/camzoom+y,ni.m/camzoom,ni.m/camzoom);
  }else if(toImage == 1){
    screenImage.fill(c);
    screenImage.noStroke();
    screenImage.ellipse(ni.x/camzoom+x,ni.y/camzoom+y,ni.m/camzoom,ni.m/camzoom);
  }else if(toImage == 2){
    popUpImage.fill(c);
    popUpImage.noStroke();
    popUpImage.ellipse(ni.x/camzoom+x,ni.y/camzoom+y,ni.m/camzoom,ni.m/camzoom);
  }
}
void drawMuscle(Muscle mi, Node ni1, Node ni2, float x,float y,int toImage){
  boolean c = mi.contracted;
  float w = 0.1/camzoom;
  if(c){
    w = 0.2/camzoom;
  }
  if(toImage == 0){
    strokeWeight(w);
    stroke(70,35,0,mi.rigidity*3000);
    line(ni1.x/camzoom+x, ni1.y/camzoom+y, ni2.x/camzoom+x, ni2.y/camzoom+y);
  }else if(toImage == 1){
    screenImage.strokeWeight(w);
    screenImage.stroke(70,35,0,mi.rigidity*3000);
    screenImage.line(ni1.x/camzoom+x, ni1.y/camzoom+y, ni2.x/camzoom+x, ni2.y/camzoom+y);
  }else if(toImage == 2){
    popUpImage.strokeWeight(w);
    popUpImage.stroke(70,35,0,mi.rigidity*3000);
    popUpImage.line(ni1.x/camzoom+x, ni1.y/camzoom+y, ni2.x/camzoom+x, ni2.y/camzoom+y);
  }
}
void drawPosts(int toImage){
  if(toImage == 0){
    noStroke();
    for(int i = int((-cam*camzoom-windowWidth/2)/5)-1;
    i <= int((-cam*camzoom+windowWidth/2)/5)+1; i++){
      fill(255);
      rect(windowWidth/2+(i*5-cam-0.1)/camzoom,windowHeight*0.8-3/camzoom,0.2/camzoom,3/camzoom);
      rect(windowWidth/2+(i*5-cam-1)/camzoom,windowHeight*0.8-3/camzoom,2/camzoom,1/camzoom);
      fill(120);
      text(i+" m",windowWidth/2+(i*5-cam)/camzoom,windowHeight*0.8-2.17/camzoom);
    }
  }else if(toImage == 2){
    popUpImage.textAlign(CENTER);
    popUpImage.textFont(font, 0.96/camzoom);
    popUpImage.noStroke();
    float w = 450;
    float h = 450;
    for(int i = int((-cam*camzoom-w/2)/5)-1;
    i <= int((-cam*camzoom+w/2)/5)+1; i++){
      popUpImage.fill(255);
      popUpImage.rect(w/2+(i*5-cam-0.1)/camzoom,h*0.8-3/camzoom,0.2/camzoom,3/camzoom);
      popUpImage.rect(w/2+(i*5-cam-1)/camzoom,h*0.8-3/camzoom,2/camzoom,1/camzoom);
      popUpImage.fill(120);
      popUpImage.text(i+" m",w/2+(i*5-cam)/camzoom,h*0.8-2.17/camzoom);
    }
  }
}
void drawArrow(float x){
  noStroke();
  fill(120,0,255);
  rect(windowWidth/2+(x-cam-1.7)/camzoom,windowHeight*0.8-4.8/camzoom,3.4/camzoom,1.1/camzoom);
  beginShape();
  vertex(windowWidth/2+(x-cam)/camzoom,windowHeight*0.8-3.2/camzoom);
  vertex(windowWidth/2+(x-cam-0.5)/camzoom,windowHeight*0.8-3.7/camzoom);
  vertex(windowWidth/2+(x-cam+0.5)/camzoom,windowHeight*0.8-3.7/camzoom);
  endShape(CLOSE);
  fill(255);
  text((float(round(x*2))/10)+" m",windowWidth/2+(x-cam)/camzoom,windowHeight*0.8-3.91/camzoom);
}
void drawGraphImage(){
  image(graphImage,50,180,650,380);
  image(segBarImage,50,580,650,100);
  if(gen >= 1){
    stroke(0,160,0,255);
    strokeWeight(3);
    float genWidth = float(610)/gen;
    float lineX = 90+genSelected*genWidth;
    line(lineX,180,lineX,500+180);
    Integer[] s = speciesCounts.get(genSelected);
    textAlign(LEFT);
    textFont(font,12);
    noStroke();
    for(int i = 1; i < 101; i++){
      int c = s[i]-s[i-1];
      if(c >= 25){
        float y = ((s[i]+s[i-1])/2)/1000.0*100+573;
        if(i-1 == topSpeciesCounts.get(genSelected)){
          stroke(0);
          strokeWeight(2);
        }else{
          noStroke();
        }
        fill(255,255,255);
        rect(lineX+10,y,50,14);
        colorMode(HSB,1.0);
        fill(getColor(i-1,true));
        text("S"+floor((i-1)/10)+""+((i-1)%10)+": "+c,lineX+11,y+12);
        colorMode(RGB,255);
      }
    }
    noStroke();
  }
}
color getColor(int i, boolean adjust){
  colorMode(HSB,1.0);
  float col = (i*1.618034)%1;
  if(i == 46){
    col = 0.083333;
  }else if(i == 44){
    col = 0.1666666;
  }else if(i == 57){
    col = 0.5;
  }
  float light = 1.0;
  if(abs(col-0.333) <= 0.18 && adjust){
    light = 0.7;
  }
  return color(col,1.0,light);
}
void drawGraph(int graphWidth, int graphHeight){
  drawLines(60,int(graphHeight*0.05),graphWidth-60,int(graphHeight*0.9));
  if(gen >= 1){
    drawSegBars(60,0,graphWidth-60,150);
  }
}
void drawLines(int x, int y, int graphWidth, int graphHeight){
  graphImage.beginDraw();
  graphImage.smooth();
  graphImage.background(220);
  if(gen >= 1){
    float gh = float(graphHeight);
    float genWidth = float(graphWidth)/gen;
    float best = extreme(1);
    float worst = extreme(-1);
    float meterHeight = float(graphHeight)/(best-worst);
    float zero = (best/(best-worst))*gh;
    float unit = setUnit(best, worst);
    graphImage.stroke(150);
    graphImage.strokeWeight(2);
    graphImage.fill(150);
    graphImage.textFont(font, 18);
    graphImage.textAlign(RIGHT);
    for(float i = ceil((worst-(best-worst)/18.0)/unit)*unit; i < best+(best-worst)/18.0;i+=unit){
      float lineY = y-i*meterHeight+zero;
      graphImage.line(x,lineY,graphWidth+x,lineY);
      graphImage.text(showUnit(i,unit)+" m",x-5,lineY+4);
    }
    graphImage.stroke(0);
    for(int i = 0; i < 29; i++){
      int k;
      if(i == 28){
        k = 14;
      }else if(i < 14){
        k = i;
      }else{
        k = i+1;
      }
      if(k == 14){
        graphImage.stroke(255,0,0,255);
        graphImage.strokeWeight(5);
      }else{
        stroke(0);
        if(k == 0 || k == 28 || (k >= 10 && k <= 18)){
          graphImage.strokeWeight(3);
        }else{
          graphImage.strokeWeight(1);
        }
      }
      for(int j = 0; j < gen; j++){
        graphImage.line(x+j*genWidth,(-percentile.get(j)[k])*meterHeight+zero+y,
        x+(j+1)*genWidth,(-percentile.get(j+1)[k])*meterHeight+zero+y);
      }
    }
  }
  graphImage.endDraw();
}
void drawSegBars(int x, int y, int graphWidth, int graphHeight){
  segBarImage.beginDraw();
  segBarImage.smooth();
  segBarImage.noStroke();
  segBarImage.colorMode(HSB, 1);
  segBarImage.background(0,0,0.5);
  float genWidth = float(graphWidth)/gen;
  int gensPerBar = floor(gen/500)+1;
  for(int i = 0; i < gen; i+=gensPerBar){
    int i2 = min(i+gensPerBar,gen);
    float barX1 = x+i*genWidth;
    float barX2 = x+i2*genWidth;
    int cum = 0;
    for(int j = 0; j < 100; j++){
      segBarImage.fill(getColor(j,false));
      segBarImage.beginShape();
      segBarImage.vertex(barX1,y+speciesCounts.get(i)[j]/1000.0*graphHeight);
      segBarImage.vertex(barX1,y+speciesCounts.get(i)[j+1]/1000.0*graphHeight);
      segBarImage.vertex(barX2,y+speciesCounts.get(i2)[j+1]/1000.0*graphHeight);
      segBarImage.vertex(barX2,y+speciesCounts.get(i2)[j]/1000.0*graphHeight);
      segBarImage.endShape();
    }
  }
  segBarImage.endDraw();
  colorMode(RGB, 255);
}
float extreme(float sign){
  float record = -sign;
  for(int i = 0; i < gen; i++){
    float toTest = percentile.get(i+1)[int(14-sign*14)];
    if(toTest*sign > record*sign){
      record = toTest;
    }
  }
  return record;
}
float setUnit(float best, float worst){
  float unit2 = 3*log(best-worst)/log(10)-3.3;
  if((unit2+100)%3 < 1){
    return pow(10,int(unit2/3));
  }else if((unit2+100)%3 < 2){
    return pow(10,int((unit2-1)/3))*2;
  }else{
    return pow(10,int((unit2-2)/3))*5;
  }
}
String showUnit(float i, float unit){
  if(unit < 1){
    return nf(i,0,2)+"";
  }else{
    return int(i)+"";
  }
}
ArrayList<Creature> quickSort(ArrayList<Creature> c){
  if(c.size() <= 1){
    return c;
  }else{
    ArrayList<Creature> less = new ArrayList<Creature>();
    ArrayList<Creature> more = new ArrayList<Creature>();
    ArrayList<Creature> equal = new ArrayList<Creature>();
    Creature c0 = c.get(0);
    equal.add(c0);
    for(int i = 1; i < c.size(); i++){
      Creature ci = c.get(i);
      if(ci.d == c0.d){
        equal.add(ci);
      }else if(ci.d > c0.d){
        more.add(ci);
      }else{
        less.add(ci);
      }
    }
    ArrayList<Creature> total = new ArrayList<Creature>();
    total.addAll(quickSort(more));
    total.addAll(equal);
    total.addAll(quickSort(less));
    return total;
  }
}
boolean isItContracted(float rtime1, float rtime2){
  boolean contracted;
  if(rtime1 <= rtime2){
    return true;
  }else{
    return false;
  }
}
void toStableConfiguration(int nodeNum, int muscleNum){
  for(int j = 0; j < 200; j++){
    for(int i = 0; i < muscleNum; i++){
      Muscle mi = m.get(i);
      if(mi.contracted){
        target = mi.contractLength;
      }else{
        target = mi.extendLength;
      }
      mi.applyForce(i,target);
    }
    for(int i = 0; i < nodeNum; i++){
      Node ni = n.get(i);
      ni.applyForces(i);
    }
  }
  for(int i = 0; i < nodeNum; i++){
    Node ni = n.get(i);
    ni.vx = 0;
    ni.vy = 0;
  }
}
void adjustToCenter(int nodeNum){
  float avx = 0;
  float lowY = -1000;
  for(int i = 0; i < nodeNum; i++){
    Node ni = n.get(i);
    avx += ni.x;
    if(ni.y+ni.m/2 > lowY){
      lowY = ni.y+ni.m/2;
    }
  }
  avx /= nodeNum;
  for(int i = 0; i < nodeNum; i++){
    Node ni = n.get(i);
    ni.x -= avx;
    ni.y -= lowY;
  }
}
void setGlobalVariables(Creature thisCreature){
  n.clear();
  m.clear();
  for(int i = 0; i < thisCreature.n.size(); i++){
    n.add(thisCreature.n.get(i).copyNode());
  }
  for(int i = 0; i < thisCreature.m.size(); i++){
    m.add(thisCreature.m.get(i).copyMuscle());
  }
  id = thisCreature.id;
  timer = 0;
  camzoom = 0.01;
  cam = 0;
  cTimer = thisCreature.creatureTimer;
  simulationTimer = 0;
}
void simulate(){
  for(int i = 0; i < m.size(); i++){
    Muscle mi = m.get(i);
    mi.thruPeriod = ((float(timer)/cTimer)/float(mi.period))%float(1);
    if((mi.thruPeriod <= mi.extendTime && mi.extendTime <= mi.contractTime) ||
       (mi.contractTime <= mi.thruPeriod && mi.thruPeriod <= mi.extendTime) ||
       (mi.extendTime <= mi.contractTime && mi.contractTime <= mi.thruPeriod)){
      target = mi.contractLength;
      mi.contracted = true;
    }else{
      target = mi.extendLength;
      mi.contracted = false;
    }
    mi.applyForce(i,target);
  }
  for(int i = 0; i < n.size(); i++){
    Node ni = n.get(i);
    ni.applyForces(i);
    ni.applyGravity(i);
    ni.hitWalls(i);
  }
  simulationTimer++;
}
// Calculate the distance for the current creature, by taking the average of the x coordinates
// of all its nodes.
void setAverage(){
  average = 0;
  for(int i = 0; i < n.size(); i++){
    Node ni = n.get(i);
    average += ni.x;
  }
  average = average/n.size();
  
  // Workaround for bug where creatures fall through blocks and get an enormous distance (in the millions)
  if(average > 10000) {
    writeLog ("Discarding erroneous result of " + average);
    average = 0;
  }
}
ArrayList<Node> n = new ArrayList<Node>();
ArrayList<Muscle> m = new ArrayList<Muscle>();
Creature[] c = new Creature[1000];
ArrayList<Creature> c2 = new ArrayList<Creature>();

void mouseWheel(MouseEvent event) {
  int delta = -1;//event.getCount();
  if(menu == 5){
    if(delta == -1){
      camzoom *= 0.9090909;
      if(camzoom < 0.006){
        camzoom = 0.006;
      }
      textFont(font, 0.96/camzoom);
    }else if(delta == 1){
      camzoom *= 1.1;
      if(camzoom > 0.1){
        camzoom = 0.1;
      }
      textFont(font, 0.96/camzoom);
    }
  }
}

void mousePressed(){
  if(gensToDo >= 1){
    gensToDo = 0;
  }
  float mX = mouseX/WINDOW_SIZE;
  float mY = mouseY/WINDOW_SIZE;
  if(menu == 1 && gen >= 1 && abs(mY-365) <= 25 && abs(mX-sliderX-25) <= 25){
    drag = true;
  }
}

void openMiniSimulation(){
  simulationTimer = 0;
  speed = MINI_SIMULATION_SPEED;
  
  // In the main window, the animation performs slower. Increase speed to let it show at normal speed.
  if(statusWindow < 0)
    speed = speed * 2;
    
  if(gensToDo == 0){
    miniSimulation = true;
    int id;
    Creature cj;
    if(statusWindow <= -1){
      // Load rectangles for selected generation
      int simGen = genSelected - 1;
      rects = rectsHistory.get(simGen);
      cj = creatureDatabase.get(simGen*3+statusWindow+3);
      id = cj.id;
    }else{
      // Showing a creature in the creature overview, after sorting.
      id = statusWindow;
      cj = c2.get(id);
    }
    setGlobalVariables(cj);
    creatureWatching = id;
  }
}
void setMenu(int m){
  menu = m;
  if(m == 1){
    drawGraph(975,570);
  }
}

void startASAP(){
  setMenu(4);
  creaturesTested = 0;
  stepbystep = false;
  stepbystepslow = false;
}
void mouseReleased(){
  drag = false;
  miniSimulation = false;
  float mX = mouseX/WINDOW_SIZE;
  float mY = mouseY/WINDOW_SIZE;
  if(menu == 0 && abs(mX-windowWidth/2) <= 200 && abs(mY-400) <= 100){
    setMenu(1);
  }else if(menu == 1 && gen == -1 && abs(mX-120) <= 100 && abs(mY-300) <= 50){
    setMenu(2);
  }else if(menu == 1 && gen >= 0 && abs(mX-990) <= 230){
    if(abs(mY-40) <= 20){
      // Full animation of a generation
      setMenu(4);
      creaturesTested = 0;
      stepbystep = true;
      stepbystepslow = true;
    }
    if(abs(mY-90) <= 20){
      // 1 quick generation
      setMenu(4);
      creaturesTested = 0;
      stepbystep = true;
      stepbystepslow = false;
    }
    if(abs(mY-140) <= 20){
      // ASAP generation, 1 or unlimited (ALAP)
      if(mX < 990){
        gensToDo = 1;
      }else{
        gensToDo = 1000000000;
      }
      startASAP();
    }
  }else if(menu == 3 && abs(mX-1030) <= 130 && abs(mY-684) <= 20){
    gen = 0;
    setMenu(1);
  }else if(menu == 7 && abs(mX-1030) <= 130 && abs(mY-684) <= 20){
    setMenu(8);
  }else if(menu == 9 && abs(mX-1030) <= 130 && abs(mY-690) <= 20){
    setMenu(10);
  }else if(menu == 11 && abs(mX-1130) <= 80 && abs(mY-690) <= 20){
    setMenu(12);
  }else if(menu == 13 && abs(mX-1130) <= 80 && abs(mY-690) <= 20){
    setMenu(1);
  }
}
void drawScreenImage(int stage){
  screenImage.beginDraw();
  screenImage.smooth();
  screenImage.background(220,253,102);
  screenImage.noStroke();
  camzoom = 0.12;
  for(int j = 0; j < 1000; j++){
    Creature cj = c2.get(j);
    if(stage == 3) cj = c[cj.id-(gen*1000)-1001];
    int j2 = j;
    if(stage == 0){
      j2 = cj.id-(gen*1000)-1;
      creaturesInPosition[j2] = j;
    }
    int x = j2%40;
    int y = floor(j2/40);
    if(stage >= 1) y++;
    drawCreatureWhole(cj,x*30+55,y*25+40,1);
  }
  timer = 0;
  screenImage.textAlign(CENTER);
  screenImage.textFont(font, 24);
  screenImage.fill(100,100,200);
  if(stage == 0){
    screenImage.rect(900,664,260,40);
    screenImage.fill(0);
    screenImage.text("All 1,000 creatures have been tested.  Now let's sort them!",windowWidth/2-200,690);
    screenImage.text("Sort",windowWidth-250,690);
  }else if(stage == 1){
    screenImage.rect(900,670,260,40);
    screenImage.fill(0);
    screenImage.text("Fastest creatures at the top!",windowWidth/2,30);
    screenImage.text("Slowest creatures at the bottom. (Going backward = slow)",windowWidth/2-200,700);
    screenImage.text("Kill 500",windowWidth-250,700);
  }else if(stage == 2){
    screenImage.rect(1050,670,160,40);
    screenImage.fill(0);
    screenImage.text("Faster creatures are more likely to survive because they can outrun their predators.  Slow creatures get eaten.",windowWidth/2,30);
    screenImage.text("Because of random chance, a few fast ones get eaten, while a few slow ones survive.",windowWidth/2-130,700);
    screenImage.text("Reproduce",windowWidth-150,700);
    for(int j = 0; j < 1000; j++){
      Creature cj = c2.get(j);
      int x = j%40;
      int y = floor(j/40)+1;
      if(cj.alive){
        drawCreatureWhole(cj,x*30+55,y*25+40,0);
      }else{
        screenImage.rect(x*30+40,y*25+17,30,25);
      }
    }
  }else if(stage == 3){
    screenImage.rect(1050,670,160,40);
    screenImage.fill(0);
    screenImage.text("These are the 1000 creatures of generation #"+(gen+2)+".",windowWidth/2,30);
    screenImage.text("What perils will they face?  Find out next time!",windowWidth/2-130,700);
    screenImage.text("Back",windowWidth-150,700);
  }
  screenImage.endDraw();
}
void drawpopUpImage(){
  camzoom = 0.015;
  setAverage();
  cam += (average-cam)*0.1;
  popUpImage.beginDraw();
  popUpImage.smooth();
  if(simulationTimer < SIMULATION_FRAMES){
    popUpImage.background(120,200,255);
  }else{
    popUpImage.background(60,100,128);
  }
  drawPosts(2);
  drawGround(2);
  drawCreature(n,m,-cam/camzoom+450/2, 450*0.8,2);
  popUpImage.noStroke();
  popUpImage.endDraw();
}
void drawCreatureWhole(Creature cj, float x, float y, int toImage){
  for(int i = 0; i < cj.m.size(); i++){
    Muscle mi = cj.m.get(i);
    drawMuscle(mi,cj.n.get(mi.c1),cj.n.get(mi.c2),x,y,toImage);
  }
  for(int i = 0; i < cj.n.size(); i++){
    drawNode(cj.n.get(i),x,y,toImage);
  }
}
void drawCreature(ArrayList<Node> n, ArrayList<Muscle> m, float x, float y, int toImage){
  for(int i = 0; i < m.size(); i++){
    Muscle mi = m.get(i);
    drawMuscle(mi,n.get(mi.c1),n.get(mi.c2),x,y,toImage);
  }
  for(int i = 0; i < n.size(); i++){
    drawNode(n.get(i),x,y,toImage);
  }
}
void drawHistogram(int x, int y, int hw, int hh){
  int maxH = 1;
  for(int i = 0; i < barLen; i++){
    if(barCounts.get(genSelected)[i] > maxH){
      maxH = barCounts.get(genSelected)[i];
    }
  }
  fill(200);
  noStroke();
  rect(x,y,hw,hh);
  fill(0,0,0);
  float barW = (float)hw/barLen;
  float multiplier = (float)hh/maxH*0.9;
  textAlign(LEFT);
  textFont(font,16);
  stroke(128);
  strokeWeight(2);
  int unit = 100;
  if(maxH < 300) unit = 50;
  if(maxH < 100) unit = 20;
  if(maxH < 50) unit = 10;
  for(int i = 0; i < hh/multiplier; i += unit){
    float theY = y+hh-i*multiplier;
    line(x,theY,x+hw,theY);
    if(i == 0) theY -= 5;
    text(i,x+hw+5,theY+7);
  }
  textAlign(CENTER);
  for(int i = minBar; i <= maxBar; i ++){
    if(i%10 == 0){
      if(i == 0){
        stroke(0,0,255);
      }else{
        stroke(128);
      }
      float theX = x+(i-minBar)*barW;
      text(nf((float)i/histBarsPerMeter,0,1),theX,y+hh+14);
      line(theX,y,theX,y+hh);
    }
  }
  noStroke();
  for(int i = 0; i < barLen; i++){
    float h = min(barCounts.get(genSelected)[i]*multiplier,hh);
    if(i+minBar == floor(percentile.get(min(genSelected,percentile.size()-1))[14]*histBarsPerMeter)){
      fill(255,0,0);
    }else{
      fill(0,0,0);
    }
    rect(x+i*barW,y+hh-h,barW,h);
  }
}
void drawStatusWindow(){
  int x, y, px, py;
  int rank = (statusWindow+1);
  Creature cj;
  stroke(abs(overallTimer%30-15)*17);
  strokeWeight(3);
  noFill();
  if(statusWindow >= 0){
    cj = c2.get(statusWindow);
    if(menu == 7){
      int id = ((cj.id-1)%1000);
      x = id%40;
      y = floor(id/40);
    }else{
      x = statusWindow%40;
      y = floor(statusWindow/40)+1;
    }
    px = x*30+55;
    py = y*25+10;
    if(px <= 1140){
      px += 80;
    }else{
      px -= 80;
    }
    rect(x*30+40,y*25+17,30,25);
  }else{
    cj = creatureDatabase.get((genSelected-1)*3+statusWindow+3);
    x = 760+(statusWindow+3)*160;
    y = 180;
    px = x;
    py = y;
    rect(x,y,140,140);
    int[] ranks = {1000,500,1};
    rank = ranks[statusWindow+3];
  }
  noStroke();
  fill(255);
  rect(px-60,py,120,52);
  fill(0);
  textFont(font,12);
  textAlign(CENTER);
  text("#"+rank,px,py+12);
  text("ID: "+cj.id,px,py+24);
  text("Fitness: "+nf(cj.d,0,3),px,py+36);
  colorMode(HSB,1);
  int sp = (cj.n.size()%10)*10+(cj.m.size()%10);
  fill(getColor(sp,true));
  text("Species: S"+(cj.n.size()%10)+""+(cj.m.size()%10),px,py+48);
  colorMode(RGB,255);
  if(miniSimulation){
    int py2 = py-125;
    if(py >= 360){
      py2 -= 180;
    }else{
      py2 += 180;
    }
    //py = min(max(py,0),420);
    int px2 = min(max(px-90,10),970);
    drawpopUpImage();
    image(popUpImage,px2,py2,300,300);
    fill(255,255,255);
    rect(px2+240,py2+10,50,30);
    rect(px2+10,py2+10,100,30);
    fill(0,0,0);
    textFont(font,30);
    textAlign(RIGHT);
    text(int(simulationTimer/60),px2+285,py2+36);
    textAlign(LEFT);
    text(nf(average/5.0,0,3),px2+15,py2+36);
    
    // Respect set speed for minisimulation.
    for(int s = 0; s < speed; s++){
      if(timer < SIMULATION_FRAMES){
        simulate();
        timer++;
      }
    }
    
    int shouldBeWatching = statusWindow;
    if(statusWindow <= -1){
      cj = creatureDatabase.get((genSelected-1)*3+statusWindow+3);
      shouldBeWatching = cj.id;
    }
    if(creatureWatching != shouldBeWatching){
      openMiniSimulation();
    }
  }
}
void setup(){
  size(1280, 720, P2D); // Don't change this.  It ruins everything.
  if(USE_RANDOM_SEED){
    randomSeed(SEED);
  }
  smooth();
  ellipseMode(CENTER);
  Float[] beginPercentile = new Float[29];
  Integer[] beginBar = new Integer[barLen];
  Integer[] beginSpecies = new Integer[101];
  for(int i = 0; i < 29; i++){
    beginPercentile[i] = 0.0;
  }
  for(int i = 0; i < barLen; i++){
    beginBar[i] = 0;
  }
  for(int i = 0; i < 101; i++){
    beginSpecies[i] = 500;
  }

  percentile.add(beginPercentile);
  barCounts.add(beginBar);
  speciesCounts.add(beginSpecies);
  topSpeciesCounts.add(0);

  graphImage = createGraphics(975,570,P2D);
  screenImage = createGraphics(1280,720,P2D);
  popUpImage = createGraphics(450,450,P2D);
  segBarImage = createGraphics(975,150,P2D);
  font = loadFont("Helvetica-Bold-96.vlw");
  textFont(font, 96);
  textAlign(CENTER);
  
  // Initialize rectangles. First gen gets unrandomized ones.
  for(int i = 0; i < RECTANGLES.length; i++){
    rects.add(RECTANGLES[i]);
  }
  rectsHistory.add(rects);
}
void writeLog(String toLog){
  if(DEBUG) println(toLog);
}
void randomizeRectangles(){
  if(!RANDOMIZE_RECTANGLES) {
    // If no randomization, we just add the original set of rectangles for every history generation.    
    rectsHistory.add(rects);
    return;
  }

  rects = new ArrayList<Rectangle>(0);
  for(int i = 0; i < RECTANGLES.length; i++){
    float x1 = RECTANGLES[i].x1 * (1 + random(-1, 1) * (RECTANGLES_MUTABILITY_FACTOR - 1));
    float y1 = RECTANGLES[i].y1 * (1 + random(-1, 1) * (RECTANGLES_MUTABILITY_FACTOR - 1));
    float x2 = RECTANGLES[i].x2 * (1 + random(-1, 1) * (RECTANGLES_MUTABILITY_FACTOR - 1));
    float y2 = RECTANGLES[i].y2 * (1 + random(-1, 1) * (RECTANGLES_MUTABILITY_FACTOR - 1));
        
    // Ensure the coordinates are specified "normally" with x1, y1 left bottom and x2, y2 right top.
    float temp;
    if(x1 > x2) {
      temp = x2;
      x2 = x1;
      x1 = temp;
    }
    if(y1 > y2) {
      temp = y2;
      y2 = y1;
      y1 = y2;
    }
    
    // Ensure it doesn't overlap with the previous one, to prevent weird issues
    // with creatures poking through rects.
    // Not necessary (example rectangles also overlap) and undesirable.
//    if(i>0){
//      Rectangle prevRect = rects.get(i-1);
//      x1 = max(prevRect.x2, x1);
//      
//      // It could happen that the correction lead to x1 pass further than x2. We correct x2 with a random width.
//      if(x1 > x2) x2 = x1 + (1 + random(-1, 1) * (RECTANGLES_MUTABILITY_FACTOR - 1));
//    }
    
//    writeLog("New rectangle " + i + ": (" + x1 + ", " + y1 + ")-(" + x2 + ", " + y2 +")");
    Rectangle newRect = new Rectangle(x1, y1, x2, y2);
    rects.add(newRect);
  }
  
  // Save rectangles for this generation to history to properly re-simulate historical creatures.
  // As this method is called once for each generation, the ArrayList index is on par with "gen".
  // TODO: replace by a (resizable) associative array, if there is one.
  rectsHistory.add(rects);
}
void draw(){
  scale(1);
  if(menu == 0){
    background(255);
    fill(100,200,100);
    noStroke();
    rect(windowWidth/2-200,300,400,200);
    fill(0);
    text("EVOLUTION!", windowWidth/2,200);
    text("START", windowWidth/2,430);
  }else if(menu == 1){
    noStroke();
    fill(0);
    background(255,200,130);
    textFont(font, 32);
    textAlign(LEFT);
    textFont(font,96);
    text("Generation "+max(genSelected,0),20,100);
    textFont(font,28);
    if(gen == -1){
      fill(100,200,100);
      rect(20,250,200,100);
      fill(0);
      text("Since there are no creatures yet, create 1000 creatures!",20,160);
      text("They will be randomly created, and also very simple.",20,200);
      text("CREATE",56,312);
    }else{
      fill(100,200,100);
      rect(760,20,460,40);
      rect(760,70,460,40);
      rect(760,120,230,40);
      if(gensToDo >= 2){
        fill(128,255,128);
      }else{
        fill(70,140,70);
      }
      rect(990,120,230,40);
      fill(0);
      text("Do 1 step-by-step generation.",770,50);
      text("Do 1 quick generation.",770,100);
      text("Do 1 gen ASAP.",770,150);
      if(gensToDo >= 2){
        textFont(font,15);
        text("Currently ALAPing.",996,136);
        text("Click & hold anywhere to stop.",996,153);
        textFont(font,28);
      }else{
        text("Do gens ALAP.",1000,150);
      }
      text("Max Distance",50,140);
      textAlign(RIGHT);
      text(float(round(percentile.get(min(genSelected,percentile.size()-1))[0]*1000))/1000+" m",700,140);

      textAlign(LEFT);
      text("Median Distance",50,165);
      textAlign(RIGHT);
      text(float(round(percentile.get(min(genSelected,percentile.size()-1))[14]*1000))/1000+" m",700,165);

      drawHistogram(760,410,460,280);
      drawGraphImage();
    }
    if(gensToDo >= 1){
      gensToDo--;
      if(gensToDo >= 1){
        startASAP();
      }
    }
  }else if(menu == 2){
    // Create a new set of nodes
    creatures = 0;
    camzoom = 0.12;
    background(220,253,102);
    for(int y = 0; y < 25; y++){
      for(int x = 0; x < 40; x++){
        n.clear();
        m.clear();
        int nodeNum = int(random(CREATURE_MIN_NODES, 2* CREATURE_MIN_NODES));
        int muscleNum = int(random(nodeNum-1,nodeNum*3-6));
        for(int i = 0; i < nodeNum; i++){
          n.add(new Node(random(-1,1),random(-1,1),0,0,
          random(MINIMUM_NODE_SIZE,MAXIMUM_NODE_SIZE),
          random(MINIMUM_NODE_FRICTION,MAXIMUM_NODE_FRICTION))); //replaced all nodes' sizes with 0.4, used to be random(0.1,1), random(0,1)
        }
        for(int i = 0; i < muscleNum; i++){
          int tc1;
          int tc2;
          if(i < nodeNum-1){
            tc1 = i;
            tc2 = i+1;
          }else{
            tc1 = int(random(0,nodeNum));
            tc2 = tc1;
            while(tc2 == tc1){
              tc2 = int(random(0,nodeNum));
            }
          }
          float rlength1 = random(0.5,1.5);
          float rlength2 = random(0.5,1.5);
          float rtime1 = random(0,1);
          float rtime2 = random(0,1);
          m.add(new Muscle(int(random(1,3)),tc1,tc2,rtime1,rtime2,
          min(rlength1,rlength2),max(rlength1,rlength2),isItContracted(rtime1,rtime2),random(0.02,0.08)));
        }
        toStableConfiguration(nodeNum,muscleNum);
        adjustToCenter(nodeNum);
        float heartbeat = random(40,80);
        c[y*40+x] = new Creature(y*40+x+1,new ArrayList<Node>(n),new ArrayList<Muscle>(m),0,true,heartbeat,1.0);
        c[y*40+x].checkForOverlap();
        c[y*40+x].checkForLoneNodes();
        drawCreatureWhole(c[y*40+x],x*30+55,y*25+30,0);
      }
    }
    setMenu(3);
    noStroke();
    fill(100,100,200);
    rect(900,664,260,40);
    fill(0);
    textAlign(CENTER);
    textFont(font, 24);
    text("Here are your 1000 randomly generated creatures!!!",windowWidth/2-200,690);
    text("Back",windowWidth-250,690);
  }else if(menu == 4){ // Start simulation
    // Load latest rects, as they might have changed when watching previous
    // generations.
    // gen hasn't been increased at this point yet.
    if(gen > 0) {
      rects = rectsHistory.get(gen);
    }
    setGlobalVariables(c[creaturesTested]);
    camzoom = 0.01;
    setMenu(5);
    if(stepbystepslow){
      // In step-by-step simulation, show each next creatures a bit faster than the last.
      if(creaturesTested <= 4){
        speed = max(creaturesTested,1);
      }else{
        speed = min(creaturesTested*3-9,1000);
      }
    }else{
      // An ASAP simulation run
      for(int i = 0; i < 1000; i++){
        setGlobalVariables(c[i]);
        for(int s = 0; s < SIMULATION_FRAMES; s++){
          simulate();
          timer++;
        }
        setAverage();
        c[i].d = average*0.2;
      }
      setMenu(6);
    }
  }
  if(menu == 5){ //simulate running
    if(timer <= SIMULATION_FRAMES){
      textAlign(CENTER);
      textFont(font, 0.96/camzoom);
      background(120,200,255);
      for(int s = 0; s < speed; s++){
        if(timer < SIMULATION_FRAMES){
          simulate();
          timer++;
        }
      }
      setAverage();
      if(speed < 30){
        for(int s = 0; s < speed; s++){
          cam += (average-cam)*0.03;
        }
      }else{
        cam = average;
      }
      drawPosts(0);
      drawGround(0);
      drawCreature(n,m,-cam/camzoom+windowWidth/2, windowHeight*0.8,0);
      drawArrow(average);
      textAlign(RIGHT);
      textFont(font,32);
      fill(0);
      text("Creature ID: "+id,windowWidth-10,32);
      if(speed > 60){
        timeShow = int((timer+creaturesTested*37)/60)%15;
      }else{
        timeShow = (timer/60);
      }
      timeShow = round(timeShow);
      text("Time: "+timeShow+" / 15 sec.",windowWidth-10,64);
      text("Playback Speed: x"+speed,windowWidth-10,96);
    }
    if(timer == SIMULATION_FRAMES){
      if(speed < 30){
        noStroke();
        fill(0,0,0,130);
        rect(0,0,windowWidth,windowHeight);
        fill(0,0,0,255);
        rect(windowWidth/2-500,200,1000,240);
        fill(255,0,0);
        textAlign(CENTER);
        textFont(font, 96);
        text("Creature's Distance:",windowWidth/2,300);
        text(float(round(average*200))/1000 + " m",windowWidth/2,400);
      }else{
        timer = SIMULATION_FRAMES + 2 * FRAMES_PER_SECOND;
      }
        
      c[creaturesTested].d = average*0.2;
    }
    if(timer >= SIMULATION_FRAMES + 2 * FRAMES_PER_SECOND){
      setMenu(4);
      creaturesTested++;
      if(creaturesTested == 1000){
        setMenu(6);
      }
      cam = 0;
    }
    if(timer >= SIMULATION_FRAMES){
      timer += speed;
    }
  }
  if(menu == 6){
    //sort
    c2 = new ArrayList<Creature>(0);
    for(int i = 0; i < 1000; i++){
      c2.add(c[i]);
    }
    c2 = quickSort(c2);
    percentile.add(new Float[29]);
    for(int i = 0; i < 29; i++){
      percentile.get(gen+1)[i] = c2.get(p[i]).d;
    }
    creatureDatabase.add(c2.get(999).copyCreature(-1));
    creatureDatabase.add(c2.get(499).copyCreature(-1));
    creatureDatabase.add(c2.get(0).copyCreature(-1));

    Integer[] beginBar = new Integer[barLen];
    for(int i = 0; i < barLen; i++){
      beginBar[i] = 0;
    }
    barCounts.add(beginBar);
    Integer[] beginSpecies = new Integer[101];
    for(int i = 0; i < 101; i++){
      beginSpecies[i] = 0;
    }
    for(int i = 0; i < 1000; i++){
      int bar = floor(c2.get(i).d*histBarsPerMeter-minBar);
      if(bar >= 0 && bar < barLen){
        barCounts.get(gen+1)[bar]++;
      }
      int species = (c2.get(i).n.size()%10)*10+c2.get(i).m.size()%10;
      beginSpecies[species]++;
    }
    speciesCounts.add(new Integer[101]);
    speciesCounts.get(gen+1)[0] = 0;
    int cum = 0;
    int record = 0;
    int holder = 0;
    for(int i = 0; i < 100; i++){
      cum += beginSpecies[i];
      speciesCounts.get(gen+1)[i+1] = cum;
      if(beginSpecies[i] > record){
        record = beginSpecies[i];
        holder = i;
      }
    }
    topSpeciesCounts.add(holder);
    if(stepbystep){
      drawScreenImage(0);
      setMenu(7);
    }else{
      setMenu(10);
    }
  }
  if(menu == 8){
    //cool sorting animation
    camzoom = 0.12;
    background(220,253,102);
    float transition = 0.5-0.5*cos(min(float(timer)/60,PI));
    for(int j = 0; j < 1000; j++){
      Creature cj = c2.get(j);
      int j2 = cj.id-(gen*1000)-1;
      int x1 = j2%40;
      int y1 = floor(j2/40);
      int x2 = j%40;
      int y2 = floor(j/40)+1;
      float x3 = inter(x1,x2,transition);
      float y3 = inter(y1,y2,transition);
      drawCreatureWhole(cj,x3*30+55,y3*25+40,0);
    }
    if(stepbystepslow){
      timer += 1*SORT_ANIMATION_SPEED;
    }else{
      timer += 3*SORT_ANIMATION_SPEED;
    }
    if(timer > 60*PI){
      drawScreenImage(1);
      setMenu(9);
    }
  }
  float mX = mouseX/WINDOW_SIZE;
  float mY = mouseY/WINDOW_SIZE;
  if(abs(menu-9) <= 2 && gensToDo == 0 && !drag){
    // For overview pages, determine which creature the mouse is over. ID stored in var statusWindow.
    if(abs(mX-639.5) <= 599.5){
      if(menu == 7 && abs(mY-329) <= 312){
        statusWindow = creaturesInPosition[floor((mX-40)/30)+floor((mY-17)/25)*40];
      }else if(menu >= 9 && abs(mY-354) <= 312){
        statusWindow = floor((mX-40)/30)+floor((mY-42)/25)*40;
      }else{
        statusWindow = -4;
      }
    }else{
      statusWindow = -4;
    }
  }else if(menu == 1 && genSelected >= 1 && gensToDo == 0 && !drag){
    statusWindow = -4;
    if(abs(mY-250) <= 70){
      if(abs(mX-990) <= 230){
        float modX = (mX-760)%160;
        if(modX < 140){
          statusWindow = floor((mX-760)/160)-3;
        }
      }
    }
  }else{
    statusWindow = -4;
  }
  if(menu == 10){
    //Kill!
    for(int j = 0; j < 500; j++){
      float f = float(j)/1000;
      float rand = (pow(random(-1,1),3)+1)/2; //cube function
      slowDies = (f <= rand);
      int j2;
      int j3;
      if(slowDies){
        j2 = j;
        j3 = 999-j;
      }else{
        j2 = 999-j;
        j3 = j;
      }
      Creature cj = c2.get(j2);
      cj.alive = true;
      Creature ck = c2.get(j3);
      ck.alive = false;
    }
    if(stepbystep){
      drawScreenImage(2);
      setMenu(11);
    }else{
      setMenu(12);
    }
  }
  if(menu == 12){ //Reproduce and mutate. I.e. get ready for next round.
    justGotBack = true;
    randomizeRectangles();
    for(int j = 0; j < 500; j++){
      int j2 = j;
      if(!c2.get(j).alive) j2 = 999-j;
      Creature cj = c2.get(j2);
      Creature cj2 = c2.get(999-j2);
      c2.set(999-j2,cj.modified(cj2.id+1000));   //mutated offspring 1
      n = c2.get(999-j2).n;
      m = c2.get(999-j2).m;
      toStableConfiguration(n.size(),m.size());
      adjustToCenter(n.size());
      c2.set(j2,cj.copyCreature(cj.id+1000));        //duplicate
    }
    for(int j = 0; j < 1000; j++){
      Creature cj = c2.get(j);
      c[cj.id-(gen*1000)-1001] = cj.copyCreature(-1);
    }
    drawScreenImage(3);
    gen++;
    if(stepbystep){
      setMenu(13);
    }else{
      setMenu(1);
    }
  }
  if(menu%2 == 1 && abs(menu-10) <= 3){
    image(screenImage,0,0,windowWidth,windowHeight);
  }
  if(menu == 1 || gensToDo >= 1){
    mX = mouseX/WINDOW_SIZE;
    mY = mouseY/WINDOW_SIZE;
    noStroke();
    if(gen >= 1){
      textAlign(CENTER);
      if(gen >= 5){
        genSelected = round((sliderX-760)*(gen-1)/410)+1;
      }else{
        genSelected = round((sliderX-760)*gen/410);
      }
      if(drag) sliderX = min(max(sliderX+(mX-25-sliderX)*0.2,760),1170);
      fill(100);
      rect(760,340,460,50);
      fill(220);
      rect(sliderX,340,50,50);
      int fs = 0;
      if(genSelected >= 1){
        fs = floor(log(genSelected)/log(10));
      }
      fontSize = fontSizes[fs];
      textFont(font,fontSize);
      fill(0);
      text(genSelected,sliderX+25,366+fontSize*0.3333);
    }
    if(genSelected >= 1){
      textAlign(CENTER);
      camzoom = 0.028;
      for(int k = 0; k < 3; k++){
        fill(220);
        rect(760+k*160,180,140,140);
        drawCreatureWhole(creatureDatabase.get((genSelected-1)*3+k),830+160*k,290,0);
      }
      fill(0);
      textFont(font,16);
      text("Worst Creature",830,310);
      text("Median Creature",990,310);
      text("Best Creature",1150,310);
    }
    if(justGotBack) justGotBack = false;
  }
  if(statusWindow >= -3){
    drawStatusWindow();
    if(statusWindow >= -3 && !miniSimulation){
      openMiniSimulation();
    }
  }
  overallTimer++;
}
