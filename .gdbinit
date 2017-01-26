
# Load pwndbg
source ~/Documents/rep/pwndbg/gdbinit.py

# Better GDB defaults ----------------------------------------------------------

#set history save
set confirm off
set verbose off
set print pretty on
set print array off
set print array-indexes on
set python print-stack full

set disassembly-flavor intel
#dashboard assembly -style context 20 # 20 lines of assembly section

unset env LINES
unset env COLUMNS

