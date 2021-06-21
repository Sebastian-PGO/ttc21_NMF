- this solution is inspired from the the code in solutions/Reference
- remaining issues
        - PB1: failed samples reappear in failed jobs (propagation filtering issue)
		- but this may not be an actual problem because these jobs will not be reexecuted anyway
        - PB2: newly added samples require additional jobs to perform jobs already completed on existing samples
        - PB3: previous/next not supported yet
		- but this is redundant with job ordering
        - PB4: not optimized (especially no cache to prevent duplicate boxes)

- possibly remaining issue (to confirm)
	- distributions do not always have a source

