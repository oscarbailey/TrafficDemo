// =====================================================
//   CONSTANTS
// =====================================================

// CONSTANTS - GRAPHICS
static int constFrameRate = 30;
static int constResX = 720;
static int constResY = 720;

// CONSTANTS - SYSTEM
static int constNumPatterns = 11;
static int constFixedTimer = 5 * constFrameRate;
static int constSwitchPriority = 100;
static float constAdvanceRate = 0.01;
static float constQueueSeperation = 0.025;

// CONSTANTS - MATH
static float MATH_E = 2.71828182845904523536028747135266249775724709369995;

// =====================================================
//   GLOBAL VARIABLES
// =====================================================

int priorityCalc = 4;
Boolean priorityFixed = true;

// =====================================================
//   GLOBAL OBJECTS
// =====================================================

// OBJECTS - IMAGES
PImage imgCar, imgRoad, imgPatterns[];

// OBJECTS - ROUTES
Route r[];

// =====================================================
//   MATHS FUNCTIONS
// =====================================================

// Interp function
int interp(int start, int end, float p){
   return start + ceil((end - start) * p);
}

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
  int x, y, waitTime;
  float p;
  
  Car(){
    x = 0;
    y = 0;
    waitTime = 0;
    p = 0;
  }
  
  int getPriority(){
    return parseInt( pow(waitTime, 2) );
  }
  
  void r90c(){
     int tx, ty;
     int newx, newy;
    
     tx = x - 360;
     ty = y - 360;
    
     newx = 360 + ty;
     newy = 360 - tx; 
     
     x = newx;
     y = newy;
  }
  
  void draw(){
    image(imgCar, x-8, y-8);
    //println(waitTime);
  }
}

// CLASS - Route
class Route{
  Point[] points;
  ArrayList<Car> carsQueue;
  ArrayList<Car> carsDone;
  boolean enabled;
  float pQueue;        // PROGRESS POINT AT WHICH CAR MUST QUEUE#
  int side;
  
  Route(int turn, int rot){
    enabled = true;
    side = rot;
    carsQueue = new ArrayList<Car>();
    carsDone = new ArrayList<Car>();
    
    // TURNS - 0 = left, 1 = straight, 2 = right
    // SIDES - 0 = left, 1 = top, 2 = right, 3 = bottom
    // Turn is computed, side affects draw rotation
    
    if (turn == 0){          // LEFT TURN
      points = new Point[4];
      points[0] = new Point(); points[0].x = 0; points[0].y = 270;
      points[1] = new Point(); points[1].x = 247; points[1].y = 270;
      points[2] = new Point(); points[2].x = 307; points[2].y = 270;
      points[3] = new Point(); points[3].x = 307; points[3].y = 0;
    } else if (turn == 1){   // STRAIGHT ON
      points = new Point[4];
      points[0] = new Point(); points[0].x = 0; points[0].y = 305;
      points[1] = new Point(); points[1].x = 247; points[1].y = 305;
      points[2] = new Point(); points[2].x = 500; points[2].y = 305;
      points[3] = new Point(); points[3].x = 720; points[3].y = 305;
    } else {                 // RIGHT TURN
      points = new Point[4];
      points[0] = new Point(); points[0].x = 0; points[0].y = 341;
      points[1] = new Point(); points[1].x = 247; points[1].y = 341;
      points[2] = new Point(); points[2].x = 414; points[2].y = 341;
      points[3] = new Point(); points[3].x = 414; points[3].y = 720;
    }
    
    for (int i = 0; i < points.length; i++){
      points[i].p = i * (1.0 / points.length);
    }
    
    pQueue = points[1].p;    // SET INITIAL Q POINT TO EDGE OF APPROACH
  }
  
