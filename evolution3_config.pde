public class Configuration {
  

//These are the easy-to-edit variables.
final boolean USE_RANDOM_SEED = false;
// determines whether random factors will be determined by the preset seed.
//If this is false, the program will run differently every time.  If it's true, it will run exactly the same.
final int SEED = 38;

// The seed that determines all random factors in the simulation. Same seed = same simulation results,
// different seed = different simulation results.  Make sure USE_RANDOM_SEED is true for this.
final float SORT_ANIMATION_SPEED = 5.0; // Determines speed of sorting animation.  Higher number is faster.
final float MINIMUM_NODE_SIZE = 0.1; // Note: all units are 20 cm.  Meaning, a value of 1 equates to a 20 cm node.
final float MAXIMUM_NODE_SIZE = 1;
final float MINIMUM_NODE_FRICTION = 0.0;
final float MAXIMUM_NODE_FRICTION = 1.0;
final float GRAVITY = 0.005; // higher = more friction.
final float AIR_FRICTION = 0.95; // The lower the number, the more friction.  1 = no friction.  Above 1 = chaos.
final float MUTABILITY_FACTOR = 1.1; // How fast the creatures mutate.  1 is normal.

// Minimum amount of nodes per creature. Creatures will never mutate below
// this amount of nodes.
final int CREATURE_MIN_NODES = 1;
// Minimum amount of muscles per creature. This isn't always respected as sometimes
// muscles have to be removed in case of an invalid structure (see checkForOverlap())
final int CREATURE_MIN_MUSCLES = 1;

// The amount of seconds the simulation runs and is counted for fitness.
final int SIMULATION_SECONDS = 45;

// Log debug messages
final boolean DEBUG = true;

// Speed for showing the creature previews. 1 = real time, 2 = 2x speed, etc. If preview animations
// are slow on your system, increase this value.
final int MINI_SIMULATION_SPEED = 2;

//Add rectangular obstacles by filling up this array of rectangles.  The parameters are x1, y1, x2, y2, specifying
// two opposite vertices.  NOTE: The units are 20 cm, so 1 = 20 cm, and 5 = 1 m.
// ALSO NOTE: y-values increase as you go down.  So -3 is in the air, and 3 is in the ground.  0 is the surface.
final Rectangle[] RECTANGLES = {
// Lower stairs
new Rectangle(2,-0.2,7,1),
new Rectangle(4,-0.4,9,1),
new Rectangle(6,-0.6,11,1),
new Rectangle(8,-0.8,13,1),
new Rectangle(10,-1,15,1),
new Rectangle(12,-1.3,17,1),
new Rectangle(14,-1.6,19,1),
new Rectangle(16,-1.9,21,1),
new Rectangle(18,-2.2,23,1),
new Rectangle(20,-2.5,25,1),
// Some higher separated blocks after a flat area
new Rectangle(40,-1,41,0),
new Rectangle(42,-1,44,0),
new Rectangle(46,-1.2,50,0)
};

// Whether to randomize the rectangles
final boolean RANDOMIZE_RECTANGLES = true;

// Whether to "mutate" the rectangles over time, or use the base set every time. Use a low mutability factor if true.
final boolean RECTANGLES_PROGRESSIVE_MUTATION = false;

// Mutability factor for randomizing the rectangles.
final float RECTANGLES_MUTABILITY_FACTOR = 1.001;

}
