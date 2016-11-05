Flock flock;
PShape obj;
PImage img;
float scale_val = 0.05;
float SEP_MULTIPLIER = 1.5;
float ALI_MULTIPLIER = 1.0;
float COH_MULTIPLIER = 2.0;
//PShape model;

void setup() {
  print("Enter setup\n");
  size(640, 360, P3D);
  flock = new Flock();
  //img = loadImage("background/deep-blue-space.jpg");
  img = loadImage("background/galaxy.jpg");
  //img = loadImage("background/space-sparkling-stars-1280x720.jpg");
  // Add an initial set of boids into the system
  //obj = loadShape("millenium-falcon.obj");
  //obj = loadShape("Pokeball_Obj.obj");
  //obj = loadShape("Millennium_Falcon/Millennium_Falcon.obj");
  //obj = loadShape("HN 48 Flying Car/HN 48 Flying Car.obj");
  //obj.scale(scale_val,scale_val,scale_val);
  //obj.width = 3.0;
  //obj.height = 3.0;
  //print("obj width: ",obj.width,", obj.height",obj.height);
  int obstacle_count = 1;
  for (int i = 0; i < obstacle_count; i++){
    flock.addObstacle(new Obstacle(width*random(1), height*random(1), random(width/10,height*2/10)));
  }
  
  int flock_count = 150;
  for (int i = 0; i < flock_count; i++) {
    flock.addBoid(new Boid(width/2,height/2));
  }
}

void draw() {
  background(50);
  image(img,0,0,width,height);
  //print("Enter draw");
  //obj.translate(width*4/5,height*2/3);
  //shape(obj);
  flock.run();
  //saveFrame("Frames/####.png");
}

// create a new boid if mousepressed
void mousePressed() {
  if (mouseButton==LEFT){
    flock.addBoid(new Boid(mouseX,mouseY));
  }
}

void mouseMoved() {
  //print("enter mouseMoved");
  if (flock.avoid_mode){
    for(Boid boid : flock.boids){
      boid.avoid(mouseX,mouseY);
    }
    //print("successfully avoided\n");
  }
  else if (flock.arrive_mode){
    for(Boid boid : flock.boids){
      boid.arrive(mouseX,mouseY);
    }
    //print("successfully arrived\n");
  }
}

void keyPressed() {
  if (key=='V' || key=='v'){
    flock.avoid_mode = true;
    flock.arrive_mode = false;
    flock.default_mode = false;
    print("Now it's avoid mode\n");
  }
  else if(key=='R' || key=='r'){
    flock.arrive_mode = true;
    flock.avoid_mode = false;
    flock.default_mode = false;
    print("Now it's arrive mode\n");
  }
  else if(key=='D'||key=='d'){
    flock.default_mode = true;
    flock.avoid_mode = false;
    flock.arrive_mode = false;
    flock.wrapup_mode = true;
    flock.bounce_mode = false;
    print("Go Back to default mode\n");
  }
  else if(key=='B'||key=='b'){
    flock.bounce_mode = true;
    flock.wrapup_mode = false;
    print("Bounce mode\n");
  }
  else if (key=='O'||key=='o'){
    if (flock.obstacle_mode){
      flock.obstacle_mode = false;
    }
    else{
      //flock.obstacle_mode = true;
    }
  }
  else if (key=='S'||key=='s'){
    SEP_MULTIPLIER+=0.5;
    print("Current SEP_MULTIPLIER is:",SEP_MULTIPLIER, "\n");
  }
  else if(key=='A'||key=='a'){
    ALI_MULTIPLIER +=0.5;
    print("Current ALI_MULTIPLIER is:",ALI_MULTIPLIER, "\n");
  }
  else if(key=='C'||key=='c'){
    COH_MULTIPLIER +=0.5;
    print("Current COH_MULTIPLIER is:",COH_MULTIPLIER,"\n");
  }
  else if (key=='W'||key=='w'){
    if (SEP_MULTIPLIER >= 0.5){
      SEP_MULTIPLIER-=0.5;
    }
    print("Current SEP_MULTIPLIER is:",SEP_MULTIPLIER,"\n");
  }
  else if (key=='Q'||key=='q'){
    if (ALI_MULTIPLIER>=0.5){
      ALI_MULTIPLIER-=0.5;
    }
     print("Current ALI_MULTIPLIER is:",ALI_MULTIPLIER,"\n");
  }
  else if (key=='E'||key=='e'){
    if (COH_MULTIPLIER>=0.5){
      COH_MULTIPLIER-=0.5;
    }
     print("Current COH_MULTIPLIER is:",COH_MULTIPLIER,"\n");
  }
}

class Obstacle{
  PVector location;
  float radius;
  float danger_radius;
  Obstacle(float x, float y, float r){
    location = new PVector(x,y);
    radius = r;
    danger_radius = radius*1.5;
  }
  void render(){
    noStroke();
    fill(random(255),random(255),random(255));
    ellipse(location.x, location.y, radius*2, radius*2);
  }
}

