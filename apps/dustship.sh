#!/bin/sh

score=0
time0=$(cat /proc/uptime)
time_ms=${time0%%? *}
time_ms=${time_ms#*.}
time0=${time0%%.*}

game_neg_y="\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
game_x=" "
life=3
engine0="\33[1;95m.\33[0m"
engine1="\33[1;91m,\33[0m"
engine=$engine0
player_x=2
player_y=0


# Startup information message
printf "\033c                \33[1;90m===\33[0m\33[1;97m\ \ \33[0m\33[1;94mDust Ship\33[0m\33[1;97m / /\33[0m\33[1;90m===\33[0m

Collect the asteroids coming from the top right corner!            \33[1;94m0\33[0m

Place your ship just below the asteroid.

Don't let the asteroid exceed the line where is your ship!    \33[1;93mL\33[0m\33[1;96m/\33[0m

Play with the arrows <-^-> or WASD. Quit with 'Q'

Press Enter <-'"

read null

# Get the game time
game_time() {
  time=$(cat /proc/uptime)
  time_ms=${time%%? *}
  time_ms=${time_ms#*.}
  time=${time%%.*}
  time=$(( $time - $time0 ))
}

# Generate random numbers
get_rand() {
  RAND255=$(od -An -N1 -tu1 /dev/urandom)
  RAND3=${RAND255%??}
  RAND10=${RAND255%?}
  RAND10=${RAND255#$RAND10}
  RAND30=$RAND3$RAND10

  RAND100=${RAND255%?}
  RAND100=${RAND255#$RAND100}
}

# Get the key form the TTY
get_key() {
  stty_state=$(stty -g)
  stty raw -echo min 0
  key=$(printf "$(dd bs=3 count=1 2>/dev/null)" | xxd)
  stty "$stty_state"
  keycode=${key% *}
  key=${key#$keycode *}
  key=${key#*.}
}

# Create a new item
create_item() {
  get_rand
  item_x=$(( 64 - $RAND30 ))
  item_y=17
  neg_y=
  item_neg_y=
  item_x_space=
  i=0

  # Random item skin
  case "$RAND3" in
    '  ') item_skin="\33[1;94m0\33[0m";;
    ' 1') item_skin="\33[1;95mQ\33[0m";;
    ' 2') item_skin="\33[1;96mD\33[0m";;
  esac

  while [ $item_x != $i ] ;do
    item_x_space="$item_x_space "
    i=$(( i + 1 ))
  done
  item_time=$time_ms
}

# Determine the item position
item_pos() {
  [ "$item_x" = "" ] && create_item
  if [ $item_time != $time_ms ] && { [ $time_ms = 0 ] || [ $time_ms = 2 ] || [ $time_ms = 4 ] || [ $time_ms = 6 ] || [ $time_ms = 8 ]; } ;then
    item_x_space=${item_x_space#???}
    item_x=$(( item_x - 3 ))
    item_neg_y="$item_neg_y\n"
    item_y=$(( item_y - 1 ))
    neg_y=$neg_y?? && item_time=$time_ms
  fi
}

# Move the player and determine its position
position_move() {
  case $key in
    w|'[A') [ $player_y != 16 ] && player_y=$(( player_y + 1 )) && game_neg_y=${game_neg_y#??} && game_y="$game_y\n";; # UP
    s|'[B') [ $player_y != 0 ] && player_y=$(( player_y - 1 )) && game_neg_y="$game_neg_y\n" && game_y=${game_y#??};; # DOWN
    d|'[C') [ $player_x != 48 ] && player_x=$(( player_x + 1 )) && game_x="$game_x ";; # RIGHT
    a|'[D') [ $player_x != 0 ] && player_x=$(( player_x - 1 )) && game_x=${game_x#?};; # LEFT
    q) clear; exit;;
  esac
}

# Player ship position
player_ship() {
  # __
  # L/
  [ $engine = $engine0 ] && engine=$engine1 || engine=$engine0
}

# Score, life and gameover
state() {
  [ $player_y -gt $(( item_y - 4 )) ] && { [ $player_x = $item_x ] || [ $(( player_x + 1 )) = $item_x ]; } && score=$(( score + 1 )) && item_x=
  [ $item_x -lt 0 ] && life=$(( life - 1 )) && item_x=
  [ $item_y = $player_y ] && item_x= && life=$(( life - 1 ))
  if [ $life -lt 1 ] ;then
    printf "\033c       \33[1;90m===\33[0m\33[1;97m\ \ \33[0m\33[1;91mGAME OVER\33[0m\33[1;97m / /\33[0m\33[1;90m===\33[0m

    You score: \33[1;93m$score\33[0m

    time: $time.$time_ms

    https://github.com/j8r/DustShip
    Copyright (c) 2016 Julien Reichardt - MIT License (MIT)

    Press Enter <-'"
    read null
    exit
  fi
}
# Create the game canvas
game_canvas() {
  player_neg_y=${game_neg_y#$neg_y}
  canvas="$item_neg_y${item_x_space}$item_skin$player_neg_y ${game_x}$weapon
$game_x${engine}\33[1;93mL\33[0m\33[1;96m/\33[0m$game_y"
}

# Main game loop function
main_game() {
  while game_time ;do
    get_key
    position_move
    player_ship
    item_pos
    game_canvas
    state
    printf "\033c\33[40mLife: \33[1;91m$life                                    \33[0m\33[40mScore: \33[1;93m$score\33[0m
$canvas
 time: $time.$time_ms                                   Q: quit"
done
}
main_game
