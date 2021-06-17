# The TTC 2021 Incremental Laboratory Automation Benchmark

## Case description

The `docs/2021_TTC_LabAutomation.pdf` file contains the [case description](https://github.com/tecan/ttc21incrementalLabWorkflows/raw/master/docs/2021_TTC_LabAutomation.pdf).

## Prerequisites

* 64-bit operating system
* Python 2.7 or higher
* R

## Solution Prerequisites

* Reference: You need to install [.NET Core 3.1](https://dotnet.microsoft.com/download/dotnet/3.1)
* ATL_Incremental: You need to install [docker](https://docs.docker.com/engine/install/) and [docker-compose](https://github.com/docker/compose). If your user is not in the docker group add `sudo` before `docker-compose` commands in [solution.ini](solutions/ATL_Incremental/solution.ini).

## Using the framework

The `scripts` directory contains the `run.py` script which is used for the following purposes:
* `run.py -b` -- builds the projects
* `run.py -b -s` -- builds the projects without testing
* `run.py -g` -- generates the instance models
* `run.py -m` -- runs the benchmark
* `run.py -v` -- visualizes the results of the latest benchmark

The `config` directory contains the configuration for the scripts:
* `config.json` -- configuration for the model generation and the benchmark
* `reporting.json` -- configuration for the visualization

### Running the benchmark

The script runs the benchmark for the given number of runs, for the specified tools and change sequences.

The benchmark results are stored in a CSV file. The header for the CSV file is stored in the `output/header.csv` file.

## Reporting and visualization

Make sure you read the `README.md` file in the `reporting` directory and install all the requirements for R.

## Implementing the benchmark for a new tool

To implement a tool, you need to create a new directory in the solutions directory and give it a suitable name.
