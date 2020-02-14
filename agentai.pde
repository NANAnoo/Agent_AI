import java.util.*;

List<Agent> eater, producer;

float food_R = 0;
float food_X = 0;
float food_Y = 0;
int group_size = 20;
int insize = 8;
float r_e = 7;
float r_p = 7;

//float wall_x = width/2;
//float wall_y = height/2;
//float wall_r = min(height,width)/2;

void newFood(){
  food_R = random(80,100);
  food_X = random(food_R, width - food_R);
  food_Y = random(food_R, height - food_R);
}

void setup(){
  size(800, 800);
  background(255, 255, 255);
  // frameRate(60);
  newFood();
  eater = new ArrayList();
  producer = new ArrayList();
  for(int i=0;i<group_size;i++){
    producer.add(new Agent(random(r_p,width-r_p),random(r_p,height-r_p),random(0,2*PI),r_p));
    eater.add(new Agent(random(r_e,width-r_e),random(r_e,height-r_e),random(0,2*PI),r_e));
  }
  
}

void update(){
  for(int i=0;i<producer.size();i++){ //<>//
    if(producer.get(i).collide(food_X,food_Y,food_R)){
      if(producer.get(i).energe<1200){
        producer.get(i).eat(30);
        if(producer.get(i).energe<100)
            producer.get(i).eat(100);
        food_R-=1;
        if(food_R<=40){
          newFood();
        }
      }
    }
    for(int j=0;j<eater.size();j++){
      if(producer.get(i).collide(eater.get(j).pos_X,eater.get(j).pos_Y,eater.get(j).R)){ //<>//
        if(eater.get(j).energe<1200){
          eater.get(j).eat(100);
          producer.get(i).energe -= 100;
          if(eater.get(j).energe<200)
            eater.get(j).eat(200);
          if(producer.get(i).energe<0){
            producer.remove(i);
            i--;
          }
          break;
        }
      }
    }
  }
  ////////////////////////////////////
  ////////  update producer  /////////
  ////////////////////////////////////
  for(int i=0;i<producer.size();i++){
    float []to_food,
    to_eater = new float[insize],
    to_producer = new float[insize],
    min = new float[insize];
    for(int j=0;j<insize;j++)min[j]=1000000;
    // get food dis first
    to_food = producer.get(i).getDis(food_X,food_Y,food_R);
    for(int m=0;m<insize;m++){
      if(to_food[m]<10000)to_food[m]=r_p;
    }
    
    // get dis to eater
    for(int j=0;j<eater.size();j++){ //<>//
      to_eater = producer.get(i).getDis(eater.get(j).pos_X,eater.get(j).pos_Y,eater.get(j).R);
      for(int k=0;k<insize;k++)
        if(to_eater[k]<min[k])
          min[k] = to_eater[k];
    }
    for(int j=0;j<insize;j++){
      to_eater[j] = min[j];
      min[j]=1000000;
    }
    // get dis to producer
    for(int j=0;j<producer.size();j++){
      if(i!=j){
        to_producer = producer.get(i).getDis(producer.get(j).pos_X,producer.get(j).pos_Y,producer.get(j).R);
        for(int k=0;k<insize;k++)
        if(to_producer[k]<min[k])
          min[k] = to_producer[k];
      }
    }
    for(int j=0;j<insize;j++)
      to_producer[j] = min[j];
    // get dis to wall
    
    // process input
    float []input = new float[insize*3 + 6];
    for(int j=0;j<insize*3;j+=3){
      int m = j/3;
      input[j] = r_p/to_food[m];
      input[j+1] = sqrt(r_p/to_eater[m]);
      input[j+2] = sqrt(r_p/to_producer[m]);
    }
    input[insize*3] = 2*abs(producer.get(i).pos_X -width/2)/width;
    input[insize*3 +1] = 2*abs(producer.get(i).pos_Y -height/2)/height;
    producer.get(i).think(input);
    if(!producer.get(i).update(0.05)){
      producer.remove(i);
      i--;
    }
  }
  ////////////////////////////////////
  ////////  update   eater   /////////
  ////////////////////////////////////
  
  for(int i=0;i<eater.size();i++){
    float []to_food,
    to_eater = new float[insize],
    to_producer = new float[insize],
    min = new float[insize];
    for(int j=0;j<insize;j++)min[j]=1000000;
    // get food dis first
    to_food = eater.get(i).getDis(food_X,food_Y,food_R);
    
    // get dis to eater
    for(int j=0;j<eater.size();j++){
      if(i!=j){
        to_eater = eater.get(i).getDis(eater.get(j).pos_X,eater.get(j).pos_Y,eater.get(j).R);
        for(int k=0;k<insize;k++)
          if(to_eater[k]<min[k])
            min[k] = to_eater[k];
      }
    }
    for(int j=0;j<insize;j++){
      to_eater[j] = min[j];
      min[j]=1000000;
    }
    
    // get dis to producer
    for(int j=0;j<producer.size();j++){
      to_producer = eater.get(i).getDis(producer.get(j).pos_X,producer.get(j).pos_Y,r_p);
      for(int k=0;k<insize;k++)
      if(to_producer[k]<min[k])
        min[k] = to_producer[k];
    }
    for(int j=0;j<insize;j++){
      if(min[j]<10000)to_producer[j] = 1 + sqrt(r_e/min[j]);
      else to_producer[j]=0;
    }
    
    // process input
    float []input = new float[insize*3 + 6];
    for(int j=0;j<insize*3;j+=3){
      int m = j/3;
      input[j] = sqrt(r_e/to_food[m]);
      input[j+1] = sqrt(r_e/to_eater[m]);
      input[j+2] = to_producer[m];
    }
    input[insize*3] = 2*abs(eater.get(i).pos_X -width/2)/width;
    input[insize*3 +1] = 2*abs(eater.get(i).pos_Y -height/2)/height;
    eater.get(i).think(input);
    if(!eater.get(i).update(0.05)){
      eater.remove(i);
      i--;
    }
  }

}

