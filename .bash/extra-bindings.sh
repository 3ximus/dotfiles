# maintain state (\200 will save the line \201 will set it again)
# bind -x '"\200": TEMP_LINE=$READLINE_LINE; TEMP_POINT=$READLINE_POINT'
# bind -x '"\201": READLINE_LINE=$TEMP_LINE; READLINE_POINT=$TEMP_POINT; unset TEMP_POINT; unset TEMP_LINE'

# Use Esc-u to go up a dir
bind -x '"\206": "cd .."'
bind '"\eu":" \C-a\C-k\206\C-m\C-y\C-h"'
