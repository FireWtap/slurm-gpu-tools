# slurm-gpu-tools

Small, read-only helpers for finding GPUs on a Slurm cluster. No root, no accounting DB needed: only `sinfo`.

## sgpu

Free GPUs, CPUs and memory per node, and **how many jobs of your size actually fit**. A free GPU is useless if its
node has no CPUs or memory left.

```
$ sgpu -f -m 40
NODE         PART        GPU free   CPU free  MEM free GB  FITS  STATE
node401      defq            3/3       32/48        77/125     1  mixed
node402      defq            2/3       40/48        85/125     2  mixed
node411      defq            1/3       36/48        53/125     1  mixed
TOTAL: 6 free GPU(s) on 3 node(s); 4 job(s) of 8 CPU + 40 GB per GPU fit now
```

```
sgpu                 all nodes
sgpu -f              only nodes where a job fits
sgpu -p gpu_a100     one partition
sgpu -c 16 -m 64     size of one 1-GPU job: 16 CPUs, 64 GB (defaults 8 CPU / 24 GB; env SGPU_CPUS, SGPU_MEM_GB)
```

`FITS = min(free GPUs, free CPUs / c, free GB / m)`. Nodes that are drained, down, failed or in maintenance count as 0.
GPU counts come from `sinfo -O Gres,GresUsed`, so GRES must be `gpu:<type>:<n>` or `gpu:<n>`.

Tested on: DAS-6 (Slurm 20.11, 3x A6000 per node).

## Install

```
git clone <this repo> ~/slurm-gpu-tools && ~/slurm-gpu-tools/install.sh   # symlinks bin/* into ~/.local/bin
```
