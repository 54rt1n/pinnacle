# PINNACLE - 11 - The Simulation

## Overview
The world system creates a canvas which we need to paint with a vibrant and engaging game world.  The juxtaposition of
80's RPG styling and a complex and dynamic game world is key to building an amazing experience for our user.

First, we must cover a brief overview of the game, and formulate our objectives.

### Concept

How does this game work?  We are measuring the `Order` scale to create a stable world state, simulated over an n-turn
timeline, and then overlay quests which either direct the world state towards order or chaos.

#### Order Win

An `Order Win` is when the world grows so stable and peaceful, that on the `Order` scale it is over the `Order Win Threshold`.

#### Chaos Win

A `Chaos Win` is when the world grows so unstable that society completely collapses, that on the `Order` scale it is
below the `Chaos Win Threshold`.

#### Objective

Our initial simulation will be iterative attempts to achieve a stable game world state.  At some point when we achieve a
good stable world, we roll back some N-(thousand)-turns and build our story from there.  We will need a log of the world
history events, with genealogies.

## Data

### Schema

The world is represented by several data files which are layered together to produce the world.  We will use image files
to store application state data, since it both well represents our grid, is highly portable for viewing and editing.  
Expect all data files to be RGB images.

#### Overworld

* For `Overworld` data files, the color value maps to specific `Terrain` types. (Brown-Grey for mountains, darker green
for trees, lighter green for plains, blue for ocean, light blue for streams.)
* For `Party` data files, the color value maps to specific `Party` id's.  The party id will be created when a `Party`
leaves a `Town`.  New id's will be close in color to the average of the character_ids of the members.
* For `Interactive` data files, the color values are Whites for `Town`s, and colors towards various themes for other
interaction types.  This functionality is TBD.

#### Locations

* For `Location` data files, the color value maps to specific `Terrain` types, like in the `Overworld`.
* For `Character` data files, the color value maps to specific `Character` id's.  The character id will be an available
value between the character id's of the parents.
* For `Interactive` data files, the color values are different items and whatnot.  This functionality is TBD.

#### Cartography

* `terrain.json` contains a master cartography document, with `Terrain` metadata for each `terrain_id`
* `cartography.json` contains a master cartography document, with `Location` metadata for each `location_id`
* `interactives.json` contains a master interaction document.  It will provide `Interactive` metadata for each `interactive_id`.

#### Jobs

What are jobs?

#### Awesome Idea

Triplet loss is a loss function commonly used in deep learning for learning embeddings and has been successfully applied in various
tasks, such as image retrieval and face recognition (Schroff et al., 2015). The key idea behind triplet loss is to learn
representations that bring similar samples closer together and push dissimilar samples further apart in the embedding space.

In the context of the game, we could potentially train the reinforcement learning agent using triplet loss to learn a
better policy based on the experiences in both Order and Chaos universes. To do this, you would need to define the
similarities and dissimilarities between the character's experiences in these universes. For example, a similar experience
might be a character performing the same action with similar motivations, whereas a dissimilar experience could involve
the character performing different actions in response to different motivations.

One way to implement this idea is to use Deep Reinforcement Learning (DRL) algorithms, such 
as Deep Q-Networks (DQN) (Mnih et al., 2015) or Proximal Policy Optimization (PPO) (Schulman et al., 2017), 
with triplet loss as an additional regularization term in the loss function. This could help the agent learn a more 
robust policy by utilizing the experiences from both universes.

Here are some sources for reference:

