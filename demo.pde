// =====================================================
//   CONSTANTS
// =====================================================

// CONSTANTS - GRAPHICS
static int constFrameRate = 30;
static int constResX = 720;
static int constResY = 720;

// CONSTANTS - SYSTEM
static int constNumPatterns = 11;
static float constAdvanceRate = 1/60;
static float constQueueSeperation = 0.025;

// CONSTANTS - MATH
static float MATH_E = 2.71828182845904523536028747135266249775724709369995;

// =====================================================
//   GLOBAL OBJECTS
// =====================================================

// OBJECTS - IMAGES
PImage imgCar, imgRoad, imgPatterns[];

// =====================================================
//   CLASSES
// =====================================================

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
  ArrayList<Car> carsQueue;
  ArrayList<Car> carsDone;
  boolean enabled;
  float pQueue;        // PROGRESS POINT AT WHICH CAR MUST QUEUE
  
  Route(int turn, int side){
    enabled = false;
    carsQueue = new ArrayList<Car>();
    carsDone = new ArrayList<Car>();
    
    // TURNS - 0 = left, 1 = straight, 2 = right
    // SIDES - 0 = left, 1 = top, 2 = right, 3 = bottom
    
    if (turn == 0){          // LEFT TURN
      points = new Point[4];
    } else if (turn == 1){   // STRAIGHT ON
      points = new Point[3];
    } else {                 // RIGHT TURN
      points = new Point[4];
    }
    
    pQueue = points[1].p;    // SET INTIAIL Q POINT TO EDGE OF APPROACH
  }
  
  void addCar(){
    carsQueue.add(new Car());
  }
  
  void tick(){
    pQueue = points[1].p - (carsQueue.size() * constQueueSeperation);      // QUEUE POINT
    
    for (int i = 0; i < carsQueue.size(); i++){
      Car c = carsQueue.get(i);
      
      if (enabled){
        c.advance(constAdvanceRate);
      } else {
        if (c.p < pQueue){
          c.advance(constAdvanceRate);
        }
      }
    }
    
    for (int i = 0; i < carsDone.size(); i++){
      Car c = carsDone.get(i);
      c.advance(constAdvanceRate);
    }
  }
  
  void draw(){
    for (int i = 0; i < carsQueue.size(); i++){
      Car c = carsQueue.get(i);
      image(imgCar, 0, 0);
    }
    
    for (int i = 0; i < carsDone.size(); i++){
      Car c = carsDone.get(i);
      c.advance(constAdvanceRate);
    }
  }
  
  void checkCars(){
     for (int i = 0; i < carsQueue.size(); i++){
       Car c = carsQueue.get(i);
       if (c.p >= points[1].p){
         carsDone.add(c);
         carsQueue.remove(i);
       }
     }
  
     for (int i = 0; i < carsDone.size(); i++){
       Car c = carsDone.get(i);
       if (c.p > 1){
         carsDone.remove(i);
       }
     } 
  }
}

// =====================================================
//   FUNCTIONS
// =====================================================

// Get number of cars
int get_cars(float expected){
  float test = random(1);
  float total = 0;
  int k;
  for(k=0; test > total; k++) {
    total += ( pow(expected, parseFloat(k)) * pow(MATH_E, -expected) ) / fac(k);
  }
  return k-1;
}

// Fac for get_car
int fac(int n) {
  int total = 1;
  for(int i=2; i<=n; i++){
    total *= i;
  }
  return total;
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

