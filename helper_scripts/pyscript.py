from mpi4py import MPI
import argparse
import sys
sys.path.append("/lustre/orion/syb111/proj-shared/Personal/jmerlet/codebase/python_mpi_wrapper")
from frontier_jobber import parse_commands, run_command

parser = argparse.ArgumentParser()
parser.add_argument('-c', '--commands')
args = parser.parse_args()
commands = parse_commands(args.commands)

comm = MPI.COMM_WORLD
size = comm.Get_size()
rank = comm.Get_rank()

for i, command in enumerate(commands):
    # match ranks to function calls
    if i % size != rank: continue
    print(f'running command {rank}/{size}')
    run_command(command)
    print(f'Finished command {rank}/{size}')