  void setCarPos(Car c){
    
    int point = 1;
    for (int i = 1; i < points.length; i++){
       if (c.p < points[i].p){
          point = i;
          break;
       }
    }
   
    c.x = interp(points[point-1].x, points[point].x, (c.p-points[point-1].p)/(points[point].p - points[point-1].p));
    c.y = interp(points[point-1].y, points[point].y, (c.p-points[point-1].p)/(points[point].p - points[point-1].p));
    
    for (int i = 1; i < side+1; i++){
      c.r90c();
    }
  }
  
  void addCar(){
    carsQueue.add(new Car());
  }

  int getPriority1(){
    // Returns total wait time
    int total = 0;
    int n = carsQueue.size();
    for(int i=0; i<n; i++){
      Car c = carsQueue.get(i);
      total += c.waitTime;
    }
    return total;
  }

  int getPriority2(){
    // Returns highest wait time
    int highest = 0;
    int n = carsQueue.size();
    for(int i=0; i<n; i++){
      Car c = carsQueue.get(i);

      if(c.waitTime > highest) {
        highest = c.waitTime;
      }
    }
    return highest;
  }

  int getPriority3(){
    // Wait time altered in some way before being used here
    // This function evaluates the product of (wait time squared)
    int total = 0;
    int n = carsQueue.size();
    for(int i=0; i<n; i++){
      Car c = carsQueue.get(i);
      total *= c.getPriority();
    }
    return total;
  }

  int getPriority4(){
    // Returns just the number of cars
    return carsQueue.size();
  }
  
  void tick(){
    // pQueue = points[1].p - ((carsQueue.size()-1) * constQueueSeperation);      // QUEUE POINT
    
    for (int i = 0; i < carsQueue.size(); i++){
      Car c = carsQueue.get(i);
      
      if (enabled){
        c.p += constAdvanceRate;
      } else {
        c.waitTime++;
        pQueue = points[1].p - (i*constQueueSeperation) - 0.02;
        if (c.p < pQueue){
          c.p += constAdvanceRate;
        }
      }
    }
    
    for (int i = 0; i < carsDone.size(); i++){
      Car c = carsDone.get(i);
      c.p += constAdvanceRate;
    }
    
    // OSCAR'S CAR ADDING CODE, please move if this is in the wrong place
    int expectedCars = int(get_cars( 1.0 / constFrameRate )); // Expect 1 car every second
    for(int i=0; i<expectedCars; i++) {
      addCar();
    }
    // END OF CODE

    checkCars();
  }
  
