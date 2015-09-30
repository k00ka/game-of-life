Game of Life Kata TDD Workshop
==============================

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

###Final Notes

DHH has come out to say that he doesn't follow TDD [http://david.heinemeierhansson.com/2014/tdd-is-dead-long-live-testing.html]. His main concerns were with regard to the unintended impacts on system design that TDD were creating. His preferred approach is to focus on System Testing. Stay tuned to the Ryatta blog for an imformative post about this very topic (how timely!)
