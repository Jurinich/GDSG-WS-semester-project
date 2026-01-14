# GameDevStudents Pong
## Cats disturbing a game of Pong.
## Main Concept
It is a chaotic, cat-themed version of pong where players can collect items and power-ups and where random cat paws appear in the field and swat the ball away.

A multiplayer game that can be played on the GameDevStudents' arcade machine.

## Specification

### Target group
The game should be playable and fun for anyone who attends game-related events. It shouldn't require nor reward a lot of practise.

### Genre
Sports game.

### Art Style
(Insert pictures)

### Forms of Engagement
The game will focus on being a social experience, a game to play with others.

## Gameplay

### Game Setting
The game is set in a room full of pesky cats that will do their best to disturb an innocent game of pong.

### Main Objective
The main objective is to catch incoming balls with one's own paddle and shoot them towards the opponent. When one player fails to catch the ball, the other one scores a point. Whoever scores the most points within 5 minutes wins the game.

### Core Mechanics
- Moving the paddles up and down to reflect the ball.
- The paddles have a concave shape that allows to better control the direction of the ball depending on where on the paddle it impacts.
- Random items will appear in the middle of the field, and players can collect them by reflecting the ball in a way that it goes through the items.
- Players will store the items they collect (up to a certain amount)
- Players can then use the items they collected, one after the other, which will lead to various positive and/or chaotic effects.
- Random obstacles (cat paws) will appear in the middle of the playing field and when the ball collides with them, they will either reflect it or swat it away in some random direction.
- Over time, the ball's velocity will increase

### Items:
Here's a list of item effects that will be implemented
- split up a ball into two seperate balls
- cat paws are more likely to appear and are more likely to swat the ball in the enemy's direction
- speed up time for a few seconds
- slow down time for a few seconds
- throw down a box in the middle of the playing field, a giant cat will spawn, sit in the box and become an obstacle.

### Controls
Since the game is made to be playable on an arcade machine, each player will conrol their paddle with the joystick, and have one button to their item.

## Front End

### Start Screen
The very first screen will have one button for going to the Start-Game-Screen and one for showing the credits. Navigation between buttons should be possible using one of the joysticks.

### Start-Game Screen
The ball will be very close to the camera/filling up almost the entire screen. There should be a "Press button to start" message, once both players have pressed their "use item"-button, there is an animation of the ball falling down and the game starts. The paddles will also be visible on this screen, and already be able to be moved by the players' joysticks (to help them get used to the controls).

### End-Game Screen
Once the 5 minutes are over, a pop-up will appear that shows the final score and says something along the lines of "Left player won!" or "It's a draw!". There will be two buttons labeled something like "Rematch" and "Back" (navigation using joystick and button), "Rematch" takes the players back to the Start-Game-Screen, "Back" will lead back to the Start Screen.

## Technology
The game is designed to run on the Game Dev Students' arcade machine. The game engine used is Godot 4.5.1.

## Inclusion and Accessibility
The game will make sure that no essential information is conveyed only by colour.
The controls are kept simple, not requiring multiple buttons to be pressed at once, button mashing or buttons being held down for a longer time.

## Timeline Estimation
- First playable version with 1 item implemented and nice visuals/sounds:  January 7th
- First round of playtesting and fix the things that are most pressing for making a submission for the button festival: January 14th
- Make submission for button festival by January 16th
- Work on polishing the game, add more items, making it juicy, further playtesting: End of February
- If accepted for button festival: make version that we can show off there on March 6th/7th.

## Team and Credits
### Programming
Ivan, Max, Alex, Ida, Marlene, Marco (not good)

### Art/UI
Alex, Lisa, Ralev

### Music
Sina

### Sound effects
Sina, Marlene, Thomas

### Visual effects
Ida, Lisa

### Game Design
Alex, Marco, Marlene, Lisa, Thomas, Ivan, Ida, Sina

### Team Lead
Ida

### Testing