void create(){
  int size = eater.size();
  
  for(int i=0;i<size;i++){
    if(eater.get(i).energe>1000&& eater.get(i).child>0){
      eater.add(eater.get(i).crossover(eater.get((int)random(0,size)),0.02));
      eater.get(i).child--;
      eater.get(i).energe=600;
    }
  }
  
  if(eater.size()<group_size/4){
    eater.add(new Agent(random(r_e,width-r_e),random(r_e,height-r_e),random(0,2*PI),r_e));
    
    for(int i=0;i<group_size/2;i++){
      eater.add(eater.get((int)random(0,size)).crossover(eater.get((int)random(0,size)),0.02));
    }
    for(int i=0;i<eater.size();i++){
      if(eater.get(i).energe<610)
       eater.get(i).energe = 600 +(int)random(0.10);
    }
  }
  /////////////////////////////////
  size = producer.size();
    for(int i=0;i<size;i++){
    if(producer.get(i).energe>1000&&producer.get(i).child>0){
      producer.add(producer.get(i).crossover(producer.get((int)random(0,size)),0.05));
      producer.get(i).child--;
      producer.get(i).energe=600;
    }
  }
  if(producer.size()<group_size/4){
    producer.add(new Agent(random(r_p,width-r_p),random(r_p,height-r_p),random(0,2*PI),r_p));

    for(int i=0;i<group_size/2;i++){
      producer.add(producer.get((int)random(0,size)).crossover(producer.get((int)random(0,size)),0.05));
    }
    for(int i=0;i<producer.size();i++){
      if(producer.get(i).energe<610)
        producer.get(i).energe = 600 +(int)random(0.10);
    }
  }
}

void draw(){
  background(255);
  noStroke();
  fill(#05E4FF);
  circle(food_X,food_Y,2*food_R);
  strokeWeight(2);
  for(int i=0;i<producer.size();i++){
    stroke(125,182,104);
    producer.get(i).display();
  }
  for(int i=0;i<eater.size();i++){
    stroke(185,132,104);
    eater.get(i).display();
  }
  update();
  create();
}
