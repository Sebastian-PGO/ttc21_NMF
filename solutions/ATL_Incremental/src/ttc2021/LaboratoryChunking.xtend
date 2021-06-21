package ttc2021

import java.util.Map
import java.util.HashMap

import fr.eseo.aof.extensions.AOFExtensions
import fr.eseo.atol.gen.ATOLGen
import fr.eseo.atol.gen.ATOLGen.Metamodel

import org.eclipse.papyrus.aof.core.impl.utils.DefaultObserver
import org.eclipse.papyrus.aof.core.AOFFactory
import com.google.common.collect.ImmutableMap
import org.eclipse.papyrus.aof.core.IBox


@ATOLGen(transformation="src/ttc2021/LaboratoryChunking.atl", metamodels = #[
    @Metamodel(name = "LA", impl=LaboratoryAutomation)
])
class LaboratoryChunking implements AOFExtensions {
    public val trace = new HashMap<Object, Map<String, Object>>

	def <E, T> chunksOf(IBox<E> it, int n) {
		indexedChunksOf(n)[chunk, i | ImmutableMap.of("samps", chunk, "index", AOFFactory.INSTANCE.createOne(i))]
	}

	static class ChunkInfo<E> {
		var srcIdx = 0
		var tgtIdx = 0
		var IBox<E> currentChunk = null
	}

	/*
	 *	Active chunking (append-only because no more is required here)
	 */
	def <E, T> indexedChunksOf(IBox<E> it, int n, (IBox<Map<String,Object>>, Integer)=>T f) {
		val ret = AOFFactory.INSTANCE.createSequence
		val info = new ChunkInfo

		val obs = new DefaultObserver<E> {
			override added(int index, E element) {
				if(info.currentChunk === null) {
					info.currentChunk = AOFFactory.INSTANCE.createSequence
					ret.add(f.apply(info.currentChunk, info.srcIdx / n))
				}

				info.currentChunk.add(ImmutableMap.of(
					"samp", AOFFactory.INSTANCE.createOne(element),
					"index", AOFFactory.INSTANCE.createOne(info.srcIdx) as Object)
				)

				info.srcIdx++
				info.tgtIdx++

				if(info.srcIdx % n === 0) {
					info.tgtIdx = 0
					info.currentChunk = null
				}
			}

			override removed(int index, E element) {
				throw new UnsupportedOperationException("This chunking implementation is append-only")
			}

			override replaced(int index, E newElement, E oldElement) {
				throw new UnsupportedOperationException("This chunking implementation is append-only")
			}

			override moved(int newIndex, int oldIndex, E element) {
				throw new UnsupportedOperationException("This chunking implementation is append-only")
			}
		}

		for(e : it) {
			obs.added(info.srcIdx, e);
		}

		addObserver(obs)

		ret
	}

	/*
	 *	Passive chunking
	 */
	def <E, T> oldIndexedChunksOf(IBox<E> it, int n, (IBox<Map<String,Object>>, Integer)=>T f) {
		val ret = AOFFactory.INSTANCE.createSequence

		for(var srcIdx = 0 ; srcIdx < length ; srcIdx += n) {
			val chunk = AOFFactory.INSTANCE.createSequence
			for(var tgtIdx = 0 ; tgtIdx < n && srcIdx + tgtIdx < length ; tgtIdx++) {
				val sample = get(srcIdx + tgtIdx)
				chunk.add(ImmutableMap.of("samp", AOFFactory.INSTANCE.createOne(sample), "index", AOFFactory.INSTANCE.createOne(srcIdx + tgtIdx) as Object))
			}
			ret.add(f.apply(chunk, srcIdx / n))
		}

		ret
	}

	// 0-padding as per the change samples, whereas the case paper specifies no padding (and a different microplate naming convention)
	def pad(IBox<Integer> it) {
		collect[
			String.format("%02d", it)
		]
	}

	// tuple accessors, this could be automated

	def _samps(Object it) {
		(it as ImmutableMap<String, IBox<Map<String, Object>>>).get("samps")
	}

	def <E> IBox<E> _samp(Object it) {
		(it as ImmutableMap<String, IBox<E>>).get("samp")
	}

	def IBox<Integer> _index(Object it) {
		(it as ImmutableMap<String, IBox<Integer>>).get("index")
	}
}