// class of flock, a gorup of boids
class Flock {
  
  ArrayList<Boid> boids; 
  ArrayList<Obstacle> obstacles;
  boolean avoid_mode;
  boolean arrive_mode;
  boolean default_mode;
  boolean obstacle_mode;
  boolean wrapup_mode;
  boolean bounce_mode;
  
  Flock() {
    boids = new ArrayList<Boid>(); 
    obstacles = new ArrayList<Obstacle>();
    obstacle_mode = false;
    avoid_mode = false;
    arrive_mode = false;
    default_mode = true;
    wrapup_mode = true;
    bounce_mode = false;
  }
  
  void addBoid(Boid b) {
    boids.add(b);
  }
  
  void addObstacle(Obstacle o){
    obstacles.add(o);
  }
  
  void run() {
    /*if (default_mode){
      for (Boid b : boids) {
        b.run(boids);  // Passing the entire list of boids to each boid individually
      }
    }
    else if (avoid_mode){
      for (Boid b: boids) {
        b.run_avoid(boids);
      }
    }
    else if (arrive_mode){
      for (Boid b: boids){
        b.run_arrive(boids);
      }
    }*/
    if (obstacle_mode){
      for (Obstacle o: obstacles){
        o.render();
      }
    }
    
    for (Boid b: boids) {
      b.run(boids, bounce_mode, obstacle_mode, obstacles);
    }
  }
  
}




// class of boid, an individual obj

class Boid {

  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxF;    // Maximum force
  float maxV;    // Maximum speed

    Boid(float x, float y) {
    //acceleration = new PVector(0, 0); //for 2D simulation
    //location = new PVector(x,y); // for 2D simulation
    location = new PVector(x, y);
    float theta = random(TWO_PI);
    //float phi = random(PI);
    velocity = new PVector(cos(theta), sin(theta));
    acceleration = new PVector(0,0);
    r = 2.0;
    maxV = 2.5;
    maxF = 0.05;
  }

  void run(ArrayList<Boid> boids, boolean bounce_mode, boolean obstacle_mode, ArrayList<Obstacle> obstacles) {
    //print("enter run");
    flock(boids);
    update(bounce_mode, obstacle_mode, obstacles);
    if (!bounce_mode){
      borders_wrapup();
    } else {
      borders_bounce();
    }
    render();
    acceleration.mult(0);//reset
  }

  void flock(ArrayList<Boid> boids) {
    PVector sep = separate(boids);   // Separation
    PVector ali = align(boids);      // Alignment
    PVector coh = cohesion(boids);   // Cohesion
    sep.mult(SEP_MULTIPLIER);
    ali.mult(ALI_MULTIPLIER);
    coh.mult(COH_MULTIPLIER);

    acceleration.add(sep);
    acceleration.add(ali);
    acceleration.add(coh);
  }
  
  void update(boolean bounce_mode, boolean obstacle_mode, ArrayList<Obstacle> obstacles) {
    if (obstacle_mode)
      avoid_obstacle(obstacles);
    velocity.add(acceleration);
    velocity.limit(maxV);
    if (bounce_mode)
      borders_smooth_bounce();
    location.add(velocity);
  }
  
  void avoid_obstacle(ArrayList<Obstacle> obstacles){
    for (Obstacle o : obstacles){
      float d = PVector.dist(location, o.location);
      PVector dir = new PVector(location.x, location.y);
      dir.sub(o.location);
      if (d < o.radius){ //if object is in the obstacle
        //print("enter object is in the obstacle case");
        dir.normalize();
        acceleration.add(dir);
      }
      else if (d > o.radius && d < o.danger_radius){
        float a = asin(o.radius/d);
        float b = atan2(dir.y, dir.x);
        float t = b-a;
        PVector ta = new PVector(o.radius*sin(t), o.radius*(-cos(t)));
        PVector tb = new PVector(-o.radius*sin(t), o.radius*(cos(t)));
        PVector dira = new PVector(ta.x-location.x, ta.y-location.y);
        PVector dirb = new PVector(tb.x-location.x, tb.y-location.y);
        PVector tp_final = new PVector(0,0);
        if (dira.mag()<dirb.mag()){
          tp_final.x = ta.x;
          tp_final.y = ta.y;
        }
        else{
          tp_final.x = tb.x;
          tp_final.y = tb.y;
        }
        PVector mod_force = PVector.sub(tp_final, o.location);
        //float multiplier = mod_force.dot(velocity);
        //mod_force.normalize();
        //if (multiplier<0)
          //multiplier = -1.0;
        //else
          //multiplier = 1.0;
        //mod_force.mult(multiplier);
        acceleration.add(mod_force);
      }
    }
  }
  
