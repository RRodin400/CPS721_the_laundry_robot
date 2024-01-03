%%%%% Group Members:
%%%%% NAME: Dishu Bansal
%%%%% NAME: Gurveen Kaur
%%%%% NAME: Rachelle Rodin

%%%%% SECTION: dynamic_laundry
%%%%% These lines allow you to write statements for a predicate that are not consecutive in your program
:- dynamic clean/2.
:- dynamic wet/2.
:- dynamic folded/2.
:- dynamic holding/2.
:- dynamic hasSoap/2.
:- dynamic hasSoftener/2.
:- dynamic hasLint/2.
:- dynamic in/3.
:- dynamic container/1.


%%%%% SECTION: planner_laundry
%%%%% This line loads the generic planner code from the file "planner.pl"
:- [planner].


%%%%% SECTION: init_laundry
%%%%% Loads the initial state from the file laundryInit.pl
%%%%% HINT: You can create other files with other initial states to more easily test individual actions
%%%%% To do so, just replace the line below with one loading in the file with your initial state
:- [laundryInit].


%%%%% SECTION: goal_states_laundry
%%%%% Below we define different goal states, each with a different ID
goal_state(1, S) :- clean(cl1,S).
goal_state(2, S) :- clean(cl1,S), not wet(cl1,S).
goal_state(3, S) :- clean(cl1,S), not wet(cl1,S), folded(cl1,S), in(cl1,dresser,S).

goal_state(100, S) :- clean(cl1,S), clean(cl2,S), not wet(cl1,S), not wet(cl2,S),
        folded(cl1,S), folded(cl2,S), in(cl1,dresser,S), in(cl2,dresser,S).



%%%%% SECTION: precondition_axioms_laundry
%%%%% precondition axioms for all actions in your domain: 

% The following defines different types of objects as containers
% You do not need to edit it
container(X) :- washer(X).
container(X) :- dryer(X).
container(X) :- cupboard(X).
container(X) :- hamper(X).
container(dresser).

% Put the rest of your precondition axioms below
poss(fetch(O, C), S) :- container(C), in(O, C, S), not holding(X, S).

poss(putAway(O, C), S) :-  container(C), holding(O, S), not in(O,C,S).

poss(addSoap(P, W), S) :- soap(P), washer(W), not hasSoap(W, S), holding(P, S). 

poss(addSoftener(T, W), S) :- softener(T), washer(W),  not hasSoftener(W, S), holding(T, S).

poss(removeLint(D), S) :- dryer(D), hasLint(D, S), not holding(X, S).

poss(washClothes(C, W), S) :- washer(W), hasSoftener(W, S), hasSoap(W, S), clothes(C), in(C, W, S), not clean(C, S).

poss(dryClothes(C, D), S) :- dryer(D), clothes(C), in(C, D, S), wet(C, S), not hasLint(D, S).

poss(fold(C), S) :- clothes(C), clean(C, S), not wet(C, S), not folded(C, S), not holding(X, S). 

poss(wear(C), S) :- clothes(C), folded(C, S).

poss(move(C, F, T), S) :- clothes(C), container(F), in(C, F, S), container(T), not F=T, not holding(X, S).

%%%%% SECTION: successor_state_axioms_laundry 
%%%%% successor-state axioms that characterize how the truth value of all 
%%%%% fluents change from the current situation S to the next situation [A | S]. :
in(O, C, [putAway(O,C) | S]).
in(O, C, [move(O,F,C) | S]).
in(O, C, [A|S]) :- not A = fetch(O,C), not A = move(O,C,Somewhere), in(O,C,S).

holding(O, [fetch(O,C) | S]).
holding(O, [A | S]) :- not A = putAway(O,C), not A = addSoap(O,C), not A = addSoftener(O,C), holding(O,S).  

hasSoap(W,[addSoap(P,W) | S]).
hasSoap(W, [A | S]) :- not A = washClothes(C,W), hasSoap(W,S).

