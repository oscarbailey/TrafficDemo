// CONSTANTS - GRAPHICS
static int constFrameRate = 30;
static int constResX = 720;
static int constResY = 405;

// CONSTANTS - SYSTEM
static int constNumPatterns = 11;

// OBJECTS - IMAGES
PImage imgCar, imgRoad, imgPatterns[];

// CLASS - Point
class Point{
  int x, y;
  float p;
 
  Point(){
    x = 0;
    y = 0;
    p = 0;
  } 
}

// CLASS - Car
class Car{
  int waitTime;
  float p;
  
  Car(){
    waitTime = 0;
    p = 0;
  }
  
  void advance(float amt){
    p += amt;
  }
}

// CLASS - Route
class Route{
  Point points[];
  ArrayList<Car> cars;
  boolean enabled;
  float pQueue;        // PROGRESS POINT AT WHICH CAR MUST QUEUE
  
  Route(int turn, int side){
    enabled = false;
    cars = new ArrayList<Car>();
    
    // TURNS - 0 = left, 1 = straight, 2 = right
    // SIDES - 0 = left, 1 = top, 2 = right, 3 = bottom
    
    if (turn == 0){          // LEFT TURN
      points = new Point[4];
    } else if (turn == 1){   // STRAIGHT ON
      points = new Point[3];
    } else {                 // RIGHT TURN
      points = new Point[4];
    }
  }
  
  void addCar(){
    cars.add(new Car());
  }
  
  void tick(){
    pQueue = 0;      // QUEUE POINT
    
    for (int i = 0; i < cars.size(); i++){
      car c = cars.get(i);  
      
      if (c.p < points[1].p){    // APPROACHING
        if (c.p < pQueue){
          c.advance();
        }
      } else{                    // PAST APPROACH LINE
        c.advance();
      }
    }
  }
  
  void draw(){
    for (int i = 0; i < cars.size(); i++){
      car c = cars.get(i);
      image(imgCar, c.x, c.y);
    }
  }
}

// Interp function
int Interp(int start, int end, float p){
   return start + ceil((end - start) * p);
}

// Setup function
void setup(){
  size(constResX, constResY);
  frameRate(constFrameRate);
  
  textFont(createFont("NanumGothic", 14));
  
  imgCar = loadImage("car.png");
  imgRoad = loadImage("road.png");
  imgPatterns = new PImage[constNumPatterns];
  for (int i = 0; i < constNumPatterns; i++){
    imgPatterns[i] = loadImage("p_" + nf(i, 2) + ".png");
  }
}

// Draw function
void draw(){
   image(imgRoad, 0, 0);
}

