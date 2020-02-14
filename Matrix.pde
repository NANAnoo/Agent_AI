class Matrix {
  
  int rows, cols;
  float[][] matrix;
  
   Matrix(int r, int c) {
     rows = r;
     cols = c;
     matrix = new float[rows][cols];
   }
   
   Matrix(float[][] m) {
      matrix = m;
      rows = matrix.length;
      cols = matrix[0].length;
   }
   
   void output() {
      for(int i = 0; i < rows; i++) {
         for(int j = 0; j < cols; j++) {
            print(matrix[i][j] + " "); 
         }
         println();
      }
      println();
   }
   
   Matrix activate(Matrix n) {
     Matrix result = new Matrix(rows + 1, 1);
     
     if(cols == n.rows) {
        for(int i = 0; i < rows; i++) {
            float sum = 0;
            for(int k = 0; k < cols; k++) {
               sum += matrix[i][k]*n.matrix[k][0];
            }  
            result.matrix[i][0] = max(0,sum);
           }
     }
     result.matrix[rows][0] = 1;
     return result;
   }
   
   void randomize() {
      for(int i = 0; i < rows; i++) {
         for(int j = 0; j < cols; j++) {
            matrix[i][j] = random(-1,1); 
         }
      }
   }
   
   Matrix singleColumnMatrixFromArray(float[] arr) {
      Matrix n = new Matrix(arr.length, 1);
      for(int i = 0; i < arr.length; i++) {
         n.matrix[i][0] = min(arr[i],1); 
      }
      return n;
   }
   
   float[] toArray() {
      float[] arr = new float[rows*cols];
      for(int i = 0; i < rows; i++) {
         for(int j = 0; j < cols; j++) {
            arr[j+i*cols] = matrix[i][j]; 
         }
      }
      return arr;
   }
   
   Matrix addBias() {
      Matrix n = new Matrix(rows+1, 1);
      for(int i = 0; i < rows; i++) {
         n.matrix[i][0] = matrix[i][0]; 
      }
      n.matrix[rows][0] = 1;
      return n;
   }
   
   void mutate(float mutationRate) {
      for(int i = 0; i < rows; i++) {
         for(int j = 0; j < cols; j++) {
            float rand = random(1);
            if(rand<mutationRate) {
               matrix[i][j] += randomGaussian()/5;
               
               if(matrix[i][j] > 1) {
                  matrix[i][j] = 1;
               }
               if(matrix[i][j] <-1) {
                 matrix[i][j] = -1;
               }
            }
         }
      }
   }
   
   Matrix crossover(Matrix partner) {
      Matrix child = new Matrix(rows, cols);
      
      int randC = floor(random(cols));
      int randR = floor(random(rows));
      
      for(int i = 0; i < rows; i++) {
         for(int j = 0;  j < cols; j++) {
            if((i  < randR) || (i == randR && j <= randC)) {
               child.matrix[i][j] = matrix[i][j]; 
            } else {
              child.matrix[i][j] = partner.matrix[i][j];
            }
         }
      }
      return child;
   }
   
   Matrix clone() {
      Matrix clone = new Matrix(rows, cols);
      for(int i = 0; i < rows; i++) {
         for(int j = 0; j < cols; j++) {
            clone.matrix[i][j] = matrix[i][j]; 
         }
      }
      return clone;
   }
}
