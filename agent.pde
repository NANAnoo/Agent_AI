// Agent class 

class Agent{
  public float pos_X;
  public float pos_Y;
  private float V_X;
  private float V_Y;
  private float W;
  private float A;
  private float[] out_1 = {0,0,0,0};
  public int R;
  public NeuralNet brain;
  public int energe;
  public int child;
  Agent(float x, float y, float a0, int r){
    pos_X = x;
    pos_Y = y;
    V_X = 0;
    V_Y = 0;
    W = 0;
    A = a0;
    R = r;
    child = 2;
    brain = new NeuralNet(insize*3+6,insize*2,4+4,2);
    energe = 600 + (int)random(0,10);
  }
  
  public boolean collide(float x,float y,float r){
    float dx = pos_X - x;
    float dy = pos_Y - y;
    return r + R >= sqrt(dx * dx + dy * dy);
  }
  
  public float[] getDis(float x,float y, float r){
    float alpha = A;
    float []ans = new float[insize];
    float dx = pos_X-x;
    float dy = pos_Y-y;
    float c = dx*dx + dy*dy - r*r;
    for(int i=0;i<insize;i++){
      float vx = cos(alpha);
      float vy = sin(alpha);
      float a = vx*vx + vy*vy;
      float b = 2 * (dx*vx + dy*vy);
      float delta = b*b - 4*a*c;
      if(delta>=0){
        float sd = sqrt(delta);
        float x1 = (-b + sd)/(2*a);
        float x2 = (-b - sd)/(2*a);
        if(x2<=0){
          ans[i] = max(0,x1);
          if(ans[i]==0)ans[i]=100000;
        }else{
          ans[i] = min(x2,x1);
        }
      }else
        ans[i] = 100000;
      alpha+=2*PI/insize;
    }
    return ans;
  }
  
  // update pos and angular of agent
  public boolean update(float dt){
    V_X *= 0.9;
    V_Y *= 0.9;
    W *= 0.9;
    pos_X += V_X * dt;
    pos_Y += V_Y * dt;
    A += W * dt;
    if(pos_X + R > width || pos_X - R<0){
      V_X = -V_X;energe-=10;
    }
    if(pos_Y + R > height || pos_Y - R<0){
      V_Y = -V_Y;energe-=10;
    }
    energe--;
    return energe > 0;
  }
  
  public void eat(int food){
    energe += food;
  }
  
  public Agent crossover(Agent partner,float mr){
    //// generate child near parent
    float b = random(0,2*PI);
    float x = pos_X + random(4,20)*R*cos(b);
    float y = pos_Y + random(4,20)*R*sin(b);
    if(x<0)x = R+random(10,50);
    else if(x>width)x = width - R -1;
    if(y<0)y = R+random(10,50);
    else if(y>width)y = width - R -1;
    Agent child = new Agent(x,y,random(0,2*PI),R);
    child.brain = brain.crossover(partner.brain);
    child.brain.mutate(mr);
    return child;
  }
  
  // put signals vary from 0 to 1
  private void getSignal(float L, float R,float f,float b){
    if(min(L,R)<0.1||L+R<0.1)energe--;
    if(f>b){
      float dv = 3 * min(L, R);
      V_X += dv * cos(A);
      V_Y += dv * sin(A);
      W += (R - L)*0.1;
    }else{
      float dv = -3 * min(L, R);
      V_X += dv * cos(A);
      V_Y += dv * sin(A);
      W += (R - L)*0.1;
    }
  }
  
  public void think(float[] inputsArr){
    float a = 2*PI/insize;
    for(int i=0;i<insize;i++){
      float c = inputsArr[i*3]+inputsArr[i*3+1]+inputsArr[i*3+2];
      stroke(1.0-c/3.0);
      line(pos_X+1.5*R*cos(A+a*i),pos_Y+1.5*R*sin(A+a*i),pos_X+5*R*cos(A+a*i),pos_Y+5*R*sin(A+a*i));
    }
    inputsArr[insize*3 + 2]=out_1[0];
    inputsArr[insize*3 + 3]=out_1[1];
    inputsArr[insize*3 + 4]=out_1[2];
    inputsArr[insize*3 + 5]=out_1[3];
    float []ans = brain.output(inputsArr);
    getSignal(ans[0], ans[1], ans[2], ans[3]);
    out_1[0] = ans[4];
    out_1[1] = ans[5];
    out_1[2] = ans[6];
    out_1[3] = ans[7];
  }
  
  public void display(){
    float h_x = pos_X + R * cos(A);
    float h_y = pos_Y + R * sin(A);
    float c = energe/1200.0 * 100 + 155;
    fill(c);
    circle(pos_X,pos_Y,2*R);
    line(pos_X,pos_Y,h_x, h_y);
  }
}