* Schroff, F., Kalenichenko, D., & Philbin, J. (2015). FaceNet: A Unified Embedding for Face Recognition and Clustering.
Proceedings of the IEEE Conference on Computer Vision and Pattern Recognition (CVPR), 815-823.
* ( Mnih, V., Kavukcuoglu, K., Silver, D., Rusu, A. A., Veness, J., Bellemare, M. G., ... & Hassabis, D. (2015). Human-level
control through deep reinforcement learning. Nature, 518(7540), 529-533.
* Schulman, J., Wolski, F., Dhariwal, P., Radford, A., & Klimov, O. (2017). Proximal Policy Optimization Algorithms. 
arXiv preprint arXiv:1707.06347.

A high-level algorithm for training a reinforcement learning network using triplet loss with experiences from the Order and Chaos universes:

Initialize the DRL agent with a neural network architecture. You can choose an algorithm like DQN or PPO as the base
algorithm. The agent's network should produce embeddings for states, actions, or state-action pairs, depending on the
problem setting.

Collect experiences in both Order and Chaos universes. Store these experiences in separate replay buffers, one for each
universe. Each experience should include the state, action, reward, next state, and a done flag.

During the training phase, sample mini-batches of experiences from both replay buffers. For each mini-batch, calculate
the DRL algorithm's primary loss (e.g., TD-error for DQN or policy gradient loss for PPO).

For each experience in the mini-batch, create triplets. A triplet consists of an anchor experience (A), a positive
experience (P), and a negative experience (N). The anchor experience is from the current universe (either Order or Chaos).
The positive experience is a similar experience from the same universe, while the negative experience is a dissimilar
experience from the other universe. You will need to define a similarity metric for selecting positive and negative experiences.

Pass the anchor, positive, and negative experiences through the agent's neural network to obtain their embeddings: 
E_A, E_P, and E_N.

Compute the triplet loss for the mini-batch using the embeddings:

TripletLoss = max(0, margin + ||E_A - E_P||^2 - ||E_A - E_N||^2),

where margin is a hyperparameter that controls the desired distance between positive and negative pairs.

Combine the primary loss (e.g., TD-error or policy gradient loss) with the triplet loss, using a weighting factor lambda:

TotalLoss = PrimaryLoss + lambda * TripletLoss

Update the agent's neural network parameters using gradient descent on the TotalLoss.

Periodically evaluate the agent's performance in both Order and Chaos universes and adjust hyperparameters (e.g., 
learning rate, lambda, margin) as needed.

Repeat steps 2-9 until the agent converges or a stopping criterion is met.

#### Future

`Character`s might choose to interact with other nearby `Character`s, due to a proximity `Event` which is fired when 
one `Character` enters another `Character`s perception range.

This might have cool effects, if `Character`s follow a schedule, they would see other people at the marketplace, and at
the inn for supper, or go home to the wife that makes `Own`ed food for you.

If you consider Faction Space, one `Character` would feel a color towards another `Character`.  When they interact,
positive would bring the color closer to their own, and negative would push it away from their color.

#### Performance

To make simulation fast, we are going to use vectors to represent our current `Motivation` vector `m` in `Possibility`
space `P`.  `m` is the sum of all `Motivator` vector `v` for a `Character`.  `m` vectors are close to optimal
`Course` `c` vectors in `P`.

We tune our actions through Monte Carlo simulation.


## Simulator

The `Simulator` needs to be very fast, and model actions for every `Character` in the world for every tick.  Ideally
it is written in a very fast language such as rust.  It would be nice for the engine to be used in real-time for actual gameplay.

When `Character`s are in a `Party`, they do not have to be individually simulated for `Motivation`s, just for `Mood` and `Health`.

Each `Location` is simulated separately.

Initial testing will begin with the generation of one `Location` and simulation of one `Town` at that `Location`.

Once we figure out a stable base of `Motivation`s for all `Character`s to survive a long simulation, thus building a
simple stable economic system and growing functionality from there.

It will be useful to have the `Simulator` display a UI containing the world overlay.  The `Overworld` map in the top
left corner, and then each location along the bottom and right sides.  Combat could be a pop-up overlay.

### Possibility Space

Possibility space `P` is the space where `Motivation` induces `Action`, through a `Course` of action.  We are solving
for optimal traversal of this space via Monte Carlo simulation.

#### Monte Carlo

Our Monte Carlo generates N random `Character`s at various degrees of `Health`, `Food`, etc. at a provided `Location`. 
The `Location` is optimal.  The Simulation run_once for N iterations.  The `Order` metric is calculated.  The Simulation
run_many for M iterations, or until `Order` crosses alpha threshold, or win criteria met.

#### Reinforcement Learning

The action chain for each simulation can be represented in a Markov Chain.  The results of the Simulation run_many, along
with the local prior_window, current, and next_window `Order` is backpropogated.

#### This is complicated

So, when we think about the problem, the character has something wrong, or nothing wrong, but has a job.  How did he get
this job?  He just has it I suppose.  So, he does his job, and he makes money doing it.  How does he do this job?  He
collects stuff and brings it to the marketplace.

That is, unless something bad is happening, like, I'm bleeding, or I'm hungry, or I have to use the bathroom.  Characters
know the location of all `Interactive`s in an area that they `Own` or are `Public`.  I guess an interactive can be
flagged as a `Job` as well perhaps, that could make scheduling easier?

We continue, life goes forward.  We need food, we need sleep, and everyone has a job.  We can start from there.



