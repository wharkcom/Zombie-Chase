

// 2D Array of objects
Person[] people;

// Number of people
int n = 500;

int gridSize = 120;
int pixelSize = 6;

int second = 0;
boolean surviving = true;

boolean occupied[][];

void setup() {
  size(gridSize * pixelSize + 201, gridSize * pixelSize + 1);

  occupied = new boolean[gridSize][gridSize];

  for ( int i = 0; i < gridSize; i++ ) {
    for ( int j = 0; j < gridSize; j++ ) {
      occupied[i][j] = false;
    }
  }

  people = new Person[n];
  people[0] = new Person(int(random(gridSize)), int(random(gridSize)), true);
  for (int i = 1; i < n; i++) {
    // Initialize each object     
    people[i] = new Person(int(random(gridSize)), int(random(gridSize)), int(random(100)) == 1);
  }
}

void draw() {
  background(255);


  //Count Zombies
  int znum = 0;

  for (int i = 0; i < n; i++) {
    // Move and display each object
    people[i].move();
    people[i].display();

    // Count zombies
    if ( people[i].infected ) {
      znum++;
      //text(znum, 20, 20);
    }

    if ( surviving ) {
      second++;
      fill(255);
      rect(width-200, 0, width, 20);
      fill(0);
      textAlign(RIGHT);
      text((n - znum) + " survivors", width-10, 15);
    }
  }

  // Check to see if everyone is a zombie.
  if (znum == n) {
    textAlign(CENTER, CENTER);
    textSize(100);
    fill(255, 0, 0);
    text("You Lose!", width/2, height/2);
    fill(0);
    textSize(20);
    text("survived for " + int(second/60/60/24) + " days", width/2, height*3/4);
    surviving = false;
  }
}

float randomNormal()
{
  float x = 1.0, y = 1.0,
        s = 2.0; // s = x^2 + y^2
  while(s >= 1.0)
  {
    x = random(-1.0f, 1.0f);
    y = random(-1.0f, 1.0f);
    s = x*x + y*y;
  }
  return x * sqrt(-2.0f * log(s)/s);
}

class Person {
  int x, y;   // x, y location
  boolean infected;
  int chance;

  // Alternate constructor
  Person(int tempX, int tempY, boolean tempI) {
    x = tempX;
    y = tempY;
    infected = tempI;

    while ( occupied[x][y] ) {
      if ( int(random(2)) == 1 )
        x = min(max(x + int(random(3)) - 1, 0), gridSize);
      else
        y = min(max(y + int(random(3)) - 1, 0), gridSize);
    }
    occupied[x][y] = true;
    
    chance = 10 + round(3 * randomNormal());
  }

  void move() {
    if ( infected )
      zombieMove();
    else
      normalMove();
  }

  void moveEast() {
    if ( x < gridSize - 1 ) {
      if ( ! occupied[x+1][y] ) {  
        occupied[x][y] = false;
        x = x + 1;
        occupied[x][y] = true;
      }
    }
  }

  void moveWest() {
    if ( x > 0 ) {
      if ( ! occupied[x-1][y] ) {  
        occupied[x][y] = false;
        x = x - 1;
        occupied[x][y] = true;
      }
    }
  }

  void moveSouth() {
    if ( y < gridSize - 1 ) {
      if ( ! occupied[x][y+1] ) {  
        occupied[x][y] = false;
        y = y + 1; 
        occupied[x][y] = true;
      }
    }
  }

  void moveNorth() {
    if ( y > 0 ) {
      if ( ! occupied[x][y-1] ) { 
        occupied[x][y] = false;
        y = y - 1; 
        occupied[x][y] = true;
      }
    }
  }

  void moveAway(Person from, int chance) {
    // Chance to move in x axis
    if ( int(random(chance)) == 1 ) {
      if ( from.x < x ) {
        moveEast();
      } 
      else if ( from.x == x ) {
        if ( int(random(2)) == 1 ) {
          moveEast();
        } 
        else {
          moveWest();
        }
      }
      else {
        moveWest();
      }
    }

    // Chance to move in y axis
    if ( int (random(chance)) == 1 ) {
      if ( from.y < y ) {
        moveSouth();
      } 
      else if ( from.y == y ) {
        if ( int(random(2)) == 1 ) {
          moveSouth();
        } 
        else {
          moveNorth();
        }
      } 
      else {
        moveNorth();
      }
    }
  }

  void moveTo(Person to, int chance) {
    // Chance to move in x axis
    if ( int(random(chance)) == 1 ) {
      if ( to.x > x ) {
        moveEast();
      } 
      else if ( to.x == x ) {
        if ( int(random(2)) == 1 ) {
          moveEast();
        } 
        else {
          moveWest();
        }
      } 
      else {
        moveWest();
      }
    }
    // Chance to move in y axis
    if ( int (random(chance)) == 1 ) {
      if ( to.y > y ) {
        moveSouth();
      } 
      else if ( to.y == y ) {
        if ( int(random(2)) == 1 ) {
          moveSouth();
        } 
        else {
          moveNorth();
        }
      } 
      else {
        moveNorth();
      }
    }
  }

  // Move in a random direction
  void randomMove(int chance) {
    int direction = int(random(chance));
    switch(direction) {
    case 1:
      moveNorth();
      break;
    case 2:
      moveEast();
      break;
    case 3:
      moveSouth();
      break;
    case 4:
      moveWest();
      break;
    }
  }

  void normalMove() {
    int closest_zombie = -1;
    float closest_dist = 10000000;
    float dist = 0;
    for (int i = 0; i < n; i++ ) {
      if ( people[i]. infected ) {
        dist = pow(people[i].x-x, 2) + pow(people[i].y-y, 2);
        if ( dist < closest_dist ) {
          closest_dist = dist;
          closest_zombie = i;
        }
      }
    }

    if ( closest_dist < 100 ) {
      moveAway(people[closest_zombie], chance);
    } 
    else {
      randomMove(chance*5);
    }
  }

  void zombieMove() {
    float dist = 0;
    int closest = 0;
    float closest_dist = 10000000;

    // Find index of closest person
    for ( int i = 0; i < n; i++) {
      if ( !people[i].infected ) {
        dist = pow(people[i].x-x, 2) + pow(people[i].y-y, 2);
        if ( dist < closest_dist ) {
          closest = i;
          closest_dist = dist;
        }
      }
    }

    // If everyone is a zombie, end
    if ( closest_dist == 10000000 )
      return;

    // text("Distance: " + closestdist, 20, 20 );
    // text("Person: " + people[closest].x + ", " + people[closest].y, 20, 35);
    // text("Zombie: " + x + ", " + y, 20, 50);

    moveTo(people[closest], chance*3);

    if ( closest_dist <= 1 )
      people[closest].infected = true;
  }


  void display() {
    stroke(255);

    if (infected) {
      fill(0, 255, 0);
    }
    else {
      fill(0);
    }
    rect(x * pixelSize, y * pixelSize, pixelSize, pixelSize);
  }
}