  PVector seek(PVector target, boolean slowdown) {
    PVector desired = PVector.sub(target, location);  // A vector pointing from the location to the target
    float d = location.dist(target);

    desired.normalize();
    desired.mult(maxV);
    if (slowdown && d<100.0f){
      desired.mult(d/100.0f); //hacky solution to slowdown the boid
    }

    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxF);  // Limit to maximum steering force
    return steer;
  }
  
  //when the mode is avoid
  void avoid(int x, int y){
    PVector target = new PVector(x,y);
    float d = PVector.dist(location, target);
    acceleration.sub((seek(target,false)).div(d/(width/10)));
    
  }
  
  //when the mode is arrive
  void arrive (int x, int y){
    PVector target = new PVector(x,y);
    acceleration.add(seek(target,true));
    
  }

  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading() + radians(90);
    //float rad = sqrt(velocity.x*velocity.x+velocity.y*velocity.y+velocity.z*velocity.z);
    //float phi = atan(velocity.z/rad);
    //float theta2 = -atan2(-velocity.y,velocity.x)+radians(90);

    //print("theta by heading:",theta,", theta by polr",theta2,"\n");
    //shape(obj);
    //obj.translate(location.x,location.y);
    //obj.rotate(theta);
    //obj.scale(10,10);
    
    fill(200, 100);
    stroke(255);
    pushMatrix();
    translate(location.x, location.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
    
    /*fill(200,100);
    stroke(255);
    pushMatrix();
    translate(location.x,location.y);
    rotate(theta);
    //rotateZ(phi+radians(0));
    beginShape();
    float height = -3*r;
    vertex(0,height,0);
    vertex(r,0,r);
    vertex(r,0,-r);
    vertex(0,height,0);
    vertex(r,0,-r);
    vertex(-r,0,-r);
    vertex(0,height,0);
    vertex(-r,0,-r);
    vertex(-r,0,r);
    vertex(0,height,0);
    vertex(-r,0,r);
    vertex(r,0,r);
    endShape(CLOSE);
    popMatrix();*/
  }

  void borders_wrapup() {
    if (location.x < -r) location.x = width+r;
    if (location.y < -r) location.y = height+r;
    if (location.x > width+r) location.x = -r;
    if (location.y > height+r) location.y = -r;
    
    //float depth = 100;
    //if (location.z < -depth) location.z = abs(depth-location.z);
    //if (location.z > depth) location.z = 0;
    //print("x coord:",location.x," y coord:",location.y, " z coord:", location.z,"\n");
    
    /*if (location.x < -obj.width) location.x = width+obj.width;
    if (location.y < -obj.height) location.y = height+obj.height;
    if (location.x > width+obj.width) location.x = -obj.width;
    if (location.y > height+obj.height) location.y = -obj.height;*/
  }
  
  void borders_smooth_bounce(){
    float divisor = 3.0;
    float mod_force = 0.5;
    if (location.x < width/divisor){
      acceleration.x = acceleration.x+mod_force;
    }
    if (location.y < height/divisor){
      acceleration.y = acceleration.y+mod_force;
    }
    if (location.x > width-width/divisor){
      acceleration.x = acceleration.x-mod_force;
    }
    if(location.y > height-height/divisor){
      acceleration.y = acceleration.y-mod_force;
    }
  }
  
  void borders_bounce(){
  if (location.x < 0){
    location.x = location.x*(-1);
    velocity.x = velocity.x*(-1);
  }
  if (location.y <0) {
    location.y = location.y*(-1);
    velocity.y = velocity.y*(-1);
  }
  if (location.x > width){
    location.x = width-(location.x-width);
    velocity.x = velocity.x*(-1);
  }
  if (location.y > height){
    location.y = height-(location.y-height);
    velocity.y = velocity.y*(-1);
  }
  }

  // Separation
  PVector separate (ArrayList<Boid> boids) {
    //float desiredseparation = 25.0f;
    float desiredseparation = 30.0f;
    PVector steer = new PVector(0, 0);
    int count = 0;
    // check if it's too close for evey boid
    for (Boid other : boids) {
      float d = PVector.dist(location, other.location);
      // if there should be some separation
      if ((d > 0) && (d < desiredseparation)) {
        PVector diff = PVector.sub(location, other.location);
        diff.normalize();
        diff.div(d);        
        steer.add(diff);
        count++;            
      }
    }
    if (count > 0) {
      steer.div((float)count);
    }
    
    if (steer.mag() > 0) {
      steer.normalize();
      steer.mult(maxV);
      steer.sub(velocity);
      steer.limit(maxF);
    }
    return steer;
  }

  // Alignment
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location, other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxV);
      PVector steer = PVector.sub(sum, velocity);
      steer.limit(maxF);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }

  // Cohesion
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);  
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location, other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.location); 
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum, false);  
    } 
    else {
      return new PVector(0, 0);
    }
  }
}