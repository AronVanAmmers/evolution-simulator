# Evolution simulator

Created by [Cary Huang](https://www.youtube.com/channel/UC9z7EZAbkphEMg0SP7rw44A) and released on [OpenProcessing.org](http://www.openprocessing.org/sketch/205807). Many thanks for creating this educational and entertaining gem of code!

Some small functionality added by Aron van Ammers.

Up to now I have been unable to get in contact with the original author Cary Huang. Cary, if you read this, I'd be very happy to move this code over to a repo owned by you with proper attribution of the code. Just message me here.

## License

Unknown!

## Introduction

[Original video explanations by Cary Huang](https://www.youtube.com/watch?v=GOFws_hhZs8)

## Prerequisites

Install [Processing](https://processing.org/) v1.5.1. 

Note that the code currently is NOT compatible with the more recent Processing versions 2 and 3. You'll get an error message "GraphImage cannot be resolved or is not a field" when running. Happy to accept a pull request for anyone making it compatible with Processing 3.

## Running

Open the .pde file in Processing and run it.

## Configuration: changing the simulation

The top of the file contains some easy to edit variables that influence the simulation. They are documented in the file.

Some interesting ones:

Randomization and mutations
* USE_RANDOM_SEED - when true, the simulation is deterministic, i.e. it will give exactly the same results if you would run it again.
* SEED - in combination with USE_RANDOM_SEED, this determines the run. The same number will lead to the same results. 
* MUTABILITY_FACTOR - how fast creatures mutate. Lower values will lead to a monoculture of highly optimized creatures. Higher values give some more variety, but also to a lot of "mishaps" because of nonsuccessful mutations.

Minimum complexity
* CREATURE_MIN_NODES - the minimum amount of nodes that creatures must have. Allows for requiring more complex creatures.
* CREATURE_MIN_MUSCLES - the minimum amount of muscles that creatures must have.

Randomization of obstacles

* RANDOMIZE_RECTANGLES - if true, the rectangles (obstacles) will be randomized over each generation. This will give more versatile creatures an advantage, i.e. creatures that aren't completely optimized to climb a single stairway with identical stairs.
* RECTANGLES_PROGRESSIVE_MUTATION - if true, randomizes the rectangles slightly over each generation. Think of this as a natural environment that slightly changes over time. If false, the rectacles will be completely randomized (from their original configuration) for each generation.
* RECTANGLES_MUTABILITY_FACTOR - sets how much the rectangles are randomized.

