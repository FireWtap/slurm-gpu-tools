# slurm-gpu-tools

Small, read-only helpers for finding GPUs on a Slurm cluster. No root, no accounting DB needed: only `sinfo`.

This project stems from my own necessities: I often find my self working with a SLURM cluster and it can be convoluted and hard to figure out exactly how to operate it with the overhead there is. Sometimes simple things should be simple. I hope this tool can be as useful to others as it is for me.

## sgpu

Free GPUs, CPUs and memory per node, and **how many jobs of your size actually fit**. A free GPU is useless if its
node has no CPUs or memory left.

```
$ sgpu -f -m 40
NODE         PART       GPU         GPU free   CPU free  MEM free GB  FITS  STATE
node401      defq       A6000           3/3       32/48        77/125     1  mixed
node402      defq       A6000           2/3       40/48        85/125     2  mixed
node411      defq       A6000           1/3       36/48        53/125     1  mixed
TOTAL: 6 free GPU(s) on 3 node(s); 4 job(s) of 8 CPU + 40 GB per GPU fit now
```

```
sgpu                 all nodes
sgpu -f              only nodes where a job fits
sgpu -a              also list nodes without GPUs (hidden by default)
sgpu -p gpu_a100     one partition
sgpu -c 16 -m 64     size of one 1-GPU job: 16 CPUs, 64 GB (defaults 8 CPU / 24 GB; env SGPU_CPUS, SGPU_MEM_GB)
```

`GPU` is the GRES type (`gpu:A6000:3`), or, if the GRES is untyped (`gpu:4`), the first GPU-like node feature (e.g. `TitanRTX`).
`FITS = min(free GPUs, free CPUs / c, free GB / m)`. Nodes that are drained, down, failed or in maintenance count as 0; *planned* nodes (state ending in `-`, held by the
backfill scheduler for a waiting job) have FITS 0; *completing* nodes are counted (their GPUs free up shortly).
GPU counts come from `sinfo -O Gres,GresUsed`: every `gpu[:type]:<n>` entry is summed; other GRES (e.g. Snellius'
`cpu:72`) and `(S:..)`/`(IDX:..)` annotations are ignored. Tested on DAS-6 (A6000) and Snellius (A100, H100, MIG).

## swhen

When will a GPU job of your size fit? Forecast from the running jobs' end times (start + time limit) and the queue.

```
$ swhen                      # 1 GPU, 8 CPU, 24 GB (defaults), partition defq
NODE       GPUs free  next GPU frees             your job fits here
node401    3/3        now                        now
node405    0/3        today 16:15 (2h01m)        today 16:15 (2h01m)
node412    1/3        now                        tomorrow 00:35 (10h20m)
...
optimistic  : NOW  on node401, node402, node411
with queue  : NOW  on node401, node402, node411   (1 pending GPU job(s) waiting for resources: ...)
```

```
swhen -g 3 -m 40     3 GPUs on one node, 40 GB per GPU (CPUs: -c per GPU, default 8)
swhen -p gpu_a100    another partition ('' = any)
swhen -v             detailed release list per node (time, +GPU/CPU/GB, job id)
```

- *next GPU frees*: first time a GPU on that node is released. *your job fits here*: first time GPUs **and** CPUs
  **and** memory for your job are free on that node (they differ when a node has a free GPU but no memory left).
- *optimistic*: running jobs only. *with queue*: pending GPU jobs waiting for resources start first, in priority order,
  then yours (a rough model of Slurm's scheduler).
- End times are time limits, i.e. upper bounds: jobs often finish earlier, so real waits are usually shorter.
- Read-only (`scontrol`), Python >= 3.6, standard library only.

## Install

```
git clone <this repo> ~/slurm-gpu-tools && ~/slurm-gpu-tools/install.sh   # symlinks bin/* into ~/.local/bin. You can also simply add the repo to your $PATH manually.
```
