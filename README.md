#Update Oct 2, 2015: Sparse Matrix Approach

The game board is a key entity in the Game of Life. One of the core decisions is how to separate the concepts of Board and Cell. Almost all approaches end up with one or the other of Board or Cell being small or non-existent. The relationship between Cells must be modelled either by an ordered structure, or by connections between Cells (such as my suggestion of creating links from a Cell to its up-to-8 neighbours). In the former case, the Board ends up being a two-dimensional Array (or similar) with a vestigial Cell class that needs to ask the Board for help with everything except the answer to "Are you alive?". In the latter case, the Cell is a first-class entity and, unless the Board and Cell are highly coupled, the Board can do nothing but point to the "first" Cell.

The sparse matrix approach uses a Dictionary of Keys [https://en.wikipedia.org/wiki/Sparse_matrix] to store the locations of the live cells. "Dead" cells are not stored. As Mark stated, it uses quite a bit less memory than most other approaches, and will scale quite well to very large Board dimensions. In a fully-defined version, the Cell class would be a real class rather than a Set [http://c2.com/cgi/wiki?PrimitiveObsession]. A Set (or Hash) makes sense since each has a quick lookup function. But because of this inappropriate choice, the Cell methods (such as #coord_to_key, #cell_alive? and #dead?) are part of the Board class (Primitive Obsession leads to this). Further, there are no tests. This should not be the case, but Code Retreat sessions are short!

According to Code Retreat rules, this code should have been deleted at the end of the session, but I hope that you Ruby Hackers might find something useful in seeing the sparse matrix approach in the flesh. Enjoy.

To start the game:
ruby lib/play.rb

To stop the game, type &lt;Ctrl-C&gt;. The game will automatically stop if all cells die.


Game of Life Code Retreat Workshop
==================================

This repo contains an exercise for the tenth workshop - our first Code Retreat. This workshop is about developer skills. For this session we have based our activities on the Game of Life Code Retreat.

We've restructured the repository to provide a quick-start to TDD with RSpec and to mimic the setup we have been using in the workshops. The code to be created is found in the ``lib/`` directory, and we have supplied unit tests in the ``spec/`` directory.

###Setup

Here are the steps to get you started with the repo. We assume, naturally, that you have a working development machine with Ruby 1.9 or better on it. At Ryatta Group we use rbenv, and so we've included some optional elements - just skip them if you're using rvm or are not versioning your Ruby.

```sh
% git clone git@github.com:k00ka/game-of-life.git
% cd game-of-life
% gem install bundler
Fetching: bundler-1.7.4.gem (100%)
Successfully installed bundler-1.7.4
1 gem installed
% bundle
Fetching gem metadata from https://rubygems.org/.........
Resolving dependencies...
Installing rake 10.3.2
...
Using bundler 1.7.4
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
```
######Note: if you use rbenv...
```sh
% rbenv rehash
```
You are (almost) there!

###TDD
If you want to learn (more) about TDD, there are plenty of online resources. For a quick primer, you can review our blog post from the previous workshop: [http://www.ryatta.com/refactoring-in-context/]

Tonight (or below if you're doing this exercise on your own), I’m going to give you some directions for what your solution should do. In response to these requests, you are going to:

1. Write a test or tests that translate my request into code
1. Demonstrate to yourself that those test(s) fail
1. Implement modifications to make the tests pass
1. Share your implementation with the team

We'll iterate on this pattern about 11 times so you can practice the TDD workflow.

####Tips
* Implement the simplest code you can imagine to make the tests pass.
* Once the tests pass, refactor the code to simplify it.
* Let earlier tests stand, they will catch regressions.
* Discuss edge cases and obscure aspects with the customer or others on your team.

###How to test

There is an empty file (well, almost empty) in the ``lib/`` directory. It is called ``game_of_life.rb``. This is part 1 of your deliverable.

There is a unit test file in the ``spec/`` directory called ``game_of_life_spec.rb``. This is part 2 of your deliverable.

To play the Game of Life, you need to make both files work together.
To run the tests we have written against the code we've developed, do the following:
```sh
% rspec
F

Failures:

  1) GameOfLife#something returns an empty board given an empty board
     Failure/Error: expect(GameOfLife.step(empty_board)).to eq(empty_board)
     NameError:
       undefined local variable or method `empty_board' for #<RSpec::ExampleGroups::GameOfLifeSomething:0x007faad89e3ec0>
     # ./spec/game_of_life_spec.rb:11:in `block (2 levels) in <top (required)>'

Finished in 0.00052 seconds (files took 0.08027 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./spec/game_of_life_spec.rb:10 # GameOfLife#something returns an empty board given an empty board
```

The text ``1 failure`` means you're currently failing! Now go fix some code and share what you've learned with the group.

###Game of Life Rules

The universe of the Game of Life is an infinite two-dimensional orthogonal grid of square cells, each of which is in one of two possible states, live or dead. Every cell interacts with its eight neighbors, which are the cells that are directly horizontally, vertically, or diagonally adjacent. At each step in time, the following transitions occur:

* Any live cell with fewer than two live neighbours dies, as if caused by underpopulation.
* Any live cell with more than three live neighbours dies, as if by overcrowding.
* Any live cell with two or three live neighbours lives on to the next generation.
* Any dead cell with exactly three live neighbours becomes a live cell.

The initial pattern constitutes the seed of the system. The first generation is created by applying the above rules simultaneously to every cell in the seed?births and deaths happen simultaneously, and the discrete moment at which this happens is sometimes called a tick (in other words, each generation is a pure function of the one before). The rules continue to be applied repeatedly to create further generations.