hasSoftener(W,[addSoftener(T,W) |S]).
hasSoftener(W,[A |S]) :- not A = washClothes(C,W), hasSoftener(W,S).

hasLint(D, [dryClothes(C,D) | S]).
hasLint(D, [A| S]) :- not A = removeLint(D), hasLint(D,S).

clean(C,[washClothes(C,W) | S]).
clean(C, [A|S]) :- not A = wear(C), clean(C,S).

wet(C, [washClothes(C,W) | S]).
wet(C, [A | S]) :-  not A = dryClothes(C,D), wet(C, S).

folded(C, [fold(C) | S]).
folded(C, [A | S]) :- not A = wear(C), folded(C,S).    


%%%%% SECTION: declarative_heuristics_laundry
%%%%% The predicate useless(A,ListOfPastActions) is true if an action A is useless given the list of previously performed actions:
useless(fetch(O,C), [fetch(_,C) | S]). % Fetching twice from same Container is useless since there can be only 1 item in container.
useless(fetch(O,C), [fetch(O,_) | S]). % Fetching same object twice from 2 containers (same or different) is useless since an object can be only 1 container at a time.
useless(putAway(O,C), [ putAway(_,C) | S]). % Putting Away twice in same Container is useless since there can be only 1 item in container.
useless(putAway(O,C), [ putAway(O,_) | S]). % Putting away same object twice in 2 containers (same or different) is useless since an object can be only 1 container at a time.
useless(addSoap(P, W), [addSoap(_, W) | S]). % Adding Soap in same washer twice is useless since washer can contain only one soap at a time.
useless(addSoap(P, W), [addSoap(P, _) | S]). % Adding same soap in 2 washers is useless since one soap can be in one washer only at a time.
useless(addSoftener(T, W), [addSoftener(_, W) | S]). % Adding Softener in same washer twice is useless since washer can contain only one soap at a time.
useless(addSoftener(T, W), [addSoftener(T, _) | S]). % Adding same Softener in 2 washers is useless since one soap can be in one washer only at a time.
useless(removeLint(D), [removeLint(D) | S]). % Removig Lint twice is useless.
useless(washClothes(C, W), [washClothes(_, W) | S]). % Washing Clothes twice is useless.
useless(washClothes(C, W), [washClothes(C, _) | S]). % Washing clothes twice is useless. 
useless(dryClothes(C, D), [dryClothes(_, D) | S]). % drying clothes twice is useless.
useless(dryClothes(C, D), [dryClothes(C, _) | S]). % Drying Clothes twice is useless.
useless(fold(C), [fold(C) | S]). % Folding cloths twice is useless.
useless(wear(C), [wear(C) | S]). % Wearing cloths twice is useless.
useless(move(C, F, T), [move(C, F, T) | S]). % moving Clothes from between same containers is useless.
useless(move(C, T, T2), [move(C, F, T) | S]). % Moving clothes through an intermediate container is useless.
useless(move(C, T, T), _). % Moving clothes to same container is useless.
useless(move(C, F, T), [A|S]):- A = move(_,_,_), useless(move(C,F,T), S). % Same Useless moves as above uninterrupted by a different move action with other object.

useless(fetch(O,C), [putAway(O,C) | S]). % fetching from same container we just put away object in is useless.
useless(putAway(O,C), [ fetch(O,C) | S]). % putting away in same container you fetched from is useless.
useless(move(C, F, T), [ move(C, T, F) | S]). % Moving back and forth between 2 containers is useless.
useless(putAway(O, C1), [fetch(O, C) | S]). % putting away in a different object after fetching is useless. Directly use Move.
useless(fetch(O, C1), [putAway(O, C) | S]). % Fetching from a different container than putting away is useless since object is not in other container.  
useless(fetch(O, C), [move(O, _, C) | S]). % Fetching away from same container we just put clothes in.
useless(move(O, C, _), [putAway(O, C) | S]). % moving away from same container we just put clothes in.