  void draw(){
    for (int i = 0; i < carsQueue.size(); i++){
      Car c = carsQueue.get(i);
      setCarPos(c);
      c.draw();
    }
    for (int i = 0 ; i < carsDone.size(); i++){
       Car c = carsDone.get(i);
       setCarPos(c);
       c.draw();
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

class Pattern{
  Route[] routes;
  String[] routePrint;
  int priority;
  Boolean enabled;

  Pattern(int patternid, Route[][] globalRoutes) {
    enabled = false;
    routes = new Route[4];
    // SIDES - 0 = left, 1 = top, 2 = right, 3 = bottom
    // From X to Y
    int[][] patterns = {{01,02,20,23},
                        {01,03,12,30},
                        {01,12,23,30},
                        {01,02,03,30}};
    // xy
    // x = Pattern index
    // y = Rotation / 90
    int[] possiblePatterns = {00,01,10,11,12,13,20,30,31,32,33};
    int patternCode = possiblePatterns[patternid];
    int[] pd = decode(patternCode);
    int[] pattern = patterns[ pd[0] ];
    int rotation = pd[1];

    routePrint = new String[4];

    for(int i=0; i<4; i++) {
      int turn = pattern[i];
      int[] rotated = routeRotate(turn, rotation);
      int a = ((rotated[1] - rotated[0]) % 4) - 1;
      if(a<0) a+=4;
      int b = rotated[0];
      routePrint[i] = str(a) + str(b);
      routes[i] = globalRoutes[a][b];
    }
  }

  int[] decode(int turn){
    int[] returnVal = new int[2];
    returnVal[1] = turn % 10;
    returnVal[0] = (turn - returnVal[1]) / 10;
    return returnVal;
  }

  int[] routeRotate(int code, int rotation) {
    int to = ((code % 10) + rotation) % 4;
    int from = ((code - (code%10)) + (10*rotation)) % 40;
    return decode(to + from);
  }

  int getPriority(){
    int total = 0;
    for(Route route : routes){
      switch(priorityCalc) {
        case 1:
          total += route.getPriority1();
          break;
        case 2:
          total += route.getPriority2();
          break;
        case 3:
          total += route.getPriority3();
          break;
        case 4:
          total += route.getPriority4();
          break;
      }
      
    }
    print(str(total));
    return total;
  }

  void printPattern() {
    for(int i=0; i<4; i++) {
      print(routePrint[i]);
      print(" ");
    }
    println("------");
  }

  void tick(){
    for(Route route : routes) {
      route.enabled = enabled;
    }
  }
}

class Junction{
  Pattern[] patterns;
  Route[][] routes;
  Pattern enabledPattern;
  Boolean enabled;
  int timerDisabled;
  int patternIndex;

  Junction() {
    // Setup Routes
    routes = new Route[3][4];
    for(int i=0; i<3; i++) {
      for(int j=0; j<4; j++) {
        routes[i][j] = new Route(i, j);
      }
    }

    // Setup patterns
    patterns = new Pattern[11];
    for(int i=0; i<11; i++) {
      patterns[i] = new Pattern(i, routes);
    }

    enabled = false;
    timerDisabled = 2 * constFrameRate;
    patternIndex = int(random(patterns.length));
    enabledPattern = patterns[ patternIndex ];
  }

  void tick() {
    for(int i=0; i<3; i++) {
      for(int j=0; j<4; j++) {
        routes[i][j].draw();
      }
    }
    
    if(enabled) {

      for(int i=0; i<3; i++) {
        for(int j=0; j<4; j++) {
          routes[i][j].tick();
        }
      }

      for( Pattern pattern : patterns) {
        pattern.tick();
      }

      if(timerDisabled > 0) {
        timerDisabled--;
      } else if( priorityFixed ){
        // Cycle through the patterns with a fixed time
        enabledPattern.enabled = false;
        patternIndex = (patternIndex+1) % patterns.length;
        enabledPattern = patterns[patternIndex];
        enabledPattern.enabled = true;
        print("Switched\n");
        enabledPattern.printPattern();
        timerDisabled = constFixedTimer;
      } else {
        // Compare the priorities of each pattern
        int currentPriority = enabledPattern.getPriority() + constSwitchPriority;
        print("!!!");
        for( Pattern pattern : patterns) {
          if( pattern.getPriority() > currentPriority) {
            enabledPattern.enabled = false;
            enabledPattern = pattern;
            enabledPattern.enabled = true;
            println("Switch");
            timerDisabled = 2*constFrameRate;
          }
        }
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

Junction myJunction;

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
  
  myJunction = new Junction();
  myJunction.enabled = true;

  // r = new Route[12];
 
  // r[0] = new Route(0, 0);
  // r[1] = new Route(1, 0);
  // r[2] = new Route(2, 0);
  
  // r[3] = new Route(0, 1);
  // r[4] = new Route(1, 1);
  // r[5] = new Route(2, 1);
  
  // r[6] = new Route(0, 2);
  // r[7] = new Route(1, 2);
  // r[8] = new Route(2, 2);
  
  // r[9] = new Route(0, 3);
  // r[10] = new Route(1, 3);
  // r[11] = new Route(2, 3); 
}

// Draw function
void draw(){
   image(imgRoad, 0, 0);
   myJunction.tick();
  
  if (keyPressed){
    if(myJunction.enabled){
      myJunction.enabled = false;
    } else {
      myJunction.enabled = true;
    }
  }
   
  //  for (int i = 0; i < 12; i++){
  //    r[i].tick();
  //    r[i].draw();
  //  }
}

