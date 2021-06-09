package ttc2021

import fr.eseo.aof.xtend.utils.AOFAccessors
import jobCollection.JobCollectionPackage

import static fr.eseo.atol.gen.MetamodelUtils.*

import jobCollection.IncubateJob
import jobCollection.JobStatus
import jobCollection.TipLiquidTransfer

@AOFAccessors(JobCollectionPackage)
class JobCollection {

	// setting default values

        public val __duration = <IncubateJob, Integer>oneDefault(0)[
                _duration
        ]

        public val __temperature = <IncubateJob, Double>oneDefault(0.0)[
                _temperature
        ]

        public val __sourceCavityIndex = <TipLiquidTransfer, Integer>oneDefault(0)[
                _sourceCavityIndex
        ]

        public val __targetCavityIndex = <TipLiquidTransfer, Integer>oneDefault(0)[
                _targetCavityIndex
        ]

        public val __volume = <TipLiquidTransfer, Double>oneDefault(0.0)[
                _volume
        ]

	// enum to/from String converions

	public val __state = enumConverterBuilder(
		[
			_state
		], JobStatus, ""
	)

	public val __status = enumConverterBuilder(
		[
			_status
		], JobStatus, ""
	)
}
