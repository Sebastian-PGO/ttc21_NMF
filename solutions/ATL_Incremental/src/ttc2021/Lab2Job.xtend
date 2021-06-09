package ttc2021

import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver
import org.eclipse.papyrus.aof.core.AOFFactory
import org.eclipse.papyrus.aof.core.IBox
import com.google.common.collect.ImmutableMap

import fr.eseo.atol.gen.ATOLGen
import fr.eseo.atol.gen.ATOLGen.Metamodel
import laboratoryAutomation.JobRequest
import laboratoryAutomation.Sample
import laboratoryAutomation.SampleState

import jobCollection.Job
import jobCollection.JobStatus

@ATOLGen(transformation="src/ttc2021/Lab2Job.atl", metamodels = #[
	@Metamodel(name = "LA", impl=LaboratoryAutomation),
	@Metamodel(name = "JC", impl=JobCollection)
])
class Lab2Job {

	// bidirectional mappings cannot be specified using the OCL syntax
	// plus we need propagation event filtering to break bidirectional incrementality
	def mapState(IBox<String> it, Job job) {
		val a = AOFFactory.INSTANCE.createSequence
		for(e : it) {
			a.add(a.length, e)
		}
		it.addObserver(new DefaultObserver<String> {
			override added(int index, String element) {
				throw new UnsupportedOperationException("Event filtering does not support forward adding")
			}

			override removed(int index, String element) {
				throw new UnsupportedOperationException("Event filtering does not support forward removing")
			}

			override replaced(int index, String newElement, String oldElement) {
				//throw new UnsupportedOperationException("Event filtering does not support forward replacing")
			}

			override moved(int newIndex, int oldIndex, String element) {
				throw new UnsupportedOperationException("Event filtering does not support forward moving")
			}
		})
		a.addObserver(new DefaultObserver<String> {
			override added(int index, String element) {
				throw new UnsupportedOperationException("Event filtering does not support reverse adding")
			}

			override removed(int index, String element) {
				throw new UnsupportedOperationException("Event filtering does not support reverse removing")
			}

			override replaced(int index, String newElement, String oldElement) {
				//throw new UnsupportedOperationException("Event filtering does not support reverse replacing")
				if(job.state == JobStatus.FAILED && newElement == "Error" && it.get(index) != "Error") {
					it.set(index, newElement)
				}
			}

			override moved(int newIndex, int oldIndex, String element) {
				throw new UnsupportedOperationException("Event filtering does not support reverse moving")
			}
		})
		a.collect([
			switch it {
				case "Waiting": "Planned"
				case "Processing": "Executing"
				case "Finished": "Succeeded"
				case "Error": "Failed"
				default: {System.err.println("ERROR:"+ it); ""}
			}
		])[
			switch it {
				case "Planned": "Waiting"
				case "Executing": "Processing"
				case "Succeeded": "Finished"
				case "Failed": "Error"
				default: {System.err.println("ERROR:"+ it); ""}
			}
		]
	}

	// enumeration literal comparison helpers

	def isError(IBox<Sample> it) {
		collectMutable[
			if(it === null) {
				IBox.ONE as IBox<?> as IBox<Boolean>
			} else {
				LAMM._state(it).collect[it == SampleState.ERROR]
			}
		]
	}

	def isPlanned(Job it) {
		JCMM._state(it).collect[it == JobStatus.PLANNED]
	}



	// tuple accessors, this could be automated

	def _tubes(JobRequest it) {
		LAMM._tubes(it)
	}

	def _processPlates(JobRequest it) {
		LAMM._processPlates(it)
	}

	def <E> IBox<E> _fst(Object it) {
		(it as ImmutableMap<String, IBox<E>>).get("fst")
	}

	def <E> IBox<E> _snd(Object it) {
		(it as ImmutableMap<String, IBox<E>>).get("snd")
	}

	// this should not be necessary (already in LaboratoryAutomation.xtend)

	def _sample(LaboratoryAutomation.ProcessWell it) {
		LAMM._sample(it)
	}
	def _columns(LaboratoryAutomation.ProcessPlate it) {
		LAMM._columns(it)
	}
	def _index(LaboratoryAutomation.ProcessPlate it) {
		LAMM._index(it)
	}
}
